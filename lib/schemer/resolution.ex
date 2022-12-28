defmodule Schemer.Resolution do
  @moduledoc """
  Resolve a path.

  ## Contents
  - `:schema` - The current schema.
  - `:resolve_name` - The resolve_name, the first arugment that passed to the resolver function.
  - `:context` - The context passed from `Schemer.run`.
  - `:result` - The result struct of the resolution.
  - `:options` - The other options of the resolution.
  """

  use TypedStruct

  require Logger

  alias Schemer.Execution
  alias Schemer.Node
  alias Schemer.Result
  alias Schemer.Schema

  @type resolve_name() :: atom()

  @derive {Inspect, only: [:resolve_name]}

  typedstruct do
    field :schema, Schema.t(), enforce: true
    field :resolve_name, resolve_name(), enforce: true
    field :context, map(), default: %{}
    field :result, map(), default: %{}
    field :options, Keyword.t(), default: []
  end

  @type resolver_result(value) ::
          :ignore
          | {:ok, value}
          | {:ok, value, t()}
          | {:error, term()}

  @type resolver_result() :: resolver_result(term())

  @spec resolve(t(), path_str :: [String.t()]) :: {:ok, [Node.t()], t()} | {:error, term()}
  def resolve(%__MODULE__{} = resolution, path_str) do
    path_str
    |> Enum.reduce_while(
      {make_root_node(resolution), resolution.options[:root_value], [], resolution},
      fn node_key, {parent_node, parent_value, path, res} ->
        execution = make_execution(node_key: node_key, path: path, parent_value: parent_value)

        case do_resolve_node(parent_node, execution, res) do
          {:ok, node, value, res} ->
            execution =
              execution
              |> Map.put(:path, [node | path])
              |> Execution.put_value(value)

            # credo:disable-for-next-line Credo.Check.Refactor.Nesting
            Logger.debug(fn ->
              """
              Node(#{node.name}) has been resolved.
              node_name: #{inspect(node.name)}
              node_key: #{inspect(execution.node_key)}
              value: #{inspect(value)}
              """
            end)

            {:cont, {node, value, execution.path, put_result(res, execution)}}

          {:error, error} ->
            {:halt, {:error, error}}
        end
      end
    )
    |> case do
      {:error, error} ->
        {:error, error}

      {_node, _value, path, res} ->
        {:ok, path, res}
    end
  end

  @doc """
  Get the current path.

  Each `Absinthe.Resolution` struct holds the current result path as a list of
  nodes. Usually however you don't need the full AST list
  and instead just want the path that will eventually end up in the result.

  For that, use this function.

  ## Examples
  Given some identifier:
  ```
  "users.user_uuid"
  ```

  If you called this function inside a resolver on the users user_uuid field it
  returns a value like:

  ```elixir
  resolve fn _, _, execution, _ ->
    Schemer.Resolution.path(execution.path) #=> ["users", "user_uuid"]
  end
  ```
  """
  @spec path([Node.t() | String.t()]) :: [String.t()]
  def path(path) when is_list(path) do
    Enum.reduce(path, [], fn
      %Node{name: name}, acc ->
        [name | acc]

      name, acc when is_binary(name) ->
        [name | acc]
    end)
  end

  @doc """
  Get the value from the path.
  """
  @spec get_result(t(), [Node.t()]) :: nil | term()
  def get_result(%__MODULE__{} = res, path) when is_list(path) do
    case get_in(res.result, path(path)) do
      nil -> nil
      %Result{execution: execution} -> execution.value
    end
  end

  defp make_root_node(%__MODULE__{} = res) do
    %Node{
      name: "Root",
      type: :root,
      nodes: res.schema.roots
    }
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp do_resolve_node(%Node{nodes: [_ | _] = nodes}, execution, res) do
    Enum.find_value(
      nodes,
      {:error, :invalid_path},
      fn %{resolve: resolution_function} = node ->
        execution = %{execution | path: [node | execution.path]}

        resolution_function
        |> extract_from_resolve_map(res)
        |> case do
          {mod, fun} when is_atom(mod) and is_atom(fun) ->
            ignore_wrap_resolve(Function.capture(mod, fun, 3), [
              execution.node_key,
              execution,
              res
            ])

          {mod, fun, [_ | _] = args} when is_atom(mod) and is_atom(fun) ->
            ignore_wrap_resolve(
              Function.capture(mod, fun, 3 + length(args)),
              [
                execution.node_key,
                execution,
                res | args
              ]
            )

          fun when is_function(fun, 1) ->
            ignore_wrap_resolve(fun, [execution.node_key])

          fun when is_function(fun, 2) ->
            ignore_wrap_resolve(fun, [execution.node_key, execution])

          fun when is_function(fun, 3) ->
            ignore_wrap_resolve(fun, [execution.node_key, execution, res])

          _otherwise ->
            raise ArgumentError, """
            Node resolve property must be a 1 arity anonymous function,
            2 arity anonymous function, 3 arity anonymous function,
            a `{Module, :function}` tuple, a `{Module, :function, args}` tuple,
            or `%{resolve_name => resolve_fun}` map resolution_function.

            Instead got: #{inspect(resolution_function)}

            Resolving node:

                #{execution.node_key} at path #{inspect(execution.path)}

            Execution Info: #{inspect(execution)}
            Resolution Info: #{inspect(res)}
            """
        end
        |> case do
          :ignore -> false
          {:ok, value} -> {:ok, node, value, res}
          {:ok, value, res} -> {:ok, node, value, res}
          {:error, error} -> {:error, error}
        end
      end
    )
  end

  defp do_resolve_node(_parent_node, _execution, _res) do
    {:error, :invalid_path}
  end

  defp extract_from_resolve_map(%{} = map_resolve, %{resolve_name: resolve_name})
       when is_map_key(map_resolve, resolve_name) do
    Map.get(map_resolve, resolve_name)
  end

  defp extract_from_resolve_map(resolution_function, _res), do: resolution_function

  defp ignore_wrap_resolve(fun, args) do
    apply(fun, args)
  rescue
    exception ->
      case Exception.blame(:error, exception, __STACKTRACE__) do
        {%FunctionClauseError{args: ^args}, _stacktrace} -> :ignore
        _otherwise -> reraise exception, __STACKTRACE__
      end
  end

  defp make_execution(options) do
    %Execution{
      status: :unresolved,
      node_key: Keyword.fetch!(options, :node_key),
      path: Keyword.fetch!(options, :path),
      parent_value: Keyword.fetch!(options, :parent_value)
    }
  end

  defp put_result(res, execution) do
    %{res | result: put_in(res.result, path(execution.path), Result.wrap(execution))}
  end
end

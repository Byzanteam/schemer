defmodule Schemer do
  @moduledoc """
  Resolve identifier to a value.
  """

  alias Schemer.Resolution
  alias Schemer.Schema

  @type result_t :: term()

  @type run_opts :: [
          context: %{},
          root_value: term(),
          resolve_name: atom()
        ]

  @type run_result() :: {:ok, result_t()} | {:error, atom()}
  @type run_result(t) :: {:ok, t} | {:error, atom()}

  @seperator "."

  @spec run(String.t(), Schema.t(), run_opts) :: run_result()
  def run(identifier, %Schema{} = schema, opts \\ []) do
    options = options(Keyword.put(opts, :schema, schema))
    path_str = String.split(identifier, @seperator, trim: true)

    case Resolution.resolve(make_resolution(options), path_str) do
      {:ok, path, res} ->
        current_node = hd(path)

        if current_node.type in [:leaf, :leaf_like] do
          result = get_in(res.result, Resolution.path(path))
          {:ok, result.execution.value}
        else
          {:error, :invalid_leaf_node}
        end

      error ->
        error
    end
  end

  @defaults [
    resolve_name: :default,
    context: %{},
    root_value: %{}
  ]

  defp options(overrides) do
    Keyword.merge(@defaults, overrides)
  end

  defp make_resolution(opts) do
    %Resolution{
      schema: Keyword.fetch!(opts, :schema),
      context: Keyword.fetch!(opts, :context),
      resolve_name: Keyword.fetch!(opts, :resolve_name),
      options: opts
    }
  end
end

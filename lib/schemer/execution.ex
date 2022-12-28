defmodule Schemer.Execution do
  @moduledoc false

  use TypedStruct

  @type node_key :: String.t()

  typedstruct do
    field :status, :resolved | :unresolved, enforce: true
    field :node_key, node_key(), enforce: true
    field :path, [Node.t()], enforce: true
    field :parent_value, term(), default: %{}
    field :value, term(), default: %{}
  end

  @doc "Put value, and mark the execution resolved."
  @spec put_value(t(), term()) :: t()
  def put_value(%__MODULE__{} = execution, value) do
    %{execution | status: :resolved, value: value}
  end

  defimpl Inspect do
    import Inspect.Algebra

    # credo:disable-for-next-line Credo.Check.Readability.Specs
    def inspect(execution, opts) do
      list =
        for attr <- [:node_key, :parent_value, :path, :status, :value] do
          {attr, Map.get(execution, attr)}
        end

      container_doc("#Schemer.Execution<", list, ">", opts, fn
        {:node_key, node_key}, opts ->
          concat("node_key: ", to_doc(node_key, opts))

        {:parent_value, parent_value}, opts ->
          concat("parent_value: ", to_doc(parent_value, opts))

        {:path, path}, _opts ->
          concat("path: ", to_doc(Schemer.Resolution.path(path), opts))

        {:status, status}, opts ->
          concat("status: ", to_doc(status, opts))

        {:value, value}, opts ->
          concat("value: ", to_doc(value, opts))
      end)
    end
  end
end

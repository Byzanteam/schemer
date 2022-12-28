defmodule Schemer.Resolver.InheritFromParent do
  @moduledoc """
  The value is inherited from parent_value.
  """

  @spec build(String.t()) :: {module(), atom(), [String.t()]}
  def build(node_name) when is_binary(node_name) do
    {__MODULE__, :resolve, [node_name]}
  end

  @spec resolve(String.t(), Schemer.Execution.t(), Schemer.Resolution.t(), String.t()) ::
          {:ok, term()} | :ignore
  def resolve(node_name, execution, _res, node_name) do
    {:ok, execution.parent_value}
  end

  def resolve(_node_name, _execution, _res, _otherwise) do
    :ignore
  end
end

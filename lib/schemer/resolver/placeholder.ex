defmodule Schemer.Resolver.Placeholder do
  @moduledoc """
  Return `nil` as the value.
  """

  @spec build(String.t()) :: {module(), atom(), [String.t()]}
  def build(node_name) when is_binary(node_name) do
    {__MODULE__, :resolve, [node_name]}
  end

  @spec resolve(String.t(), Schemer.Execution.t(), Schemer.Resolution.t(), String.t()) ::
          {:ok, nil} | :ignore
  def resolve(node_name, _execution, _res, node_name) do
    {:ok, nil}
  end

  def resolve(_node_name, _execution, _res, _otherwise), do: :ignore
end

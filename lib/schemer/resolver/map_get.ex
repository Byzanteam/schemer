defmodule Schemer.Resolver.MapGet do
  @moduledoc """
  Get the value from a map.
  """

  alias Schemer.Execution

  @spec resolve(Execution.node_key(), Execution.t(), term()) :: {:ok, term()} | :ignore
  def resolve(node_key, execution, _res) do
    Enum.find_value(execution.parent_value, :ignore, fn {key, value} ->
      cond do
        key === node_key ->
          {:ok, value}

        is_atom(key) && Atom.to_string(key) === node_key ->
          {:ok, value}

        true ->
          nil
      end
    end)
  end
end

defmodule Schemer.Resolver.ListGet do
  @moduledoc """
  Get the value from a list of map.

  ## ByKey
  The value is that for which value of the `key` equals to the node_key.
  """

  @spec build_by_key(String.t() | atom()) :: {module(), atom(), [{atom(), String.t()}]}
  def build_by_key(key) when is_binary(key) or is_atom(key) do
    {key_atom, key_str} =
      if is_binary(key) do
        # credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom
        {String.to_atom(key), key}
      else
        {key, Atom.to_string(key)}
      end

    {__MODULE__, :resolve, [{key_atom, key_str}]}
  end

  @spec resolve(String.t(), Schemer.Execution.t(), Schemer.Resolution.t(), {atom(), String.t()}) ::
          {:ok, term()} | :ignore
  def resolve(node_key, execution, _res, {key_atom, key_str}) do
    Enum.find_value(execution.parent_value, :ignore, fn %{} = map ->
      with(
        :error <- Map.fetch(map, key_atom),
        :error <- Map.fetch(map, key_str)
      ) do
        nil
      else
        {:ok, ^node_key} -> {:ok, map}
        _otherwise -> nil
      end
    end)
  end
end

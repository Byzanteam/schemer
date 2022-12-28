defmodule Schemer.Support.IgnoreWrapSchema do
  @moduledoc false

  alias Schemer.Schema
  alias Schemer.Node

  def wrapped do
    %Schema{
      roots: [
        %Node{
          type: :leaf,
          name: "ignore_wrap",
          resolve: &resolve_first/3
        }
      ]
    }
  end

  def raise do
    %Schema{
      roots: [
        %Node{
          type: :leaf,
          name: "raise_or_work",
          resolve: &resolve_second/3
        }
      ]
    }
  end

  defp resolve_first("not_match", _, _) do
    {:ok, :ok}
  end

  defp resolve_second("work", _, _) do
    {:ok, do_second(1)}
  end

  defp resolve_second("raise", _, _) do
    {:ok, do_second(2)}
  end

  defp do_second(1), do: 1
end

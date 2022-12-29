defmodule Schemer.Schema do
  @moduledoc """
  The schema for a schemer.
  """

  use TypedStruct

  typedstruct do
    field :roots, [Schemer.Node.t()], enforce: true
  end
end

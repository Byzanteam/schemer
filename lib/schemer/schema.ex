defmodule Schemer.Schema do
  @moduledoc false

  use TypedStruct

  typedstruct do
    field :roots, [Schemer.Node.t()], enforce: true
  end
end

defmodule Schemer.Node do
  @moduledoc """
  The node of the schema.

  ## resolve
  The resolve_fun of the node.

  ### Returns:
  - `{:ok, value}`Returns a executed value.
  - `{:ok, value, resolution}`: The third element will overwrite the current resolution,
  you can overwrite context and others in this way.
  - `{:error, error}`: This will halt resolution immediately.
  """

  alias Schemer.Execution
  alias Schemer.Resolution

  use TypedStruct

  @type resolve_fun ::
          {module(), fun :: atom()}
          | {module(), fun :: atom(), args :: [term()]}
          | (Execution.node_key() -> Resolution.resolver_result())
          | (Execution.node_key(), Execution.t() -> Resolution.resolver_result())
          | (Execution.node_key(), Execution.t(), Resolution.t() -> Resolution.resolver_result())

  @type node_type() :: :root | :normal | :leaf | :leaf_like

  typedstruct do
    field :type, node_type(), enforce: true
    field :name, String.t(), enforce: true
    field :resolve, resolve_fun() | %{Resolution.resolve_name() => resolve_fun()}
    field :nodes, [t()], default: []
  end
end

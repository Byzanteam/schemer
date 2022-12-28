defmodule Schemer.Result do
  @moduledoc """
  The result of the resolution.

  ## Example
  Schema
  ```
  users
    .user_uuid
  ```

  Result
  ```elixir
  %{
    "users" => %Schemer.Result{
      execution: %Schemer.Execution{
        node_key: "users",
        parent_value: %{},
        path: [
          # nodes
        ],
        status: :resolved,
        value: nil
      },
      fields: %{
        "user_uuid" => %Schemer.Result{
          execution: %Schemer.Execution{
            node_key: "1",
            parent_value: nil,
            path: [
              # nodes
            ],
            status: :resolved,
            value: %{name: "user-1", uuid: "1"}
          },
          fields: %{},
          node_name: "user_uuid"
        }
      },
      node_name: "users"
    }
  }
  ```
  """

  @behaviour Access

  use TypedStruct

  alias Schemer.Execution

  @type node_name :: String.t()

  typedstruct do
    field :node_name, node_name(), enforce: true
    field :execution, Execution.t(), enforce: true
    field :fields, %{optional(node_name()) => t()}, default: %{}
  end

  @doc "Wrap an execution with Result."
  @spec wrap(Execution.t()) :: t()
  def wrap(%Execution{} = execution) do
    node = List.first(execution.path)

    %__MODULE__{
      node_name: node.name,
      execution: execution
    }
  end

  @impl Access
  def fetch(%__MODULE__{} = data, key) do
    Map.fetch(data.fields, key)
  end

  @impl Access
  def get_and_update(%__MODULE__{} = data, key, function) do
    {get_value, fields} = Map.get_and_update(data.fields, key, function)
    {get_value, %{data | fields: fields}}
  end

  @impl Access
  def pop(%__MODULE__{} = data, key) do
    {value, fields} = Map.pop(data.fields, key)
    {value, %{data | fields: fields}}
  end
end

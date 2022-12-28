defmodule Schemer.Support.ResolveNameSchema do
  @moduledoc false

  alias Schemer.Schema
  alias Schemer.Node
  alias Schemer.Resolver

  def schema do
    %Schema{
      roots: [root_node()]
    }
  end

  defp root_node do
    %Node{
      type: :normal,
      name: "users",
      resolve: Resolver.Placeholder.build("users"),
      nodes: [
        %Node{
          type: :leaf,
          name: "user_uuid",
          resolve: &resolve_user/3
        }
      ]
    }
  end

  def map_resolve_schema do
    %Schema{
      roots: [map_resolve_root_node()]
    }
  end

  defp map_resolve_root_node do
    %Node{
      type: :normal,
      name: "users",
      resolve: Resolver.Placeholder.build("users"),
      nodes: [
        %Node{
          type: :leaf,
          name: "user_uuid",
          resolve: %{
            type: &resolve_user/3,
            value: &resolve_user/3
          }
        }
      ]
    }
  end

  @users [
    %{
      uuid: "1",
      name: "user-1"
    },
    %{
      uuid: "2",
      name: "user-2"
    }
  ]

  defp resolve_user(user_uuid, _execution, %{resolve_name: :value}) do
    @users
    |> Enum.find(fn user -> user.uuid === user_uuid end)
    |> case do
      nil -> :ignore
      user -> {:ok, user}
    end
  end

  defp resolve_user(user_uuid, _execution, %{resolve_name: :type}) do
    {:ok, %{type: :user, uuid: user_uuid}}
  end
end

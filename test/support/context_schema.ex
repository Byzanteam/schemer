defmodule Schemer.Support.ContextSchema do
  @moduledoc false

  alias Schemer.Schema
  alias Schemer.Node
  alias Schemer.Resolver

  def schema do
    %Schema{
      roots: [root_node(), dynamic_root_node()]
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

  defp dynamic_root_node do
    %Node{
      type: :normal,
      name: "dynamic_users",
      resolve: fn
        "dynamic_users", _execution, %{context: context} = res ->
          {:ok, nil, %{res | context: Map.put(context, :users, @users)}}

        _, _, _ ->
          :ignore
      end,
      nodes: [
        %Node{
          type: :leaf,
          name: "user_uuid",
          resolve: &resolve_user/3
        }
      ]
    }
  end

  defp resolve_user(user_uuid, _execution, %{context: %{users: users}}) do
    users
    |> Enum.find(fn user -> user.uuid === user_uuid end)
    |> case do
      nil -> :ignore
      user -> {:ok, user}
    end
  end
end

defmodule Schemer.Resolver.ListGetTest do
  use ExUnit.Case, async: true

  alias Schemer.Schema
  alias Schemer.Node
  alias Schemer.Resolver

  test "works" do
    schema = schema()

    assert Schemer.run("users.1", schema) ===
             {:ok, %{uuid: "1"}}

    assert Schemer.run("users.2", schema) ===
             {:ok, %{"uuid" => "2"}}

    assert Schemer.run("users.3", schema) ===
             {:error, :invalid_path}
  end

  defp schema do
    %Schema{
      roots: [
        %Node{
          type: :normal,
          name: "users",
          resolve: fn "users" ->
            {:ok,
             [
               %{
                 uuid: "1"
               },
               %{
                 "uuid" => "2"
               }
             ]}
          end,
          nodes: [
            %Node{
              type: :leaf,
              name: "user_uuid",
              resolve: Resolver.ListGet.build_by_key("uuid")
            }
          ]
        }
      ]
    }
  end
end

defmodule SchemerTest do
  use ExUnit.Case, async: true

  describe "Simple" do
    setup do
      schema = Schemer.Support.Schema.simple()
      [schema: schema]
    end

    test "works when ends at leaf node", %{schema: schema} do
      assert Schemer.run("database.tables.1.associations.rows.1", schema) ===
               {:ok, %{table_uuid: "1", uuid: "1"}}

      assert Schemer.run("database.tables.1.attributes.uuid", schema) ===
               {:ok, "1"}

      assert Schemer.run("database.tables.1.attributes.title", schema) ===
               {:ok, "1"}
    end

    test "works when ends at leaf_like node", %{schema: schema} do
      assert Schemer.run("database.tables.1", schema) ===
               {:ok, %{uuid: "1", title: "1"}}
    end

    test "failed when ends at normal node", %{schema: schema} do
      assert Schemer.run("database.tables.1.associations", schema) ===
               {:error, :invalid_leaf_node}
    end

    test "failed when invalid path", %{schema: schema} do
      assert Schemer.run("database.table.1", schema) ===
               {:error, :invalid_path}
    end
  end

  describe "IgnoreWrap" do
    test "works" do
      schema = Schemer.Support.IgnoreWrapSchema.wrapped()

      assert Schemer.run("ignore_wrap", schema) === {:error, :invalid_path}
    end

    test "dont resuce other errors" do
      schema = Schemer.Support.IgnoreWrapSchema.raise()

      assert Schemer.run("work", schema) === {:ok, 1}

      assert_raise FunctionClauseError, fn ->
        Schemer.run("raise", schema) === :error
      end
    end
  end

  describe "multiple root nodes" do
    setup do
      schema = Schemer.Support.Schema.multiple_roots()
      [schema: schema]
    end

    test "works when ends at leaf node", %{schema: schema} do
      assert Schemer.run("database.tables.1.associations.rows.1", schema) ===
               {:ok, %{table_uuid: "1", uuid: "1"}}

      assert Schemer.run("workflow.case_data.associations.task", schema) ===
               {:ok, %{type: :task}}
    end
  end

  describe "context" do
    setup do
      schema = Schemer.Support.ContextSchema.schema()
      [schema: schema]
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

    test "works when ends at leaf node", %{schema: schema} do
      context = %{users: @users}

      assert Schemer.run("users.1", schema, context: context) ===
               {:ok, %{uuid: "1", name: "user-1"}}

      assert Schemer.run("users.3", schema, context: context) ===
               {:error, :invalid_path}
    end

    test "works with modified context", %{schema: schema} do
      assert Schemer.run("dynamic_users.1", schema) ===
               {:ok, %{uuid: "1", name: "user-1"}}

      assert Schemer.run("dynamic_users.3", schema) ===
               {:error, :invalid_path}
    end
  end

  describe "resolve_name" do
    setup do
      schema = Schemer.Support.ResolveNameSchema.schema()
      [schema: schema]
    end

    test "works ", %{schema: schema} do
      assert Schemer.run("users.1", schema, resolve_name: :value) ===
               {:ok, %{uuid: "1", name: "user-1"}}

      assert Schemer.run("users.3", schema, resolve_name: :value) ===
               {:error, :invalid_path}

      assert Schemer.run("users.1", schema, resolve_name: :type) ===
               {:ok, %{type: :user, uuid: "1"}}

      assert Schemer.run("users.3", schema, resolve_name: :type) ===
               {:ok, %{type: :user, uuid: "3"}}
    end
  end

  describe "resolve_name with map resolve" do
    setup do
      schema = Schemer.Support.ResolveNameSchema.map_resolve_schema()
      [schema: schema]
    end

    test "works ", %{schema: schema} do
      assert Schemer.run("users.1", schema, resolve_name: :value) ===
               {:ok, %{uuid: "1", name: "user-1"}}

      assert Schemer.run("users.3", schema, resolve_name: :value) ===
               {:error, :invalid_path}

      assert Schemer.run("users.1", schema, resolve_name: :type) ===
               {:ok, %{type: :user, uuid: "1"}}

      assert Schemer.run("users.3", schema, resolve_name: :type) ===
               {:ok, %{type: :user, uuid: "3"}}
    end
  end
end

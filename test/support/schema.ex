defmodule Schemer.Support.Schema do
  @moduledoc false

  alias Schemer.Schema
  alias Schemer.Node
  alias Schemer.Resolution
  alias Schemer.Resolver

  def simple do
    %Schema{
      roots: [database_root()]
    }
  end

  def multiple_roots do
    %Schema{
      roots: [database_root(), workflow_root()]
    }
  end

  defp database_root do
    %Node{
      type: :normal,
      name: "database",
      resolve: Resolver.Placeholder.build("database"),
      nodes: [
        %Node{
          type: :normal,
          name: "tables",
          resolve: Resolver.Placeholder.build("tables"),
          nodes: [
            %Node{
              type: :leaf_like,
              name: "table_uuid",
              resolve: &resolve_table/1,
              nodes: [
                %Node{
                  type: :normal,
                  name: "associations",
                  resolve: Resolver.Placeholder.build("associations"),
                  nodes: [
                    %Node{
                      type: :normal,
                      name: "rows",
                      resolve: Resolver.Placeholder.build("rows"),
                      nodes: [
                        %Node{
                          type: :leaf,
                          name: "row_uuid",
                          resolve: &resolve_row/3
                        }
                      ]
                    }
                  ]
                },
                %Node{
                  type: :normal,
                  name: "attributes",
                  resolve: Resolver.InheritFromParent.build("attributes"),
                  nodes: [
                    %Node{
                      type: :leaf,
                      name: "uuid",
                      resolve: {Resolver.MapGet, :resolve}
                    },
                    %Node{
                      type: :leaf,
                      name: "title",
                      resolve: {Resolver.MapGet, :resolve}
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    }
  end

  defp workflow_root do
    %Node{
      type: :normal,
      name: "workflow",
      resolve: Resolver.Placeholder.build("workflow"),
      nodes: [
        %Node{
          type: :normal,
          name: "case_data",
          resolve: Resolver.Placeholder.build("case_data"),
          nodes: [
            %Node{
              type: :normal,
              name: "associations",
              resolve: Resolver.Placeholder.build("associations"),
              nodes: [
                %Node{
                  type: :leaf,
                  name: "task",
                  resolve: fn _, _ ->
                    {:ok, %{type: :task}}
                  end
                }
              ]
            }
          ]
        }
      ]
    }
  end

  defmodule DB do
    @moduledoc false

    @tables [
      %{
        uuid: "1",
        title: "1"
      },
      %{
        uuid: "2",
        title: "2"
      },
      %{
        uuid: "3",
        title: "3"
      }
    ]

    @rows [
      %{
        table_uuid: "1",
        uuid: "1"
      },
      %{
        table_uuid: "1",
        uuid: "2"
      },
      %{
        table_uuid: "2",
        uuid: "1"
      }
    ]

    def get_table(table_uuid) do
      Enum.find(@tables, fn table -> table.uuid === table_uuid end)
    end

    def get_row(table_uuid, row_uuid) do
      Enum.find(@rows, fn row ->
        row.table_uuid === table_uuid && row.uuid === row_uuid
      end)
    end
  end

  defp resolve_table(table_uuid) do
    case DB.get_table(table_uuid) do
      nil -> :ignore
      table -> {:ok, table}
    end
  end

  defp resolve_row(row_uuid, execution, res) do
    path = Enum.drop_while(execution.path, fn node -> node.name !== "table_uuid" end)
    %{uuid: table_uuid} = Resolution.get_result(res, path)

    case DB.get_row(table_uuid, row_uuid) do
      nil -> :ignore
      row -> {:ok, row}
    end
  end
end

defmodule Q do
  def query(dbname, sql, params \\ []) do
    pool_name = :"#{dbname}.Pool"

    pool_name
    |> Postgrex.query!(sql, params, [pool: DBConnection.Poolboy])
    |> map_result()
  end

  def into({:ok, result}, struct) do
    {:ok, into(result, struct)}
  end

  def into(result, struct) when is_list(result) do
    Enum.map(result, fn item ->
      into(item, struct)
    end)
  end

  def into(result, struct) do
    Mappable.to_struct(result, struct)
  end

  defp map_result(result = %Postgrex.Result{}) do
    rows = result.rows || []
    columns = result.columns || []

    result = Enum.map(rows, fn row ->
      columns |> Enum.zip(row) |> Enum.into(%{})
    end)

    {:ok, result}
  end
end

defmodule Q do
  defmodule ParamsMissingError do
     defexception message: "one of more SQL parameters are missing"
  end

  def new(text, params \\ %{}) do
    params = Mappable.to_map(params, keys: :strings)

    text
    |> Q.Exp.build(params)
    |> Q.Exp.verify!()
  end

  def append(exp, text, params \\ %{})
  def append(exp, nil, _params), do: exp
  def append(exp, "", _params), do: exp
  def append(exp, text, params) when is_list(exp) do
    exp ++ [new(text, params)]
  end
  def append(%Q.Exp{} = exp, text, params) do
    [exp, new(text, params)]
  end

  def execute(%Q.Exp{} = expression, dbname) do
    {:ok, sql, params, _} = Q.Exp.expand(expression)

    query(dbname, sql, params)
  end
  def execute(expressions, dbname) when is_list(expressions) do
    {:ok, sql, params, _} = Q.Exp.expand(expressions)

    query(dbname, sql, params)
  end

  def query(dbname, sql, params \\ [])
  def query(dbname, sql, %{} = params) do
    exp = Q.new(sql, params)
    execute(exp, dbname)
  end
  def query(dbname, sql, params) do
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

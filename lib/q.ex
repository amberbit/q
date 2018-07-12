defmodule Q do
  defmodule ParamsMissingError do
     defexception message: "one of more SQL parameters are missing"
  end

  def exp(text, params \\ %{}) do
    params = Mappable.to_map(params, keys: :strings)

    text
    |> Q.Exp.build(params)
    |> Q.Exp.verify!()
  end

  def add_exp(exp, text, params \\ %{})
  def add_exp(exp, text, params) when is_list(exp) do
    exp ++ [exp(text, params)]
  end
  def add_exp(%Q.Exp{} = exp, text, params) do
    [exp, exp(text, params)]
  end

  def expand(exp, index \\ 1)
  def expand(%Q.Exp{} = exp, index) do
    Q.Exp.expand(exp, index)
  end
  def expand(exp, index) when is_list(exp) do
    expanded_list = expand_list(exp, index)

    text = Enum.map(expanded_list, fn({:ok, text, _, _}) -> text end) |> Enum.join(" ")
    params = Enum.map(expanded_list, fn({:ok, _, params, _}) -> params end) |> List.flatten()

    {:ok, text, params, index + length(params)}
  end

  def expand_list([exp], index), do: [expand(exp, index)]
  def expand_list([exp | tail], index) do
    {:ok, text, params, next_index} = expand(exp, index)

    [{:ok, text, params, next_index}] ++ expand_list(tail, next_index)
  end

  def query(dbname, sql, params \\ [])
  def query(dbname, %Q.Exp{} = expression, []) do
    {:ok, sql, params, _} = Q.expand(expression)

    query(dbname, sql, params)
  end
  def query(dbname, expressions, []) when is_list(expressions) do
    {:ok, sql, params, _} = Q.expand(expressions)

    query(dbname, sql, params)
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

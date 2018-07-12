defmodule Q.Exp do
  defstruct text: nil, params: nil

  def build(text, params) do
    %Q.Exp{text: text, params: params}
  end

  def verify!(exp) do
    case all_params_given?(exp) do
      true ->
        exp
      _ ->
        raise Q.ParamsMissingError
    end
  end

  defp all_params_given?(exp) do
    ~r/\${([\w]+)}/
    |> Regex.scan(exp.text)
    |> Enum.map(fn([_, name]) -> name end)
    |> Enum.all?(fn(name) -> Map.get(exp.params, name) != nil end)
  end

  def expand(exp, index) do
    catches = ~r/\${([\w]+)}/ |> Regex.scan(exp.text)

    catches_with_index = Enum.with_index(catches, index)

    text = do_replace(exp.text, catches_with_index)
    params = Enum.map(catches, fn([_, name]) -> Map.get(exp.params, name) end)

    {:ok, text, params, index + length(params)}
  end

  defp do_replace(text, []), do: text
  defp do_replace(text, [{[pattern, _], num} | tail]) do
    String.replace(text, pattern, "$#{num}", global: false) |> do_replace(tail)
  end
end

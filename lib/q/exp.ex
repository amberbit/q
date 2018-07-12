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

  def expand(exp, index \\ 1)
  def expand(%Q.Exp{} = exp, index) do
    catches = ~r/\${([\w]+)}/ |> Regex.scan(exp.text)

    catches_with_index = Enum.with_index(catches, index)

    text = do_replace(exp.text, catches_with_index)
    params = Enum.map(catches, fn([_, name]) -> Map.get(exp.params, name) end)

    {:ok, text, params, index + length(params)}
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

  defp do_replace(text, []), do: text
  defp do_replace(text, [{[pattern, _], num} | tail]) do
    String.replace(text, pattern, "$#{num}", global: false) |> do_replace(tail)
  end
end

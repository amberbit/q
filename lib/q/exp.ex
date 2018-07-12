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
end

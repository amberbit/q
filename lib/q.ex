defmodule Q do
  @moduledoc """
  Documentation for `Q`.
  """

  import Ecto.Query, only: [from: 2]

  def all(query_or_source, filters \\ %{}, opts \\ [])

  def all(%Ecto.Query{} = source, filters, opts) do
    query = prepare_query(source, filters)
    find_repo().all(query, opts)
  end

  def all(source, filters, opts) when is_binary(source) or is_atom(source) do
    query = prepare_query(source, filters)
    find_repo().all(query, opts || [])
  end

  def one(query_or_source, filters_or_opts \\ nil, opts \\ [])

  def one(%Ecto.Query{} = source, filters, opts) do
    query = prepare_query(source, filters)
    find_repo().one(query, opts || [])
  end

  def one(source, filters, opts) when is_binary(source) or is_atom(source) do
    query = prepare_query(source, filters)
    find_repo().one(query, opts || [])
  end

  defp prepare_query(source, filters) do
    filters =
      Mappable.to_list(filters || %{}, skip_unknown_atoms: true, warn_unknown_atoms: true)

    Enum.reduce(filters, source, fn
      {key, value}, query when not is_nil(value) ->
        from(o in query, where: field(o, ^key) == ^value)

      {key, nil}, query ->
        from(o in query, where: is_nil(field(o, ^key)))
    end)
  end

  defp find_repo() do
    Application.get_env(:q, :ecto_repo) ||
      raise "Ecto.Repo not set in config. Set :q, :ecto_repo in your config.exs:\n\nconfig :q, ecto_repo: MyApp.Repo"
  end
end

defmodule Q.Supervisor do
  use Supervisor

  def start_link([name: dbname], config \\ nil) do
    Supervisor.start_link(
      __MODULE__,
      [dbname: dbname, config: config || Application.get_env(:q, dbname)],
      name: :"#{dbname}.Supervisor"
    )
  end

  def init(dbname: dbname, config: config) do
    postgrex_config =
      config
      |> Keyword.put(:pool, DBConnection.Poolboy)
      |> Keyword.put(:pool_size, config[:pool_size] || 10)

    children = [
      {Postgrex, Keyword.put(postgrex_config, :name, :"#{dbname}.Pool")}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def child_spec(name: name) do
    %{
      id: name,
      start: {__MODULE__, :start_link, [[name: name]]},
      restart: :permanent,
      shutdown: 5000,
      type: :supervisor
    }
  end
end

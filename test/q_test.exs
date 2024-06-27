defmodule QTest do
  use ExUnit.Case
  doctest Q
  import ExUnit.CaptureLog
  import Ecto.Query, only: [from: 2]

  require Logger

  defmodule FakeRepo do
    def all(query, opts \\ []) do
      Logger.info("FakeRepo.query called with: #{inspect(query)}, #{inspect(opts)}")
      []
    end

    def one(query, opts \\ []) do
      Logger.info("FakeRepo.one called with: #{inspect(query)}, #{inspect(opts)}")
      nil
    end
  end

  defmodule User do
    use Ecto.Schema

    schema "users" do
      field(:first_name, :string)
      field(:last_name, :string)
      field(:deleted_at, :utc_datetime)
    end
  end

  setup _tags do
    Application.put_env(:q, :ecto_repo, QTest.FakeRepo)
  end

  describe ".all/3" do
    test "should fail if repo is not set in config" do
      Application.put_env(:q, :ecto_repo, nil)

      assert_raise RuntimeError,
                   "Ecto.Repo not set in config. Set :q, :ecto_repo in your config.exs:\n\nconfig :q, ecto_repo: MyApp.Repo",
                   fn ->
                     Q.all(from(u in "user", where: u.age > 18))
                   end
    end

    test "should pass Ecto.Query to the repo if it was passed" do
      query = from(u in "user", where: u.age > 18)

      captured =
        capture_log(fn ->
          Q.all(query) == []
        end)

      assert String.contains?(
               captured,
               "FakeRepo.query called with: #Ecto.Query<from u0 in \"user\", where: u0.age > 18>, []"
             )
    end

    test "should pass options to repo when passed along the Ecto.Query" do
      query = from(u in "user", where: u.age > 18)

      captured =
        capture_log(fn ->
          Q.all(query, %{}, timeout: :infinity) == []
        end)

      assert String.contains?(
               captured,
               "FakeRepo.query called with: #Ecto.Query<from u0 in \"user\", where: u0.age > 18>, [timeout: :infinity]"
             )
    end

    test "should support schema as first argument, and accept filters and options" do
      captured =
        capture_log(fn ->
          Q.all(QTest.User) == []
        end)

      assert String.contains?(
               captured,
               "FakeRepo.query called with: QTest.User, []"
             )

      captured =
        capture_log(fn ->
          Q.all(QTest.User, %{"first_name" => "John", "deleted_at" => nil}) == []
        end)

      assert String.contains?(
               captured,
               "FakeRepo.query called with: #Ecto.Query<from u0 in QTest.User, where: is_nil(u0.deleted_at), where: u0.first_name == ^\"John\">, []"
             )

      captured =
        capture_log(fn ->
          Q.all(QTest.User, %{"first_name" => "John", "deleted_at" => nil}, timeout: :infinity) ==
            []
        end)

      assert String.contains?(
               captured,
               "FakeRepo.query called with: #Ecto.Query<from u0 in QTest.User, where: is_nil(u0.deleted_at), where: u0.first_name == ^\"John\">, [timeout: :infinity]"
             )
    end
  end

  describe ".one/3" do
    test "should fail if repo is not set in config" do
      Application.put_env(:q, :ecto_repo, nil)

      assert_raise RuntimeError,
                   "Ecto.Repo not set in config. Set :q, :ecto_repo in your config.exs:\n\nconfig :q, ecto_repo: MyApp.Repo",
                   fn ->
                     Q.one(from(u in "user", where: u.age > 18))
                   end
    end

    test "should pass Ecto.Query to the repo if it was passed" do
      query = from(u in "user", where: u.age > 18)

      captured =
        capture_log(fn ->
          Q.one(query) == nil
        end)

      assert String.contains?(
               captured,
               "FakeRepo.one called with: #Ecto.Query<from u0 in \"user\", where: u0.age > 18>, []"
             )
    end

    test "should pass options to repo when passed along the Ecto.Query" do
      query = from(u in "user", where: u.age > 18)

      captured =
        capture_log(fn ->
          Q.one(query, [], timeout: :infinity) == nil
        end)

      assert String.contains?(
               captured,
               "FakeRepo.one called with: #Ecto.Query<from u0 in \"user\", where: u0.age > 18>, [timeout: :infinity]"
             )
    end

    test "should support schema as first argument, and accept filters and options" do
      captured =
        capture_log(fn ->
          Q.one(QTest.User) == nil
        end)

      assert String.contains?(
               captured,
               "FakeRepo.one called with: QTest.User, []"
             )

      captured =
        capture_log(fn ->
          Q.one(QTest.User, %{"first_name" => "John", "deleted_at" => nil}) == nil
        end)

      assert String.contains?(
               captured,
               "FakeRepo.one called with: #Ecto.Query<from u0 in QTest.User, where: is_nil(u0.deleted_at), where: u0.first_name == ^\"John\">, []"
             )

      captured =
        capture_log(fn ->
          Q.one(QTest.User, %{"first_name" => "John", "deleted_at" => nil}, timeout: :infinity) ==
            nil
        end)

      assert String.contains?(
               captured,
               "FakeRepo.one called with: #Ecto.Query<from u0 in QTest.User, where: is_nil(u0.deleted_at), where: u0.first_name == ^\"John\">, [timeout: :infinity]"
             )
    end
  end
end

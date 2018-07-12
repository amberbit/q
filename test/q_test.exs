defmodule QTest do
  use ExUnit.Case
  doctest Q

  describe "exp/2" do
    test "should build expression with empty params if none provided" do
      expression = Q.exp("SELECT * FROM users")
      assert expression.text == "SELECT * FROM users"
      assert expression.params == %{}

      expression = Q.exp("SELECT * FROM users", [])
      assert expression.text == "SELECT * FROM users"
      assert expression.params == %{}

      expression = Q.exp("SELECT * FROM users", %{})
      assert expression.text == "SELECT * FROM users"
      assert expression.params == %{}
    end

    test "should build simple expressions with params passed as keywrod list" do
      expression = Q.exp("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", id: 1, name: "Hubert")

      assert expression.text == "SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10"
      assert expression.params == %{"id" => 1, "name" => "Hubert"}
    end

    test "should build simple expressions with params passed as map with atoms" do
      expression = Q.exp("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", %{id: 1, name: "Hubert"})

      assert expression.text == "SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10"
      assert expression.params == %{"id" => 1, "name" => "Hubert"}
    end

    test "should build simple expressions with params passed as map with strings" do
      expression = Q.exp("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", %{"id" => 1, "name" => "Hubert"})

      assert expression.text == "SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10"
      assert expression.params == %{"id" => 1, "name" => "Hubert"}
    end

    test "should raise if the passed params do not satisfy requirements in expression" do
      assert_raise Q.ParamsMissingError, fn ->
        Q.exp("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", %{"id" => 1})
      end
    end
  end
end

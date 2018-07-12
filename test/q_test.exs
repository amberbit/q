defmodule QTest do
  use ExUnit.Case
  doctest Q

  describe "exp/2" do
    test "should build expression with empty params if none provided" do
      expression = Q.new("SELECT * FROM users")
      assert expression.text == "SELECT * FROM users"
      assert expression.params == %{}

      expression = Q.new("SELECT * FROM users", [])
      assert expression.text == "SELECT * FROM users"
      assert expression.params == %{}

      expression = Q.new("SELECT * FROM users", %{})
      assert expression.text == "SELECT * FROM users"
      assert expression.params == %{}
    end

    test "should build simple expressions with params passed as keywrod list" do
      expression = Q.new("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", id: 1, name: "Hubert")

      assert expression.text == "SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10"
      assert expression.params == %{"id" => 1, "name" => "Hubert"}
    end

    test "should build simple expressions with params passed as map with atoms" do
      expression = Q.new("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", %{id: 1, name: "Hubert"})

      assert expression.text == "SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10"
      assert expression.params == %{"id" => 1, "name" => "Hubert"}
    end

    test "should build simple expressions with params passed as map with strings" do
      expression = Q.new("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", %{"id" => 1, "name" => "Hubert"})

      assert expression.text == "SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10"
      assert expression.params == %{"id" => 1, "name" => "Hubert"}
    end

    test "should raise if the passed params do not satisfy requirements in expression" do
      assert_raise Q.ParamsMissingError, fn ->
        Q.new("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", %{"id" => 1})
      end
    end
  end

  describe ".add_exp/3" do
    test "adds expression to existing expression creating a list" do
      list = Q.new("SELECT * FROM users")
      |> Q.append("WHERE id = ${id}", id: 1)

      assert list == [
        %Q.Exp{text: "SELECT * FROM users", params: %{}},
        %Q.Exp{text: "WHERE id = ${id}", params: %{"id" => 1}}
      ]
    end


    test "adds expression to existing list of expressions" do
      list = [
        %Q.Exp{text: "SELECT * FROM users", params: %{}},
        %Q.Exp{text: "WHERE id = ${id}", params: %{"id" => 1}}
      ]

      new_list = list |> Q.append("LIMIT 1")

      assert new_list == [
        %Q.Exp{text: "SELECT * FROM users", params: %{}},
        %Q.Exp{text: "WHERE id = ${id}", params: %{"id" => 1}},
        %Q.Exp{text: "LIMIT 1", params: %{}}
      ]
    end
  end
end

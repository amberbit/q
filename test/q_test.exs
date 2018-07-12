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

  describe ".add_exp/3" do
    test "adds expression to existing expression creating a list" do
      list = Q.exp("SELECT * FROM users")
      |> Q.add_exp("WHERE id = ${id}", id: 1)

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

      new_list = list |> Q.add_exp("LIMIT 1")

      assert new_list == [
        %Q.Exp{text: "SELECT * FROM users", params: %{}},
        %Q.Exp{text: "WHERE id = ${id}", params: %{"id" => 1}},
        %Q.Exp{text: "LIMIT 1", params: %{}}
      ]
    end
  end

  describe ".expand/2" do
    test "expands simple singular query giving parameters indexes starting with 1 by default" do
      expression = Q.exp("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", id: 1, name: "Hubert")

      assert Q.expand(expression) == {:ok, "SELECT * FROM users WHERE id = $1 AND name = $2 AND $3 > 10", [1, "Hubert", 1], 4}
    end

    test "expands simple singular query giving parameters indexes starting with given index" do
      expression = Q.exp("AND email = ${email}", email: "hubert.lepicki@amberbit.com")

      assert Q.expand(expression, 4) == {:ok, "AND email = $4", ["hubert.lepicki@amberbit.com"], 5}
    end

    test "expands a list of expressions" do
      expression1 = Q.exp("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", id: 1, name: "Hubert")
      expression2 = Q.exp("AND email = ${email}", email: "hubert.lepicki@amberbit.com")

      assert Q.expand([expression1, expression2]) ==
        {:ok, "SELECT * FROM users WHERE id = $1 AND name = $2 AND $3 > 10 AND email = $4", [1, "Hubert", 1, "hubert.lepicki@amberbit.com"], 5}
    end
  end
end

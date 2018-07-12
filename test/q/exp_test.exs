defmodule Q.ExpTest do
  use ExUnit.Case
  doctest Q.Exp

  describe ".expand/2" do
    test "expands simple singular query giving parameters indexes starting with 1 by default" do
      expression = Q.new("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", id: 1, name: "Hubert")

      assert Q.Exp.expand(expression) == {:ok, "SELECT * FROM users WHERE id = $1 AND name = $2 AND $3 > 10", [1, "Hubert", 1], 4}
    end

    test "expands simple singular query giving parameters indexes starting with given index" do
      expression = Q.new("AND email = ${email}", email: "hubert.lepicki@amberbit.com")

      assert Q.Exp.expand(expression, 4) == {:ok, "AND email = $4", ["hubert.lepicki@amberbit.com"], 5}
    end

    test "expands a list of expressions" do
      expression1 = Q.new("SELECT * FROM users WHERE id = ${id} AND name = ${name} AND ${id} > 10", id: 1, name: "Hubert")
      expression2 = Q.new("AND email = ${email}", email: "hubert.lepicki@amberbit.com")

      assert Q.Exp.expand([expression1, expression2]) ==
        {:ok, "SELECT * FROM users WHERE id = $1 AND name = $2 AND $3 > 10 AND email = $4", [1, "Hubert", 1, "hubert.lepicki@amberbit.com"], 5}
    end
  end

end

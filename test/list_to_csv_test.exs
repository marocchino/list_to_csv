defmodule ListToCsvTest do
  @moduledoc """
    test of ListToCsv
  """
  use ExUnit.Case, async: true
  doctest ListToCsv

  defmodule Post do
    @moduledoc """
      for struct test
    """
    defstruct name: "name", child: nil
  end

  test ".parse_rows/2" do
    assert [["true", "1", "false"]] ==
             ListToCsv.parse_rows([%{a: 1, b: true, c: %{d: false}}], [:b, :a, [:c, :d]])
  end

  test ".parse_row/2" do
    assert ["true", "1", "false"] ==
             ListToCsv.parse_row(%{a: 1, b: true, c: %{d: false}}, [:b, :a, [:c, :d]])
  end

  describe ".parse_cell/2" do
    test "against nil" do
      assert "" == ListToCsv.parse_cell(nil, 1)
      assert "" == ListToCsv.parse_cell(nil, :a)
      assert "" == ListToCsv.parse_cell(nil, "a")
      assert "" == ListToCsv.parse_cell(nil, & &1)
      assert "" == ListToCsv.parse_cell(nil, [1, 2])
      assert "" == ListToCsv.parse_cell(nil, [:a, :b])
      assert "" == ListToCsv.parse_cell(nil, ["a", "b"])
      assert "" == ListToCsv.parse_cell(nil, [& &1, & &1])
    end

    test "against map" do
      assert "1" == ListToCsv.parse_cell(%{a: 1}, :a)
      assert "" == ListToCsv.parse_cell(%{a: 1}, :b)
      assert "1" == ListToCsv.parse_cell(%{"a" => 1}, "a")
      assert "" == ListToCsv.parse_cell(%{"a" => 1}, "b")
      assert "false" == ListToCsv.parse_cell(%{c: %{d: false}}, [:c, :d])
      assert "20" == ListToCsv.parse_cell(%{c: %{d: 4, e: 5}}, [:c, &(&1.d * &1.e)])
      assert "22" == ListToCsv.parse_cell(%{c: %{d: 4, e: 5}}, [:c, &(&1.d * &1.e), &(&1 + 2)])
    end

    test "against keyword" do
      assert "1" == ListToCsv.parse_cell([a: 1], :a)
      assert "" == ListToCsv.parse_cell([a: 1], :b)
      assert "false" == ListToCsv.parse_cell([c: [d: false]], [:c, :d])
      assert "22" == ListToCsv.parse_cell([c: [d: 4, e: 5]], [:c, &(&1[:d] * &1[:e]), &(&1 + 2)])
    end

    test "against list" do
      assert "1" == ListToCsv.parse_cell([1, 2, 3], 1)
      assert "" == ListToCsv.parse_cell([1, 2, 3], 4)
      assert "false" == ListToCsv.parse_cell(%{c: [%{d: false}]}, [:c, 1, :d])
      assert "" == ListToCsv.parse_cell(%{c: [%{d: false}]}, [:c, 2, :d])
      assert "false" == ListToCsv.parse_cell([c: [[d: false]]], [:c, 1, :d])
      assert "false" == ListToCsv.parse_cell(%{c: %{d: [false]}}, [:c, :d, 1])
      assert "false" == ListToCsv.parse_cell(%{c: [%{d: [false]}]}, [:c, 1, :d, 1])
      assert "" == ListToCsv.parse_cell(%{c: [%{d: [false]}]}, [:c, 2, :d, 2])
      assert "false" == ListToCsv.parse_cell(%{c: [%{d: [false]}]}, [:c, 1, :d, &hd/1])
    end

    test "against tuple" do
      assert "1" == ListToCsv.parse_cell({1, 2, 3}, 1)
      assert "" == ListToCsv.parse_cell({1, 2, 3}, 4)
      assert "false" == ListToCsv.parse_cell([c: {[d: false]}], [:c, 1, :d])
      assert "false" == ListToCsv.parse_cell(%{c: %{d: {false}}}, [:c, :d, 1])
      assert "false" == ListToCsv.parse_cell(%{c: [%{d: {false}}]}, [:c, 1, :d, 1])
      assert "" == ListToCsv.parse_cell(%{c: {%{d: {false}}}}, [:c, 2, :d, 2])
      assert "false" == ListToCsv.parse_cell(%{c: [%{d: {false}}]}, [:c, 1, :d, &elem(&1, 0)])
    end

    test "against struct" do
      assert "name" == ListToCsv.parse_cell(%Post{}, :name)
      assert "" == ListToCsv.parse_cell(%Post{}, :age)
      assert "name" == ListToCsv.parse_cell(%Post{child: %Post{}}, [:child, :name])
      assert "name" == ListToCsv.parse_cell(%Post{child: [%Post{}]}, [:child, 1, :name])

      assert "namename" ==
               ListToCsv.parse_cell(%Post{child: [%Post{}]}, [
                 :child,
                 1,
                 &String.duplicate(&1.name, 2)
               ])
    end
  end
end

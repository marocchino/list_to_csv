defmodule ListToCsvTest do
  use ExUnit.Case, async: true
  doctest ListToCsv

  defmodule Post do
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

  test ".parse_cell/2" do
    assert "1" == ListToCsv.parse_cell(%{a: 1}, :a)
    assert "1" == ListToCsv.parse_cell([a: 1], :a)
    assert "name" == ListToCsv.parse_cell(%Post{}, :name)
    assert "1" == ListToCsv.parse_cell(%{"a" => 1}, "a")
    assert "false" == ListToCsv.parse_cell(%{c: %{d: false}}, [:c, :d])
    assert "false" == ListToCsv.parse_cell([c: [d: false]], [:c, :d])
    assert "name" == ListToCsv.parse_cell(%Post{child: %Post{}}, [:child, :name])
    assert "false" == ListToCsv.parse_cell(%{c: [%{d: false}]}, [:c, 1, :d])
    assert "false" == ListToCsv.parse_cell([c: [[d: false]]], [:c, 1, :d])
    assert "name" == ListToCsv.parse_cell(%Post{child: [%Post{}]}, [:child, 1, :name])
    assert "" == ListToCsv.parse_cell(%{c: [%{d: false}]}, [:c, 2, :d])
    assert "false" == ListToCsv.parse_cell(%{c: %{d: [false]}}, [:c, :d, 1])
    assert "false" == ListToCsv.parse_cell(%{c: [%{d: [false]}]}, [:c, 1, :d, 1])
    assert "" == ListToCsv.parse_cell(%{c: [%{d: [false]}]}, [:c, 2, :d, 2])
    assert "20" == ListToCsv.parse_cell(%{c: %{d: 4, e: 5}}, [:c, &(&1.d * &1.e)])
    assert "22" == ListToCsv.parse_cell(%{c: %{d: 4, e: 5}}, [:c, &(&1.d * &1.e), &(&1 + 2)])
  end
end

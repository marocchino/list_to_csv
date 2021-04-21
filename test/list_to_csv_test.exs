defmodule ListToCsvTest do
  use ExUnit.Case, async: true
  doctest ListToCsv

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
    assert "1" == ListToCsv.parse_cell(%{"a" => 1}, "a")
    assert "false" == ListToCsv.parse_cell(%{c: %{d: false}}, [:c, :d])
    assert "false" == ListToCsv.parse_cell(%{c: [%{d: false}]}, [:c, 1, :d])
    assert "" == ListToCsv.parse_cell(%{c: [%{d: false}]}, [:c, 2, :d])
    assert "false" == ListToCsv.parse_cell(%{c: %{d: [false]}}, [:c, :d, 1])
    assert "false" == ListToCsv.parse_cell(%{c: [%{d: [false]}]}, [:c, 1, :d, 1])
    assert "" == ListToCsv.parse_cell(%{c: [%{d: [false]}]}, [:c, 2, :d, 2])
    assert "20" == ListToCsv.parse_cell(%{c: %{d: 4, e: 5}}, [:c, &(&1.d * &1.e)])
  end
end

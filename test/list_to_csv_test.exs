defmodule ListToCsvTest do
  use ExUnit.Case, async: true
  doctest ListToCsv

  test ".parse/2" do
    assert [
             [
               "名前",
               "アイテム1名",
               "アイテム1コード",
               "アイテム2名",
               "アイテム2コード",
               "アイテム3名",
               "アイテム3コード",
               "アイテム4名",
               "アイテム4コード",
               "item overflow?"
             ],
             ["name1", "title1", "code1", "title2", "code2", "title3", "code3", "", "", "false"],
             [
               "name2",
               "title4",
               "code4",
               "title5",
               "code5",
               "title6",
               "code6",
               "title7",
               "code7",
               "true"
             ]
           ] ==
             ListToCsv.parse(
               [
                 %{
                   name: "name1",
                   items: [
                     %{title: "title1", code: "code1"},
                     %{title: "title2", code: "code2"},
                     %{title: "title3", code: "code3"}
                   ]
                 },
                 %{
                   name: "name2",
                   items: [
                     %{title: "title4", code: "code4"},
                     %{title: "title5", code: "code5"},
                     %{title: "title6", code: "code6"},
                     %{title: "title7", code: "code7"},
                     %{title: "title8", code: "code8"}
                   ]
                 }
               ],
               header: [
                 {"名前", :name},
                 {"アイテム#名", [:items, :N, :title]},
                 {"アイテム#コード", [:items, :N, :code]},
                 {"item overflow?", [:items, &(length(&1) > 4)]}
               ],
               length: [items: 4]
             )
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

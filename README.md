# ListToCsv

Convert list of nested map to two dimensional list of strings.

## Example

```ex
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
]
|> ListToCsv.parse(header: [
  {"名前", :name},                                # simple get
  {"アイテム#名", [:items, :N, :title]}           # nested
  {"アイテム#コード", [:items, :N, :code]},
  {"item overflow?", [:items, &(length(&1) > 4)]} # function
], length: [items: 4])
=> [
  ["名前", "アイテム1名", "アイテム1コード", "アイテム2名",
   "アイテム2コード", "アイテム3名", "アイテム3コード",
   "アイテム4名", "アイテム4コード", "item overflow?"],
  ["name1", "title1", "code1", "title2", "code2", "title3", "code3", "", "",
   "false"],
  ["name2", "title4", "code4", "title5", "code5", "title6", "code6", "title7",
   "code7", "true"]
]
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `list_to_csv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:list_to_csv, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/list_to_csv](https://hexdocs.pm/list_to_csv).


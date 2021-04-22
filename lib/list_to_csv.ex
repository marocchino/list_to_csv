defmodule ListToCsv do
  @moduledoc """
  `ListToCsv` is main module of this library.
  """
  alias ListToCsv.Key
  alias ListToCsv.Option

  @type target() :: map() | struct() | keyword()

  @doc """
  Returns a list with header and body rows

  ## Options

  See `ListToCsv.Option` for details.

  - `:header` - (list({header, keys})) Required.
    Keys can be atoms, strings, numbers, or functions.
  - `:length` - (list({keys, length}) | nil) Optional.
    The length of the list can be variable, so if it is not fixed, the result
    value is not constant width.

  ## Examples

      iex> ListToCsv.parse(
      ...>   [
      ...>     %{
      ...>       name: "name1",
      ...>       items: [
      ...>         %{title: "title1", code: "code1"},
      ...>         %{title: "title2", code: "code2"},
      ...>         %{title: "title3", code: "code3"}
      ...>       ]
      ...>     },
      ...>     %{
      ...>       name: "name2",
      ...>       items: [
      ...>         %{title: "title4", code: "code4"},
      ...>         %{title: "title5", code: "code5"},
      ...>         %{title: "title6", code: "code6"},
      ...>         %{title: "title7", code: "code7"},
      ...>         %{title: "title8", code: "code8"}
      ...>       ]
      ...>     }
      ...>   ],
      ...>   header: [
      ...>     {"名前", :name},
      ...>     {"アイテム#名", [:items, :N, :title]},
      ...>     {"アイテム#コード", [:items, :N, :code]},
      ...>     {"item overflow?", [:items, &(length(&1) > 4)]}
      ...>   ],
      ...>   length: [items: 4]
      ...> )
      [
        ["名前", "アイテム1名", "アイテム1コード", "アイテム2名", "アイテム2コード", "アイテム3名", "アイテム3コード", "アイテム4名", "アイテム4コード", "item overflow?"],
        ["name1", "title1", "code1", "title2", "code2", "title3", "code3", "", "", "false"],
        ["name2", "title4", "code4", "title5", "code5", "title6", "code6", "title7", "code7", "true"]
      ]
  """
  @spec parse(list(target()), Option.t()) :: list(list(String.t()))
  def parse(list, options) do
    {header_list, keys_list} = Option.expand(options) |> Enum.unzip()
    [header_list | Enum.map(list, &parse_row(&1, keys_list))]
  end

  @spec parse_rows(list(target()), Key.many()) :: list(list(String.t()))
  def parse_rows(list, keys_list) do
    Enum.map(list, &parse_row(&1, keys_list))
  end

  @spec parse_row(target(), list(Key.many())) :: list(String.t())
  def parse_row(map, keys_list),
    do: Enum.map(keys_list, &parse_cell(map, &1))

  @spec parse_cell(any(), Key.many()) :: String.t()
  def parse_cell(map, key) when not is_list(key), do: parse_cell(map, [key])

  def parse_cell(list, [key | rest]) when is_integer(key) do
    List.pop_at(list || [], key - 1)
    |> elem(0)
    |> parse_cell(rest)
  end

  def parse_cell(map, [key | rest]) when is_function(key), do: parse_cell(key.(map), rest)
  def parse_cell(map, [key | rest]) when is_struct(map), do: parse_cell(Map.get(map, key), rest)
  def parse_cell(map, [key | rest]), do: parse_cell(map[key], rest)
  def parse_cell(map, []), do: "#{map}"
end

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

  - `:headers` - (list(string)) Optional.
  - `:Keys` - (list(Key.many())) Required.
    Keys can be atoms, strings, numbers, or functions.
  - `:length` - (list({Key.many(), length}) | nil) Optional.
    The length of the list can be variable, so if it is not fixed, the result
    value is not constant width.

  ## Examples

      iex> ListToCsv.parse([%{name: "bob"}], headers: ["name"], keys: [:name])
      [["name"], ["bob"]]

      iex> ListToCsv.parse([%{name: "bob"}], keys: [:name])
      [["bob"]]

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
      ...>   headers: [
      ...>     "名前",
      ...>     "アイテム#名",
      ...>     "アイテム#コード",
      ...>     "item overflow?"
      ...>   ],
      ...>   keys: [
      ...>     :name,
      ...>     [:items, :N, :title],
      ...>     [:items, :N, :code],
      ...>     [:items, &(length(&1) > 4)]
      ...>   ],
      ...>   length: [items: 4]
      ...> )
      [
        ["名前", "アイテム1名", "アイテム1コード", "アイテム2名", "アイテム2コード", "アイテム3名", "アイテム3コード", "アイテム4名", "アイテム4コード", "item overflow?"],
        ["name1", "title1", "code1", "title2", "code2", "title3", "code3", "", "", "false"],
        ["name2", "title4", "code4", "title5", "code5", "title6", "code6", "title7", "code7", "true"]
      ]

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
      ...>   keys: [
      ...>     :name,
      ...>     [:items, :N, :title],
      ...>     [:items, :N, :code],
      ...>     [:items, &(length(&1) > 4)]
      ...>   ],
      ...>   length: [items: 4]
      ...> )
      [
        ["name1", "title1", "code1", "title2", "code2", "title3", "code3", "", "", "false"],
        ["name2", "title4", "code4", "title5", "code5", "title6", "code6", "title7", "code7", "true"]
      ]
  """
  @spec parse(list(target()), Option.t()) :: list(list(String.t()))
  def parse(list, options) do
    case options[:headers] do
      nil ->
        parse_rows(list, Option.expand(options))

      _ ->
        {header_list, keys_list} = Option.expand(options) |> Enum.unzip()
        [header_list | parse_rows(list, keys_list)]
    end
  end

  @spec parse_rows(list(target()), Key.many()) :: list(list(String.t()))
  def parse_rows(list, keys_list), do: Enum.map(list, &parse_row(&1, keys_list))

  @spec parse_row(target(), list(Key.many())) :: list(String.t())
  def parse_row(map, keys_list), do: Enum.map(keys_list, &parse_cell(map, &1))

  @spec parse_cell(any(), Key.many()) :: String.t()
  def parse_cell(map, key), do: "#{get(map, key)}"

  @spec get(any(), Key.many()) :: any()
  def get(map, key) when not is_list(key), do: get(map, [key])

  def get(map, [{fun, keys} | rest]) when is_function(fun) and is_list(keys) do
    apply(fun, Enum.map(keys, &get(map, &1))) |> get(rest)
  end

  def get(tuple, [key | rest]) when is_integer(key) and is_tuple(tuple) do
    elem(tuple, key - 1) |> get(rest)
  rescue
    ArgumentError -> nil |> get(rest)
  end

  def get(list, [key | rest]) when is_integer(key) do
    List.pop_at(list || [], key - 1) |> elem(0) |> get(rest)
  end

  def get(map, [key | rest]) when is_function(key), do: get(key.(map), rest)
  def get(map, [key | rest]) when is_struct(map), do: get(Map.get(map, key), rest)
  def get(map, [key | rest]), do: get(map[key], rest)
  def get(map, []), do: map
end

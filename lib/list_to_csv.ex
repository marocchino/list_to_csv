defmodule ListToCsv do
  @moduledoc """
  Documentation for `ListToCsv`.
  """
  alias ListToCsv.Option

  @spec parse_rows(list(map()), Option.t()) :: list(list(String.t()))
  def parse_rows(list, options) do
    keys_list = Option.expends(options)
    Enum.map(list, &parse_row(&1, keys_list))
  end

  @spec parse_row(map(), list(Option.keys())) :: list(String.t())
  def parse_row(map, keys_list),
    do: Enum.map(keys_list, &parse_cell(map, &1))

  @spec parse_cell(any(), Option.keys()) :: String.t()
  def parse_cell(map, [key]), do: parse_cell(map, key)

  def parse_cell(list, [key | rest]) when is_integer(key) do
    List.pop_at(list || [], key)
    |> elem(0)
    |> parse_cell(rest)
  end

  def parse_cell(map, [key | rest]), do: parse_cell(map[key], rest)

  def parse_cell(map, key) when is_integer(key),
    do: "#{List.pop_at(map || [], key) |> elem(0)}"

  def parse_cell(map, key) when is_function(key), do: "#{key.(map)}"
  def parse_cell(map, key), do: "#{map[key]}"
end

defmodule ListToCsv.Header do
  @moduledoc """
    `ListToCsv.Header` contains types and utilities for headers.
  """

  @type t() :: String.t()

  @doc """
  Returns a list of header duplicated `n` times.
  Replace first # with current 1 base index.

  ## Examples

      iex> duplicate(["item#.name", "item#.size"], 2)
      ["item1.name", "item1.size", "item2.name", "item2.size"]

      iex> duplicate(["item#.package#"], 3)
      ["item1.package#", "item2.package#", "item3.package#"]
  """
  @spec duplicate(list(t()), integer()) :: list(t())
  def duplicate(headers, n) do
    Enum.flat_map(1..n, fn i ->
      Enum.map(headers, &String.replace(&1, "#", "#{i}", global: false))
    end)
  end
end

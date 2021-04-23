defmodule ListToCsv.Option do
  @moduledoc """
  `ListToCsv.Option` contains types and utilities for option.
  """
  alias ListToCsv.Header
  alias ListToCsv.Key

  @type t() :: [
          headers: list(Header.t()) | nil,
          keys: list(Key.many()),
          length: list({Key.many(), integer}) | nil
        ]

  @spec expand(t()) :: list({Header.t(), Key.many()} | Key.many())
  def expand(option) do
    headers = option[:headers]
    keys = option[:keys]
    length = option[:length]

    case {headers, length} do
      {nil, nil} ->
        keys

      {headers, nil} ->
        Enum.zip(headers, keys)

      {nil, length} ->
        Enum.reduce(length, keys, &do_expand/2)

      _ ->
        Enum.reduce(length, Enum.zip(headers, keys), &do_expand/2)
    end
  end

  @spec do_expand({Key.many(), integer()}, list({Header.t(), Key.many()} | Key.many())) ::
          list({Header.t(), Key.many()} | Key.many())
  def do_expand({keys, n}, headers) do
    matcher = &starts_with?(&1, Key.build_prefix(keys))

    case chunks(headers, matcher) do
      {prefix, body, []} ->
        Enum.concat(prefix, duplicate(body, n))

      {prefix, body, suffix} ->
        Enum.concat([prefix, duplicate(body, n), do_expand({keys, n}, suffix)])
    end
  end

  @spec duplicate(list({Header.t(), Key.many()} | Key.many()), integer()) ::
          list({Header.t(), Key.many()} | Key.many())
  def duplicate([{_, _} | _] = list, n) do
    {headers, keys} = Enum.unzip(list)

    Enum.zip(Header.duplicate(headers, n), Key.duplicate(keys, n))
  end

  @doc """
  Returns `list` duplicated `n` times. And replace first `:N` with current 1 base index.

  ## Examples

      iex> duplicate([[:name, :N]], 2)
      [[:name, 1], [:name, 2]]

      iex> duplicate([{"name#", [:name, :N]}], 2)
      [{"name1", [:name, 1]}, {"name2", [:name, 2]}]

      iex> duplicate([[:name, :N, :item, :N]], 2)
      [[:name, 1, :item, :N], [:name, 2, :item, :N]]

      iex> duplicate([{"name#.item#", [:name, :N, :item, :N]}], 2)
      [{"name1.item#", [:name, 1, :item, :N]}, {"name2.item#", [:name, 2, :item, :N]}]
  """
  def duplicate(list, n), do: Key.duplicate(list, n)

  @doc """
  Returns `true` if `keys` starts with the given `prefix` list; otherwise returns
  `false`.

  Note that `:N` can match with `integer`.

  ## Examples

      iex> starts_with?(:name, [:item, :N])
      false

      iex> starts_with?({"name", :name}, [:item, :N])
      false

      iex> starts_with?([:item, :N, :name], [:item, :N])
      true

      iex> starts_with?({"item#.name", [:item, :N, :name]}, [:item, :N])
      true

      iex> starts_with?([:name], [:item, :N])
      false

      iex> starts_with?({"name", [:name]}, [:item, :N])
      false

      iex> starts_with?([:item, 1, :name, :N, :first], [:item, :N, :name, :N])
      true

      iex> starts_with?({"item1.name#.first", [:item, 1, :name, :N, :first]}, [:item, :N, :name, :N])
      true

      iex> starts_with?([:packages, :N, :name], [:item, :N])
      false

      iex> starts_with?({"package#.name", [:packages, :N, :name]}, [:item, :N])
      false
  """
  @spec starts_with?({Header.t(), Key.many()} | Key.many(), list(Key.t())) :: boolean
  def starts_with?({header, keys}, prefix) when is_binary(header),
    do: Key.starts_with?(keys, prefix)

  def starts_with?(keys, prefix), do: Key.starts_with?(keys, prefix)

  @doc """
  Split `list` 3 part with respect orders

  - 1st not matched with `fun`
  - 2nd matched with `fun`
  - 3rd not matched with `fun`

  ## Examples

      iex> chunks([1, 2, 3, 3, 2, 1, 3, 2], &(&1 == 3))
      {[1, 2], [3, 3], [2, 1, 3, 2]}

      iex> chunks([3, 2, 3, 2, 1, 3, 2], &(&1 == 3))
      {[], [3], [2, 3, 2, 1, 3, 2]}

      iex> chunks([1, 2, 4, 5, 2], &(&1 == 3))
      {[1, 2, 4, 5, 2], [], []}
  """
  @spec chunks(list(), function()) :: {list(), list(), list()}
  def chunks(list, fun) do
    {prefix, tail} = Enum.split_while(list, &(!fun.(&1)))
    {body, suffix} = Enum.split_while(tail, fun)
    {prefix, body, suffix}
  end
end

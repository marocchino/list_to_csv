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

  def duplicate([{_, _} | _] = list, n) do
    {headers, keys} = Enum.unzip(list)

    Enum.zip(Header.duplicate(headers, n), Key.duplicate(keys, n))
  end

  def duplicate(list, n), do: Key.duplicate(list, n)

  def starts_with?({_, keys}, prefix), do: Key.starts_with?(keys, prefix)
  def starts_with?(keys, prefix), do: Key.starts_with?(keys, prefix)

  @doc """
  split list 3 part with respect orders
  - 1st not matched with `fun`
  - 2nd matched with `fun`
  - 3rd not matched with `fun`

  ## Examples

      iex> chunks([1, 2, 3, 2, 1, 3, 2], &(&1 == 3))
      {[1, 2], [3], [2, 1, 3, 2]}
  """
  @spec chunks(list(), function()) :: {list(), list(), list()}
  def chunks(list, fun) do
    {prefix, tail} = Enum.split_while(list, &(!fun.(&1)))
    {body, suffix} = Enum.split_while(tail, fun)
    {prefix, body, suffix}
  end
end

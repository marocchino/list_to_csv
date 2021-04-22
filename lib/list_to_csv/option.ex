defmodule ListToCsv.Option do
  @moduledoc """
  `ListToCsv.Option` contains types and utilities for option.
  """
  alias ListToCsv.Header
  alias ListToCsv.Key

  @type t() :: [
          header: list({Header.t(), Key.many()}),
          length: list({Key.many(), integer}) | nil
        ]

  @spec expand(t()) :: list({Header.t(), Key.many()})
  def expand(header: header, length: length),
    do: Enum.reduce(length, header, &do_expand/2)

  def expand(header: header), do: header

  def do_expand({keys, n}, headers) do
    matcher = &starts_with?(&1, Key.build_prefix(keys))

    case Key.chunks(headers, matcher) do
      {prefix, body, []} ->
        Enum.concat(prefix, duplicate(body, n))

      {prefix, body, suffix} ->
        Enum.concat([prefix, duplicate(body, n), do_expand({keys, n}, suffix)])
    end
  end

  def duplicate(list, n) do
    {headers, keys} = Enum.unzip(list)

    Enum.zip(Header.duplicate(headers, n), Key.duplicate(keys, n))
  end

  def starts_with?({_, keys}, prefix) do
    Key.starts_with?(keys, prefix)
  end
end

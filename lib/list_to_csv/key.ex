defmodule ListToCsv.Key do
  @moduledoc """
    `ListToCsv.Key` contains types and utilities for keys.
  """
  @type t() :: String.t() | atom() | integer() | function()
  @type many() :: list(t()) | t() | {function(), many()}

  @doc """
  build prefix keys with trailing `:N`

  ## Examples

      iex> build_prefix(:name)
      [:name, :N]

      iex> build_prefix([:item, :name])
      [:item, :name, :N]
  """
  @spec build_prefix(many()) :: many()
  def build_prefix(keys), do: List.wrap(keys) ++ [:N]

  @doc """
  Returns a list of `keys` duplicated `n` times. And replace first `:N` with current 1 base index.

  ## Examples

      iex> duplicate([[:name, :N]], 2)
      [[:name, 1], [:name, 2]]

      iex> duplicate([[:name, :N, :item, :N]], 2)
      [[:name, 1, :item, :N], [:name, 2, :item, :N]]

      iex> duplicate([{&(&1 + &2), [[:item, :N, :quantity], :capacity]}], 2)
      [{&(&1 + &2), [[:item, 1, :quantity], :capacity]},
       {&(&1 + &2), [[:item, 2, :quantity], :capacity]}]
  """
  @spec duplicate(list(many()), integer()) :: list(many())
  def duplicate(keys, n) do
    Enum.flat_map(1..n, fn i ->
      Enum.map(keys, &replace_first(&1, :N, i))
    end)
  end

  @doc """
  Returns `true` if `keys` starts with the given `prefix` list; otherwise returns
  `false`.

  Note that `:N` can match with `integer`.

  ## Examples

      iex> starts_with?(:name, [:item, :N])
      false

      iex> starts_with?([:item, :N, :name], [:item, :N])
      true

      iex> starts_with?([:name], [:item, :N])
      false

      iex> starts_with?([:item, 1, :name, :N, :first], [:item, :N, :name, :N])
      true

      iex> starts_with?([:packages, :N, :name], [:item, :N])
      false

      iex> starts_with?({&(&1 + &2), [[:item, :N, :quantity], :capacity]}, [:item, :N])
      true
  """
  @spec starts_with?(many(), list(t())) :: boolean
  def starts_with?({fun, keys}, prefix) when is_function(fun) and is_list(keys) do
    Enum.any?(keys, &starts_with?(&1, prefix))
  end

  def starts_with?(keys, _prefix) when not is_list(keys), do: false
  def starts_with?(keys, prefix) when length(keys) < length(prefix), do: false

  def starts_with?(keys, prefix) do
    Enum.zip(prefix, keys)
    |> Enum.all?(fn
      {a, a} -> true
      {:N, n} when is_integer(n) -> true
      {_, _} -> false
    end)
  end

  @doc """
  Returns a new list created by replacing occurrences of `from` in `subject`
  with `to`. Only the first occurrence is replaced.

  ## Examples

      iex> replace_first(:item, :N, 1)
      :item

      iex> replace_first([:item], :N, 1)
      [:item]

      iex> replace_first([:item, :N, :name], :N, 1)
      [:item, 1, :name]

      iex> replace_first([:item, :N, :name, :N], :N, 2)
      [:item, 2, :name, :N]

      iex> replace_first({&(&1 + &2), [[:item, :N, :quantity], :capacity]}, :N, 3)
      {&(&1 + &2), [[:item, 3, :quantity], :capacity]}
  """
  @spec replace_first(list(t()), t(), t()) :: list(t())
  def replace_first([] = _subject, _from, _to), do: []
  def replace_first([from | tail], from, to), do: [to | tail]
  def replace_first([head | tail], from, to), do: [head | replace_first(tail, from, to)]

  def replace_first({fun, subjects}, from, to) when is_function(fun) do
    {fun, Enum.map(subjects, &replace_first(&1, from, to))}
  end

  def replace_first(subject, _from, _to), do: subject
end

defmodule ListToCsv.Option do
  @type key() :: String.t() | atom | integer | function
  @type keys() :: list(key()) | key()
  @type t() :: %{
          header: list({String.t(), keys}),
          length: list({keys(), integer}) | nil
        }

  @spec expends(t()) :: list({String.t(), keys()})
  def expends(options) do
    Enum.reduce(options[:length] || [], options[:header], fn {keys, n}, acc ->
      expends_header(acc, keys, n)
    end)
  end

  def expends_header(headers, keys, n) do
    keys_with_n = List.wrap(keys) ++ [:N]

    case chunks(headers, fn {_, k} -> match_keys?(List.wrap(k), keys_with_n) end) do
      {prefix, body, []} ->
        prefix ++ duplicate(body, n)

      {prefix, body, suffix} ->
        prefix ++
          duplicate(body, n) ++
          expends_header(suffix, keys, n)
    end
  end

  def duplicate(list, n) do
    Enum.flat_map(1..n, fn i ->
      Enum.map(list, fn {header, keys} ->
        {
          String.replace(header, "#", "#{i}", global: false),
          replace_first(keys, :N, i)
        }
      end)
    end)
  end

  def replace_first([], _from, _to), do: []
  def replace_first([from | tail], from, to), do: [to | tail]
  def replace_first([head | tail], from, to), do: [head | replace_first(tail, from, to)]

  def chunks(list, fun) do
    {prefix, tail} = Enum.split_while(list, &(!fun.(&1)))
    {body, suffix} = Enum.split_while(tail, fun)
    {prefix, body, suffix}
  end

  @spec match_keys?(list(key()), list(key())) :: boolean
  def match_keys?(keys, sub_keys) when length(keys) < length(sub_keys), do: false

  def match_keys?(keys, sub_keys) do
    Enum.zip(sub_keys, keys)
    |> Enum.all?(fn
      {a, a} -> true
      {:N, n} when is_integer(n) -> true
      {_, _} -> false
    end)
  end
end

defmodule ListToCsv.OptionTest do
  @moduledoc """
    test of ListToCsv.Option
  """
  use ExUnit.Case, async: true
  import ListToCsv.Option
  doctest ListToCsv.Option

  test "expand/1" do
    assert [{"name", :name}] == expand(headers: ["name"], keys: [:name])

    assert [:name] == expand(keys: [:name])

    fun = &(length(&1) > 3)

    assert [
             {"name", :name},
             {"item.1.name", [:goods, 1, :name]},
             {"item.1.quantity", {&(&1 + &2), [[:goods, 1, :quantity], :capacity]}},
             {"item.1.description", [:goods, 1, :description]},
             {"item.1.color.1.name", [:goods, 1, :color, 1, :name]},
             {"item.1.color.1.code", [:goods, 1, :color, 1, :code]},
             {"item.1.color.2.name", [:goods, 1, :color, 2, :name]},
             {"item.1.color.2.code", [:goods, 1, :color, 2, :code]},
             {"item.1.color.overflow?", [:goods, 1, :color, fun]},
             {"item.2.name", [:goods, 2, :name]},
             {"item.2.quantity", {&(&1 + &2), [[:goods, 2, :quantity], :capacity]}},
             {"item.2.description", [:goods, 2, :description]},
             {"item.2.color.1.name", [:goods, 2, :color, 1, :name]},
             {"item.2.color.1.code", [:goods, 2, :color, 1, :code]},
             {"item.2.color.2.name", [:goods, 2, :color, 2, :name]},
             {"item.2.color.2.code", [:goods, 2, :color, 2, :code]},
             {"item.2.color.overflow?", [:goods, 2, :color, fun]},
             {"item.3.name", [:goods, 3, :name]},
             {"item.3.quantity", {&(&1 + &2), [[:goods, 3, :quantity], :capacity]}},
             {"item.3.description", [:goods, 3, :description]},
             {"item.3.color.1.name", [:goods, 3, :color, 1, :name]},
             {"item.3.color.1.code", [:goods, 3, :color, 1, :code]},
             {"item.3.color.2.name", [:goods, 3, :color, 2, :name]},
             {"item.3.color.2.code", [:goods, 3, :color, 2, :code]},
             {"item.3.color.overflow?", [:goods, 3, :color, fun]},
             {"item.overflow?", [:goods, fun]},
             {"package.1.weight", [:packages, 1, :weight]},
             {"package.2.weight", [:packages, 2, :weight]}
           ] ==
             expand(
               headers: [
                 "name",
                 "item.#.name",
                 "item.#.quantity",
                 "item.#.description",
                 "item.#.color.#.name",
                 "item.#.color.#.code",
                 "item.#.color.overflow?",
                 "item.overflow?",
                 "package.#.weight"
               ],
               keys: [
                 :name,
                 [:goods, :N, :name],
                 {&(&1 + &2), [[:goods, :N, :quantity], :capacity]},
                 [:goods, :N, :description],
                 [:goods, :N, :color, :N, :name],
                 [:goods, :N, :color, :N, :code],
                 [:goods, :N, :color, fun],
                 [:goods, fun],
                 [:packages, :N, :weight]
               ],
               length: [
                 {:goods, 3},
                 {:packages, 2},
                 {[:goods, :N, :color], 2}
               ]
             )

    assert [
             :name,
             [:goods, 1, :name],
             [:goods, 1, :description],
             [:goods, 1, :color, 1, :name],
             [:goods, 1, :color, 1, :code],
             [:goods, 1, :color, 2, :name],
             [:goods, 1, :color, 2, :code],
             [:goods, 1, :color, fun],
             [:goods, 2, :name],
             [:goods, 2, :description],
             [:goods, 2, :color, 1, :name],
             [:goods, 2, :color, 1, :code],
             [:goods, 2, :color, 2, :name],
             [:goods, 2, :color, 2, :code],
             [:goods, 2, :color, fun],
             [:goods, 3, :name],
             [:goods, 3, :description],
             [:goods, 3, :color, 1, :name],
             [:goods, 3, :color, 1, :code],
             [:goods, 3, :color, 2, :name],
             [:goods, 3, :color, 2, :code],
             [:goods, 3, :color, fun],
             [:goods, fun],
             [:packages, 1, :weight],
             [:packages, 2, :weight]
           ] ==
             expand(
               keys: [
                 :name,
                 [:goods, :N, :name],
                 [:goods, :N, :description],
                 [:goods, :N, :color, :N, :name],
                 [:goods, :N, :color, :N, :code],
                 [:goods, :N, :color, fun],
                 [:goods, fun],
                 [:packages, :N, :weight]
               ],
               length: [
                 {:goods, 3},
                 {:packages, 2},
                 {[:goods, :N, :color], 2}
               ]
             )
  end

  test "do_expand/2" do
    fun = &(length(&1) > 3)

    assert [
             {"id", :id},
             {"item.1.name", [:goods, 1, :name]},
             {"item.1.description", [:goods, 1, :description]},
             {"item.2.name", [:goods, 2, :name]},
             {"item.2.description", [:goods, 2, :description]},
             {"item.3.name", [:goods, 3, :name]},
             {"item.3.description", [:goods, 3, :description]},
             {"item.overflow?", [:goods, fun]}
           ] ==
             do_expand(
               {:goods, 3},
               [
                 {"id", :id},
                 {"item.#.name", [:goods, :N, :name]},
                 {"item.#.description", [:goods, :N, :description]},
                 {"item.overflow?", [:goods, fun]}
               ]
             )

    assert [
             :id,
             [:goods, 1, :name],
             [:goods, 1, :description],
             [:goods, 2, :name],
             [:goods, 2, :description],
             [:goods, 3, :name],
             [:goods, 3, :description],
             [:goods, fun]
           ] ==
             do_expand(
               {:goods, 3},
               [
                 :id,
                 [:goods, :N, :name],
                 [:goods, :N, :description],
                 [:goods, fun]
               ]
             )
  end
end

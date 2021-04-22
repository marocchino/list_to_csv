defmodule ListToCsv.OptionTest do
  @moduledoc """
    test of ListToCsv.Option
  """
  use ExUnit.Case, async: true
  import ListToCsv.Option
  doctest ListToCsv.Option

  test "expand/1" do
    assert [{"name", :name}] == expand(header: [{"name", :name}])

    fun = &(length(&1) > 3)

    assert [
             {"name", :name},
             {"item.1.name", [:goods, 1, :name]},
             {"item.1.description", [:goods, 1, :description]},
             {"item.1.color.1.name", [:goods, 1, :color, 1, :name]},
             {"item.1.color.1.code", [:goods, 1, :color, 1, :code]},
             {"item.1.color.2.name", [:goods, 1, :color, 2, :name]},
             {"item.1.color.2.code", [:goods, 1, :color, 2, :code]},
             {"item.1.color.overflow?", [:goods, 1, :color, fun]},
             {"item.2.name", [:goods, 2, :name]},
             {"item.2.description", [:goods, 2, :description]},
             {"item.2.color.1.name", [:goods, 2, :color, 1, :name]},
             {"item.2.color.1.code", [:goods, 2, :color, 1, :code]},
             {"item.2.color.2.name", [:goods, 2, :color, 2, :name]},
             {"item.2.color.2.code", [:goods, 2, :color, 2, :code]},
             {"item.2.color.overflow?", [:goods, 2, :color, fun]},
             {"item.3.name", [:goods, 3, :name]},
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
               header: [
                 {"name", :name},
                 {"item.#.name", [:goods, :N, :name]},
                 {"item.#.description", [:goods, :N, :description]},
                 {"item.#.color.#.name", [:goods, :N, :color, :N, :name]},
                 {"item.#.color.#.code", [:goods, :N, :color, :N, :code]},
                 {"item.#.color.overflow?", [:goods, :N, :color, fun]},
                 {"item.overflow?", [:goods, fun]},
                 {"package.#.weight", [:packages, :N, :weight]}
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
  end
end

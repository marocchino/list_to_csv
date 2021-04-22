defmodule ListToCsv.KeyTest do
  @moduledoc """
    test of ListToCsv.Key
  """
  use ExUnit.Case, async: true
  import ListToCsv.Key
  doctest ListToCsv.Key, import: true

  test "expand/2" do
    fun = &(length(&1) > 3)

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
               [
                 :name,
                 [:goods, :N, :name],
                 [:goods, :N, :description],
                 [:goods, :N, :color, :N, :name],
                 [:goods, :N, :color, :N, :code],
                 [:goods, :N, :color, fun],
                 [:goods, fun],
                 [:packages, :N, :weight]
               ],
               [
                 {:goods, 3},
                 {:packages, 2},
                 {[:goods, :N, :color], 2}
               ]
             )
  end

  test "do_expand/2" do
    fun = &(length(&1) > 3)

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

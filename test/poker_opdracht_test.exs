defmodule PokerOpdrachtTest do
  use ExUnit.Case
  doctest PokerOpdracht

  test "parse input correctly" do
    result = PokerOpdracht.parse_inputs("TD JH QC KS AH 3D 7H 6C 3S 2H")
    assert result == {["10D", "11H", "12C", "13S", "14H"], ["3D", "7H", "6C", "3S", "2H"]}
  end

  test "rank high card" do
    {black1, white1} = {["7S", "4S", "12D", "11D", "7D"], ["10D", "10D", "10H", "11C", "4C"]}
    {black2, white2} = {["11C", "2C", "6H", "3D", "4D"], ["6S", "10S", "8S", "8H", "12D"]}
    {black3, white3} = {["2D", "3D", "4C", "5D", "12D"], ["2H", "3H", "4H", "5S", "12S"]}

    assert Ranking.rank_high_card(black1, white1) == :black
    assert Ranking.rank_high_card(black2, white2) == :white
    assert Ranking.rank_high_card(black3, white3) == :tie
  end

  test "number of equal values" do
    full = ["10S", "10C", "6D", "10C", "6H"]
    two_pair = ["2S", "10C", "6D", "10C", "6H"]
    none = ["2S", "5C", "7D", "8C", "12H"]

    assert Ranking.number_of_equal_values(full) == {3, 2}
    assert Ranking.number_of_equal_values(two_pair) == {2, 2}
    assert Ranking.number_of_equal_values(none) == {1, 1}
  end

  test "number of consecutive values" do
    one_consec = ["2S", "5C", "8D", "10C", "12H"]
    two_consec_groups = ["2S", "3C", "6D", "7C", "8H"]
    straight = ["2S", "3C", "4D", "5C", "6H"]
    
    assert Ranking.number_of_consecutive_values(one_consec) == 1
    assert Ranking.number_of_consecutive_values(two_consec_groups) == 3
    assert Ranking.number_of_consecutive_values(straight) == 5
  end

  test "verify hand" do
    straight_flush = ["2S", "3S", "4S", "5S", "6S"]
    four_of_a_kind = ["2S", "2C", "2D", "2H", "6S"]
    full_house = ["2S", "2C", "6C", "6D", "6S"]
    flush = ["2S", "3S", "8S", "5S", "10S"]
    straight = ["2C", "3D", "4H", "5C", "6S"]
    three_of_a_kind = ["9S", "9C", "9D", "5H", "6S"]
    two_pairs = ["2S", "2C", "4S", "4H", "6S"]
    pair = ["2S", "2C", "9S", "5H", "6D"]
    high_card = ["2C", "5D", "8H", "10S", "11D"]

    assert Ranking.verify_hand(straight_flush) == :straight_flush
    assert Ranking.verify_hand(four_of_a_kind) == :four_of_a_kind
    assert Ranking.verify_hand(full_house) == :full_house
    assert Ranking.verify_hand(flush) == :flush
    assert Ranking.verify_hand(straight) == :straight
    assert Ranking.verify_hand(three_of_a_kind) == :three_of_a_kind
    assert Ranking.verify_hand(two_pairs) == :two_pairs
    assert Ranking.verify_hand(pair) == :pair
    assert Ranking.verify_hand(high_card) == :high_card
  end

end

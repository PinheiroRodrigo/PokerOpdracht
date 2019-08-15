defmodule PokerOpdrachtTest do
  use ExUnit.Case
  doctest PokerOpdracht

  test "parse input correctly" do
    result = PokerOpdracht.parse_inputs("2S 3S 4S 5S 6S 10D JH QC KS AD")
    assert result == {["2S", "3S", "4S", "5S", "6S"], ["10D", "11H", "12C", "13S", "14D"]}
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

    assert Ranking.highest_consecutive_group(one_consec) == 1
    assert Ranking.highest_consecutive_group(two_consec_groups) == 3
    assert Ranking.highest_consecutive_group(straight) == 5
  end

  test "untie by high card" do
    {black, white} = {["2H", "3D", "5S", "8C", "11D"], ["2C", "3H", "4S", "8S", "11H"]}
    {black2, white2} = {["2D", "3D", "4C", "5D", "12D"], ["2H", "3H", "4H", "5S", "12S"]}

    assert Ranking.verify_winner(black, white) == {:black, {:high_card, 5}}
    assert Ranking.verify_winner(black2, white2) == :tie
  end

  test "untie unique set" do
    {black, white} = {["2H", "2D", "5S", "5C", "5D"], ["9C", "9H", "3S", "3D", "3H"]}
    assert Ranking.verify_winner(black, white) == {:black, {:high_card, 5}}
  end

  test "untie pairs" do
    {black, white} = {["2H", "2D", "5S", "5C", "9D"], ["8C", "8H", "3S", "3D", "5H"]}
    {black2, white2} = {["3H", "3D", "5S", "5C", "8D"], ["3C", "3H", "5S", "5D", "13H"]}
    {black3, white3} = {["3H", "3D", "5S", "5C", "7D"], ["3C", "3H", "5S", "5D", "7H"]}
    assert Ranking.verify_winner(black, white) == {:white, {:high_card, 8}}
    assert Ranking.verify_winner(black2, white2) == {:white, {:high_card, 13}}
    assert Ranking.verify_winner(black3, white3) == :tie
  end

  test "verify hand" do
    straight_flush = get_set(:straight_flush)
    four_of_a_kind = get_set(:four_of_a_kind)
    full_house = get_set(:full_house)
    flush = get_set(:flush)
    straight = get_set(:straight)
    three_of_a_kind = get_set(:three_of_a_kind)
    two_pairs = get_set(:two_pairs)
    pair = get_set(:pair)
    high_card = get_set(:high_card)

    assert Ranking.verify_hand(straight_flush) == {:straight_flush, 9, straight_flush}
    assert Ranking.verify_hand(four_of_a_kind) == {:four_of_a_kind, 8, four_of_a_kind}
    assert Ranking.verify_hand(full_house) == {:full_house, 7, full_house}
    assert Ranking.verify_hand(flush) == {:flush, 6, flush}
    assert Ranking.verify_hand(straight) == {:straight, 5, straight}
    assert Ranking.verify_hand(three_of_a_kind) == {:three_of_a_kind, 4, three_of_a_kind}
    assert Ranking.verify_hand(two_pairs) == {:two_pairs, 3, two_pairs}
    assert Ranking.verify_hand(pair) == {:pair, 2, pair}
    assert Ranking.verify_hand(high_card) == {:high_card, 1, high_card}
  end

  test "verify winner - betty examples" do
    {black, white} = "2H 3D 5S 9C KD 2C 3H 4S 8C AH" |> PokerOpdracht.parse_inputs
    {black1, white1} = "2H 4S 4C 3D 4H 2S 8S AS QS 3S" |> PokerOpdracht.parse_inputs
    {black2, white2} = "2H 3D 5S 9C KD 2C 3H 4S 8C KH" |> PokerOpdracht.parse_inputs
    {black3, white3} = "2H 3D 5S 9C KD 2D 3H 5C 9S KH" |> PokerOpdracht.parse_inputs

    assert Ranking.verify_winner(black, white) == {:white, {:high_card, 14}}
    assert Ranking.verify_winner(black1, white1) == {:white, :flush}
    assert Ranking.verify_winner(black2, white2) == {:black, {:high_card, 9}}
    assert Ranking.verify_winner(black3, white3) == :tie
  end

  test "verify_winner - rodrigo examples" do
    straight_flush = get_set(:straight_flush)
    four_of_a_kind = get_set(:four_of_a_kind)
    full_house = get_set(:full_house)
    flush = get_set(:flush)
    straight = get_set(:straight)
    three_of_a_kind = get_set(:three_of_a_kind)
    two_pairs = get_set(:two_pairs)
    pair = get_set(:pair)
    high_card = get_set(:high_card)


    assert Ranking.verify_winner(straight_flush, four_of_a_kind) == {:black, :straight_flush}
    assert Ranking.verify_winner(four_of_a_kind, full_house) == {:black, :four_of_a_kind}
    assert Ranking.verify_winner(full_house, flush) == {:black, :full_house}
    assert Ranking.verify_winner(flush, straight) == {:black, :flush}
    assert Ranking.verify_winner(straight, three_of_a_kind) == {:black, :straight}
    assert Ranking.verify_winner(three_of_a_kind, two_pairs) == {:black, :three_of_a_kind}
    assert Ranking.verify_winner(two_pairs, pair) == {:black, :two_pairs}
    assert Ranking.verify_winner(pair, high_card) == {:black, :pair}
    assert Ranking.verify_winner(high_card, high_card) == :tie
  end

  def get_set(:straight_flush), do: ["2S", "3S", "4S", "5S", "6S"]
  def get_set(:four_of_a_kind), do: ["2S", "2C", "2D", "2H", "6S"]
  def get_set(:full_house), do: ["2S", "2C", "6C", "6D", "6S"]
  def get_set(:flush), do: ["2S", "3S", "8S", "5S", "10S"]
  def get_set(:straight), do: ["2C", "3D", "4H", "5C", "6S"]
  def get_set(:three_of_a_kind), do: ["9S", "9C", "9D", "5H", "6S"]
  def get_set(:two_pairs), do: ["2S", "2C", "4S", "4H", "6S"]
  def get_set(:pair), do: ["2S", "2C", "9S", "5H", "6D"]
  def get_set(:high_card), do: ["2C", "5D", "8H", "10S", "11D"]


end

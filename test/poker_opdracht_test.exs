defmodule PokerOpdrachtTest do
  use ExUnit.Case
  doctest PokerOpdracht

  setup_all do
    [
      straight_flush: ["2S", "3S", "4S", "5S", "6S"],
      four_of_a_kind: ["2S", "2C", "2D", "2H", "6S"],
      full_house: ["2S", "2C", "6C", "6D", "6S"],
      full_house_lower: ["9C", "9H", "3S", "3D", "3H"],
      flush: ["2S", "3S", "8S", "5S", "10S"],
      straight: ["2C", "3D", "4H", "5C", "6S"],
      three_of_a_kind: ["9S", "9C", "9D", "5H", "6S"],
      two_pairs: ["8C", "8H", "3S", "3D", "5H"],
      two_pairs_lower: ["2H", "2D", "5S", "5C", "9D"],
      two_equal_pairs_lower: ["2H", "2D", "5S", "5C", "8D"],
      pair: ["2S", "2C", "9S", "5H", "6D"],
      high_card: ["2C", "5D", "8H", "10S", "11D"],
      high_card_lower: ["2C", "3H", "8S", "10S", "11H"],
      four_equal_suits: ["2C", "3C", "8C", "9C", "5S"]
    ]
  end

  test "verify_winner - rodrigo examples", sets do
    straight_flush = sets[:straight_flush]
    four_of_a_kind = sets[:four_of_a_kind]
    full_house = sets[:full_house]
    flush = sets[:flush]
    straight = sets[:straight]
    three_of_a_kind = sets[:three_of_a_kind]
    two_pairs = sets[:two_pairs]
    pair = sets[:pair]
    high_card = sets[:high_card]


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

  ## Unties

  test "untie by high card", sets do
    {black, white} = {sets[:high_card], sets[:high_card_lower]}
    {black2, white2} = {sets[:high_card], sets[:high_card]}

    assert Ranking.verify_winner(black, white) == {:black, {:high_card, 5}}
    assert Ranking.verify_winner(black2, white2) == :tie
  end

  test "untie unique set", sets do
    {black, white} = {sets[:full_house], sets[:full_house_lower]}
    assert Ranking.verify_winner(black, white) == {:black, {:high_card, 6}}
  end

  test "untie pairs", sets do
    {black, white} = {sets[:two_pairs], sets[:two_pairs_lower]}
    {black2, white2} = {sets[:two_pairs_lower], sets[:two_equal_pairs_lower]}
    assert Ranking.verify_winner(black, white) == {:black, {:high_card, 8}}
    assert Ranking.verify_winner(black2, white2) == {:black, {:high_card, 9}}
  end

  ## Validations

  test "parse input correctly" do
    result = PokerOpdracht.parse_inputs("2S 3S 4S 5S 6S 10D JH QC KS AD")
    assert result == {["2S", "3S", "4S", "5S", "6S"], ["10D", "11H", "12C", "13S", "14D"]}
  end

  test "number of equal suits", sets do
    assert Ranking.number_of_equal_suits(sets[:flush]) == 5
    assert Ranking.number_of_equal_suits(sets[:four_equal_suits]) == 4
  end

  test "number of equal values", sets do
    assert Ranking.number_of_equal_values(sets[:full_house]) == {3, 2}
    assert Ranking.number_of_equal_values(sets[:two_pairs]) == {2, 2}
    assert Ranking.number_of_equal_values(sets[:high_card]) == {1, 1}
  end

  test "highest consecutive group", sets do
    one_consec = ["2S", "5C", "8D", "10C", "12H"]
    two_consec_groups = ["2S", "3C", "6D", "7C", "8H"]
    straight = sets[:straight]

    assert Ranking.biggest_consecutive_group(one_consec) == 1
    assert Ranking.biggest_consecutive_group(two_consec_groups) == 3
    assert Ranking.biggest_consecutive_group(straight) == 5
  end

end

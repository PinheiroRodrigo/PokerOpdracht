defmodule PokerOpdrachtTest do
  use ExUnit.Case
  doctest PokerOpdracht

  setup_all do
    [
      straight_flush:        [{2, :spades}, {3, :spades},   {4, :spades},   {5, :spades},   {6, :spades}],
      four_of_a_kind:        [{2, :spades}, {2, :clubs},    {2, :diamonds}, {2, :hearts},   {6, :spades}],
      full_house:            [{2, :spades}, {2, :clubs},    {6, :clubs},    {6, :diamonds}, {6, :spades}],
      full_house_lower:      [{9, :clubs},  {9, :hearts},   {3, :spades},   {3, :diamonds}, {3, :hearts}],
      flush:                 [{2, :spades}, {3, :spades},   {8, :spades},   {5, :spades},   {10, :spades}],
      straight:              [{2, :clubs},  {3, :diamonds}, {4, :hearts},   {5, :clubs},    {6, :spades}],
      three_of_a_kind:       [{9, :spades}, {9, :clubs},    {9, :diamonds}, {5, :hearts},   {6, :spades}],
      two_pairs:             [{8, :clubs},  {8, :hearts},   {3, :spades},   {3, :diamonds}, {5, :hearts}],
      two_pairs_lower:       [{2, :hearts}, {2, :diamonds}, {5, :spades},   {5, :clubs},    {9, :diamonds}],
      two_equal_pairs_lower: [{2, :hearts}, {2, :diamonds}, {5, :spades},   {5, :clubs},    {8, :diamonds}],
      pair:                  [{2, :spades}, {2, :clubs},    {9, :spades},   {5, :hearts},   {6, :diamonds}],
      high_card:             [{2, :clubs},  {5, :diamonds}, {8, :hearts},   {10, :spades},  {11, :diamonds}],
      high_card_lower:       [{2, :clubs},  {3, :hearts},   {8, :spades},   {10, :spades},  {11, :hearts}],
      four_equal_suits:      [{2, :clubs},  {3, :clubs},    {8, :clubs},    {9, :clubs},    {5, :spades}]
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


    assert Ranking.verify_winner({straight_flush, four_of_a_kind}) == {:black, :straight_flush}
    assert Ranking.verify_winner({four_of_a_kind, full_house}) == {:black, :four_of_a_kind}
    assert Ranking.verify_winner({full_house, flush}) == {:black, :full_house}
    assert Ranking.verify_winner({flush, straight}) == {:black, :flush}
    assert Ranking.verify_winner({straight, three_of_a_kind}) == {:black, :straight}
    assert Ranking.verify_winner({three_of_a_kind, two_pairs}) == {:black, :three_of_a_kind}
    assert Ranking.verify_winner({two_pairs, pair}) == {:black, :two_pairs}
    assert Ranking.verify_winner({pair, high_card}) == {:black, :pair}
    assert Ranking.verify_winner({high_card, high_card}) == :tie
  end

  test "verify winner - betty examples" do
    example1 = "Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C AH"
    example2 = "Black: 2H 4S 4C 3D 4H White: 2S 8S AS QS 3S"
    example3 = "Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C KH"
    example4 = "Black: 2H 3D 5S 9C KD White: 2D 3H 5C 9S KH"

    assert PokerOpdracht.play(example1) == "white wins - high card: Ace"
    assert PokerOpdracht.play(example2) == "white wins - flush"
    assert PokerOpdracht.play(example3) == "black wins - high card: 9"
    assert PokerOpdracht.play(example4) == "Tie"
  end

  ## Unties

  test "untie by high card", sets do
    {black, white} = {sets[:high_card], sets[:high_card_lower]}
    {black2, white2} = {sets[:high_card], sets[:high_card]}

    assert Ranking.verify_winner({black, white}) == {:black, {:high_card, 5}}
    assert Ranking.verify_winner({black2, white2}) == :tie
  end

  test "untie unique set", sets do
    {black, white} = {sets[:full_house], sets[:full_house_lower]}

    assert Ranking.verify_winner({black, white}) == {:black, {:high_card, 6}}
  end

  test "untie pairs", sets do
    {black, white} = {sets[:two_pairs], sets[:two_pairs_lower]}
    # two equal pairs, last white card has a lower value
    {black2, white2} = {sets[:two_pairs_lower], sets[:two_equal_pairs_lower]}

    assert Ranking.verify_winner({black, white}) == {:black, {:high_card, 8}}
    assert Ranking.verify_winner({black2, white2}) == {:black, {:high_card, 9}}
  end

  ## Validations

  test "parse input correctly" do
    black = " 2S 3S 4S 5S 6S"
    white = " TD JH QC KS AD"
    result = {PokerOpdracht.parse_hand(black), PokerOpdracht.parse_hand(white)}
    assert result == {[{2, :spades}, {3, :spades}, {4, :spades}, {5, :spades}, {6, :spades}], [{10, :diamonds}, {11, :hearts}, {12, :clubs}, {13, :spades}, {14, :diamonds}]}
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
    one_consec = [{2, :spades}, {5, :clubs}, {8, :diamonds}, {10, :clubs}, {12, :hearts}]
    two_consec_groups = [{2, :spades}, {3, :clubs}, {6, :diamonds}, {7, :clubs}, {8, :hearts}]
    straight = sets[:straight]

    assert Ranking.biggest_consecutive_group(one_consec) == 1
    assert Ranking.biggest_consecutive_group(two_consec_groups) == 3
    assert Ranking.biggest_consecutive_group(straight) == 5
  end

end

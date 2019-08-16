defmodule Ranking do


  @doc """
  Verify the winner between two hands.

  ## Examples

    iex> Ranking.verify_winner(
      {:black, [{2, :hearts}, {3, :hearts}, {5, :hearts}, {9, :hearts}, {13, :hearts}],
      :white, [{2, :clubs}, {3, :hearts}, {4, :spades}, {8, :clubs}, {14, :hearts}]}
     )
    {:black, :straight_flush}

  """
  def verify_winner({:black, black, :white, white}), do: verify_winner(black, white)
  def verify_winner(black, white) do
    {b_set, b_points, b_hand} = verify_hand(black)
    {w_set, w_points, w_hand} = verify_hand(white)
    cond do
      b_points > w_points -> {:black, b_set}
      b_points < w_points -> {:white, w_set}
      true -> untie(b_hand, w_hand, b_set)
    end
  end


  @doc """
  Verify which set does a hand have, based on three parameters:
  * Number of equal card suits
  * Number of equal card values
  * Biggest consecutive group

  ## Examples

    iex> Ranking.verify_hand([{8, :clubs}, {8, :hearts}, {3, :spades}, {3, :diamonds}, {5, :hearts}]
    {:two_pairs, 3, ["8C", "8H", "3S", "3D", "5H"]}

  """
  def verify_hand(hand) do
    num_eq_suits = number_of_equal_suits(hand)
    biggest_consec_group = biggest_consecutive_group(hand)
    num_eq_vals = number_of_equal_values(hand)
    case {num_eq_suits, biggest_consec_group, num_eq_vals} do
      {5, 5,      _} -> {:straight_flush,  9, hand}
      {_, _, {4, _}} -> {:four_of_a_kind,  8, hand}
      {_, _, {3, 2}} -> {:full_house,      7, hand}
      {5, _,      _} -> {:flush,           6, hand}
      {_, 5,      _} -> {:straight,        5, hand}
      {_, _, {3, _}} -> {:three_of_a_kind, 4, hand}
      {_, _, {2, 2}} -> {:two_pairs,       3, hand}
      {_, _, {2, _}} -> {:pair,            2, hand}
      _              -> {:high_card,       1, hand}
    end
  end

  @doc """
  untie hands with equal sets, this function treats all untie edge cases.
  """
  def untie(black, white, set) when is_list(black) and is_list(white) do
    black_values = Enum.map(black, &(elem(&1, 0)))
    white_values = Enum.map(white, &(elem(&1, 0)))
    cond do
      set in [:pair, :two_pairs] ->
        untie_pairs(black_values, white_values)
      set in [:three_of_a_kind, :full_house, :four_of_a_kind] ->
        untie_unique_sets(black_values, white_values)
      true ->
        untie_by_high_card(black_values, white_values)
    end
  end

  @doc """
  untie hands with no sets.

  ## Examples

    iex> Ranking.untie_pairs([2, 4, 6, 8, 11], [2, 4, 6, 8, 9])
    {:black, {:high_card, 11}}

  """
  def untie_by_high_card([], []), do: :tie
  def untie_by_high_card(black, white) do
    b_max = Enum.max(black)
    w_max = Enum.max(white)
    cond do
      b_max > w_max -> {:black, {:high_card, b_max}}
      w_max > b_max -> {:white, {:high_card, w_max}}
      true -> untie_by_high_card(List.delete(black, b_max), List.delete(white, w_max))
    end
  end

  @doc """
  untie hands with one or two pairs.

  ## Examples

    iex> Ranking.untie_pairs([8, 8, 3, 3, 5], [2, 2, 5, 5, 9])
    {:black, {:high_card, 8}}

  """
  def untie_pairs([], []), do: :tie
  def untie_pairs(black, white) do
    {b_high, _} = highest_appearance_and_value(black)
    {w_high, _} = highest_appearance_and_value(white)
    cond do
      b_high > w_high -> {:black, {:high_card, b_high}}
      w_high > b_high -> {:white, {:high_card, w_high}}
      true -> untie_pairs(List.delete(black, b_high), List.delete(white, w_high))
    end
  end

  @doc """
  A hand is considered a unique set when it have three or four cards with equal values.
  This function unties two unique set hands.

  ## Examples

    iex> Ranking.untie_unique_sets([2, 2, 6, 6, 6], [9, 9, 3, 3, 3])
    {:black, {:high_card, 6}}

  """
  def untie_unique_sets(black, white) do
    {b_high, _} = highest_appearance_and_value(black)
    {w_high, _} = highest_appearance_and_value(white)
    if b_high > w_high do
      {:black, {:high_card, b_high}}
    else
      {:white, {:high_card, w_high}}
    end
  end

  @doc """
  Verifies the highest number of equal suit cards.

  ## Examples

    iex> Ranking.number_of_equal_suits([{2, :hearts}, {3, :hearts}, {5, :hearts}, {9, :hearts}, {13, :hearts}])
    5

  """
  def number_of_equal_suits(hand) do
    hand
    |> Enum.group_by(&(elem(&1, 1)))
    |> Enum.max_by(fn({_suit, ocurrences}) -> length(ocurrences) end)
    |> elem(1)
    |> length
  end

  @doc """
  Verifies the highest and second highest number of equal value cards.

  ## Examples

    iex> Ranking.number_of_equal_values([{2, :clubs}, {2, :hearts}, {2, :spades}, {9, :hearts}, {9, :diamonds}])
    {3,2}

  """
  def number_of_equal_values(hand) do
    hand
    |> Enum.group_by(&(elem(&1, 0)))
    |> Enum.reduce({1, 1}, fn({_value, cards}, {highest, second_highest}) ->
      ocurrences = length(cards)
      cond do
        ocurrences > highest -> {ocurrences, highest}
        ocurrences > second_highest -> {highest, ocurrences}
        true -> {highest, second_highest}
      end
    end)
  end

  @doc """
  Verifies the number of consecutive cards.

  ## Examples

    iex> Ranking.biggest_consecutive_group([{2, :clubs}, {3, :hearts}, {4, :spades}, {5, :hearts}, {6, :diamonds}])
    5

  """
  def biggest_consecutive_group(hand) do
    hand
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sort
    |> group_consecutives
    |> Enum.max_by(&length/1)
    |> length
  end

  # Group consecutive values in a list, returns a list with all groups
  # input: [1,2,3,8,10]
  # output: [[1,2,3], [8], [10]]
  defp group_consecutives([card_value | tail]), do: group_consecutives(tail, [[card_value]])
  defp group_consecutives([], acc), do: acc
  defp group_consecutives([card_value | tail], acc) do
    [[latest_card_value | latest_tail] | old_consecutive_groups] = acc
    if card_value == latest_card_value + 1 do
      group_consecutives(tail, [[card_value, latest_card_value | latest_tail] | old_consecutive_groups])
    else
      group_consecutives(tail, [[card_value]] ++ acc)
    end
  end

  # Returns most frequent and highest value cards as tuple
  # input: [8, 8, 3, 3, 5]
  # output: {8, 2}
  defp highest_appearance_and_value(hand) do
    hand
    |> Enum.uniq
    |> Enum.reduce({0, 0}, fn(card_value, {high, count}) ->
      card_count = Enum.count(hand, &(&1 == card_value))
      cond do
        card_count > count -> {card_value, card_count}
        card_count < count -> {high, count}
        card_value > high -> {card_value, card_count}
        true -> {high, count}
      end
    end)
  end

end

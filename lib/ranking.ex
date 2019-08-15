defmodule Ranking do

  def verify_winner({black, white}), do: verify_winner(black, white)
  def verify_winner(black, white) do
    {b_set, b_points, b_hand} = verify_hand(black)
    {w_set, w_points, w_hand} = verify_hand(white)
    cond do
      b_points > w_points -> {:black, b_set}
      b_points < w_points -> {:white, w_set}
      true -> untie(b_hand, w_hand, b_set)
    end
  end

  defp verify_hand(hand) do
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

  def untie(black, white, set) when is_list(black) and is_list(white) do
    black_values = black |> Enum.map(&(&1 |> card_value))
    white_values = white |> Enum.map(&(&1 |> card_value))
    cond do
      set in [:pair, :two_pairs] ->
        untie_pairs(black_values, white_values)
      set in [:three_of_a_kind, :full_house, :four_of_a_kind] ->
        untie_unique_sets(black_values, white_values)
      true ->
        untie_by_high_card(black_values, white_values)
    end
  end

  def untie_by_high_card([], []), do: :tie
  def untie_by_high_card(black, white) do
    b_max = black |> Enum.max
    w_max = white |> Enum.max
    cond do
      b_max > w_max -> {:black, {:high_card, b_max}}
      w_max > b_max -> {:white, {:high_card, w_max}}
      true -> untie_by_high_card(List.delete(black, b_max), List.delete(white, w_max))
    end
  end

  def untie_pairs([], []), do: :tie
  def untie_pairs(black, white) do
    {b_high, _} = black |> highest_appearance_and_value
    {w_high, _} = white |> highest_appearance_and_value
    cond do
      b_high > w_high -> {:black, {:high_card, b_high}}
      w_high > b_high -> {:white, {:high_card, w_high}}
      true -> untie_pairs(List.delete(black, b_high), List.delete(white, w_high))
    end
  end

  def untie_unique_sets(black, white) do
    {b_high, _} = black |> highest_appearance_and_value
    {w_high, _} = white |> highest_appearance_and_value
    if b_high > w_high do
      {:black, {:high_card, b_high}}
    else
      {:white, {:high_Card, w_high}}
    end
  end

  # Data Structures

  def highest_card(hand), do: hand |> Enum.map(&(&1 |> card_value)) |> Enum.max

  defp card_value(card), do: card |> Integer.parse |> elem(0)

  def number_of_equal_suits(hand) do
    hand
    |> Enum.group_by(&String.last/1)
    |> Map.values
    |> Enum.max_by(&length/1)
    |> length
  end

  def number_of_equal_values(hand) do
    equal_values =
      hand
      |> Enum.group_by(&card_value/1)
      |> Enum.map(fn {_key, value_list} -> value_list |> length end)
    highest = Enum.max(equal_values)
    second_highest = equal_values |> List.delete(highest) |> Enum.max
    {highest, second_highest}
  end

  def biggest_consecutive_group(hand) do
    hand
    |> Enum.map(&(&1 |> card_value))
    |> Enum.sort
    |> group_consecutives
    |> Enum.max_by(&length/1)
    |> length
  end

  defp group_consecutives([head | tail]), do: group_consecutives(tail, [[head]])
  defp group_consecutives([], acc), do: acc
  defp group_consecutives([head | tail], acc) do
    [[latest | t] | old_lists] = acc
    if head == latest + 1 do
      group_consecutives(tail, [[head, latest | t] | old_lists])
    else
      group_consecutives(tail, [[head]] ++ acc)
    end
  end

  # get the card by most appearances, and then by highest value
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

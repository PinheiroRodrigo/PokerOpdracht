defmodule PokerOpdracht do
  @moduledoc """
  Documentation for PokerOpdracht.

  Simple algorithm to verify the winner between two hands of poker.

  """

  @doc """
  Receives two poker hands as input and verify who's the winner.

  ## Examples

    iex> PokerOpdracht.play("Black: 2H 3D 5S 9C KD White: 2C 3H 4S TC AH")
    "white wins - high card: Ace"


  """
  @spec play(String.t) :: String.t
  def play(<<"Black:", black_hand :: binary-size(15), " White:", white_hand :: binary-size(15)>>) do
    {parse_hand(black_hand), parse_hand(white_hand)}
    |> Ranking.verify_winner
    |> pretty_output
  end

  @doc """
  Generates two random poker hands as input and verifies who's the winner.
  The function will print the generated hands, the winner and his set.
  """
  def play_random_hands do
    {black_hand, white_hand} = random_hands()
    IO.puts("Black:#{black_hand}\n")
    IO.puts("White:#{white_hand}\n")
    {parse_hand(black_hand), parse_hand(white_hand)}
    |> Ranking.verify_winner
    |> pretty_output
  end

  @spec parse_hand(String.t) :: String.t
  def parse_hand(""), do: []
  def parse_hand(<<" ", card :: binary-size(2), rest :: binary()>>) do
    [parse_card(card)] ++ parse_hand(rest)
  end

  defp parse_card(<<rank :: 8, suit :: 8>>), do: {parse_rank(rank), parse_suit(suit)}

  defp parse_rank(?T), do: 10
  defp parse_rank(?J), do: 11
  defp parse_rank(?Q), do: 12
  defp parse_rank(?K), do: 13
  defp parse_rank(?A), do: 14
  defp parse_rank(rank), do: rank - ?0

  defp parse_suit(?C), do: :clubs
  defp parse_suit(?D), do: :diamonds
  defp parse_suit(?H), do: :hearts
  defp parse_suit(?S), do: :spades
  defp parse_suit(_), do: :error

  defp random_hands do
    taken_cards =
      deck()
      |> Enum.shuffle
      |> Enum.take_random(10)
      |> List.to_string
    <<black_hand :: binary-size(15), white_hand :: binary-size(15)>> = taken_cards
    {black_hand, white_hand}
  end

  defp deck do
    card_values = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]
    ["C", "D", "H", "S"]
    |> Enum.map(&(for value <- card_values, do: " #{value}" <> &1))
    |> :lists.concat
  end

  defp pretty_output(:tie), do: "Tie"
  defp pretty_output({winner, result}), do: "#{winner} wins - #{parse_output(result)}"

  defp parse_output({:high_card, 14}), do: "high card: Ace"
  defp parse_output({:high_card, 13}), do: "high card: King"
  defp parse_output({:high_card, 12}), do: "high card: Queen"
  defp parse_output({:high_card, 11}), do: "high card: Jack"
  defp parse_output({:high_card, value}), do: "high card: #{value}"
  defp parse_output(result), do: Atom.to_string(result) |> String.replace("_", " ")

end

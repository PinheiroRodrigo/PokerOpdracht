defmodule PokerOpdracht do
  @moduledoc """
  Documentation for PokerOpdracht.

  Simple algorithm to verify the winner between two hands of poker.

  """

  @doc """
  Receives two poker hands as input and verify who's the winner.

  ## Examples

  PokerOpdracht.play

  Black: TD JH QC KS AH

  White: 3D 7H 6C 3S 2H

  {:black, :straight}

  """

  def play do
    black = IO.gets("Black: ") |> String.trim
    white = IO.gets("White: ") |> String.trim
    parse_inputs(black <> " " <> white)
    |> Ranking.verify_winner
    |> pretty_output
  end

  @doc """
  Generates two random poker hands as input and verifies who's the winner.

  ## Examples

  PokerOpdracht.play_random_hands

  Black: ["5D", "7C", "5S", "10D", "7S"]

  White: ["13C", "4D", "14C", "10H", "8D"]

  {:black, :two_pairs}

  """

  def play_random_hands do
    {black, white} = random_hands()
    IO.puts("Black: #{inspect black}\n")
    IO.puts("White: #{inspect white}\n")
    {black, white}
    |> Ranking.verify_winner
    |> pretty_output
  end

  defp random_hands do
    deck()
    |> Enum.shuffle
    |> Enum.take_random(10)
    |> Enum.split(5)
  end

  defp deck do
    card_values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"]
    ["C", "D", "H", "S"]
    |> Enum.map(&(for value <- card_values, do: value <> &1))
    |> :lists.concat
  end

  def parse_inputs(string) do
    hands =
      string
      |> String.upcase
      |> letter_to_values
      |> String.split(" ")
    if length(hands) == 10 do
       Enum.split(hands, 5)
    else
      "invalid input (5 cards for each hand are needed)"
    end
  end

  defp letter_to_values(string) do
    ~r/(J|Q|K|A)/
    |> Regex.replace(string, fn(_, x) ->
      case x do
        "J" -> "11"
        "Q" -> "12"
        "K" -> "13"
        "A" -> "14"
      end
    end)
  end

  def pretty_output(:tie), do: IO.puts("Tie")
  def pretty_output({winner, result}), do: IO.puts("#{winner} wins - #{parse_output(result)}")

  def parse_output({:high_card, 14}), do: "high card: Ace"
  def parse_output({:high_card, 13}), do: "high card: King"
  def parse_output({:high_card, 12}), do: "high card: Queen"
  def parse_output({:high_card, 11}), do: "high card: Jack"
  def parse_output({:high_card, value}), do: "high card: #{value}"
  def parse_output(result), do: Atom.to_string(result) |> String.replace("_", " ")

end

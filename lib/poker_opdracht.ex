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
    {black, white} = hands()
    IO.puts("Black: #{inspect black}")
    IO.puts("White: #{inspect white}")
    {black, white}
    |> Ranking.verify_winner
  end

  def hands do
    deck()
    |> Enum.shuffle
    |> Enum.take_random(10)
    |> List.to_string
    |> String.trim
    |> parse_inputs
  end

  def deck do
    card_values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14"]
    suits = ["C", "D", "H", "S"]
    Enum.map(suits, fn suit ->
      for value <- card_values, do: value <> suit
    end)
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

  # TODO: regex
  def letter_to_values(string) do
    string
    |> String.replace("T", "10")
    |> String.replace("J", "11")
    |> String.replace("Q", "12")
    |> String.replace("K", "13")
    |> String.replace("A", "14")
  end

end

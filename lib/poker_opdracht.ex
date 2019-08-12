defmodule PokerOpdracht do
  @moduledoc """
  Documentation for PokerOpdracht.
  """

  def play do
    black = IO.gets("Black: ") |> String.trim
    white = IO.gets("White: ") |> String.trim
    parse_inputs(black <> " " <> white)
    |> Ranking.verify_winner
  end

  def random_hands do
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
    card_values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "T", "J", "Q", "K", "A"]
    suits = ["C", "D", "H", "S"]
    Enum.map(suits, fn suit ->
      for value <- card_values, do: value <> suit <> " "
    end)
    |> :lists.concat
  end

  # TODO: input validations
  def parse_inputs(string) do
    string
    |> String.upcase
    |> letter_to_values
    |> String.split(" ")
    |> Enum.split(5)
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

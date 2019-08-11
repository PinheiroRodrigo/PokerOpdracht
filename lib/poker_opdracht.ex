defmodule PokerOpdracht do
  @moduledoc """
  Documentation for PokerOpdracht.
  """

  def start do
    black = IO.gets("Black: ") |> String.trim
    white = IO.gets("White: ") |> String.trim
    parse_inputs(black <> " " <> white)
  end

  # TODO: input validations
  # TODO: uppercase
  def parse_inputs(string) do
    string
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

  # Just to help on tests
  def hands do
    deck()
    |> Enum.shuffle
    |> Enum.take_random(10)
    |> List.to_string
    |> String.trim
    |> parse_inputs
  end

  # Just to help on tests
  def deck do
    card_values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "T", "J", "Q", "K", "A"]
    suits = ["C", "D", "H", "S"]
    Enum.map(suits, fn suit ->
      for value <- card_values, do: value <> suit <> " "
    end)
    |> :lists.concat
  end

end

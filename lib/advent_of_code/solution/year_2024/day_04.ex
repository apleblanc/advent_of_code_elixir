defmodule AdventOfCode.Solution.Year2024.Day04 do
  def parse_input(input) do
    input |> String.trim() |> String.split("\n")
  end

  def part1(input) do
    board = input |> parse_input() |> Enum.map(&String.codepoints/1)

    points(board)
    |> Enum.reduce(0, fn {x, y}, acc ->
      if Enum.at(Enum.at(board, y), x) != "X" do
        acc + 0
      else
        right = pms(board, [{x + 1, y}, {x + 2, y}, {x + 3, y}], "MAS")
        left = pms(board, [{x - 1, y}, {x - 2, y}, {x - 3, y}], "MAS")
        up = pms(board, [{x, y - 1}, {x, y - 2}, {x, y - 3}], "MAS")
        down = pms(board, [{x, y + 1}, {x, y + 2}, {x, y + 3}], "MAS")
        upright = pms(board, [{x + 1, y - 1}, {x + 2, y - 2}, {x + 3, y - 3}], "MAS")
        upleft = pms(board, [{x - 1, y - 1}, {x - 2, y - 2}, {x - 3, y - 3}], "MAS")
        downright = pms(board, [{x + 1, y + 1}, {x + 2, y + 2}, {x + 3, y + 3}], "MAS")
        downleft = pms(board, [{x - 1, y + 1}, {x - 2, y + 2}, {x - 3, y + 3}], "MAS")
        acc + right + left + up + down + upright + upleft + downright + downleft
      end
    end)
  end

  def part2(input) do
    board = input |> parse_input() |> Enum.map(&String.codepoints/1)
    h = length(board)
    w = length(Enum.at(board, 0))

    points(board)
    |> Enum.reduce(0, fn {x, y}, acc ->
      cond do
        x < 1 or y < 1 or x > w - 2 or y > h - 2 ->
          acc + 0

        Enum.at(Enum.at(board, y), x) != "A" ->
          acc + 0

        true ->
          up =
            pms(board, [{x - 1, y - 1}, {x + 1, y - 1}, {x + 1, y + 1}, {x - 1, y + 1}], "MSSM")

          right =
            pms(board, [{x + 1, y - 1}, {x + 1, y + 1}, {x - 1, y + 1}, {x - 1, y - 1}], "MSSM")

          down =
            pms(board, [{x + 1, y + 1}, {x - 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}], "MSSM")

          left =
            pms(board, [{x - 1, y + 1}, {x - 1, y - 1}, {x + 1, y - 1}, {x + 1, y + 1}], "MSSM")

          acc + up + right + down + left
      end
    end)
  end

  def points(board) do
    for y <- 0..(length(board) - 1), x <- 0..(length(Enum.at(board, 0)) - 1), do: {x, y}
  end

  def pms(_board, [], ""), do: 1

  def pms(board, [{x, y} | points], s) do
    if x < 0 or y < 0 do
      0
    else
      letter = Enum.at(Enum.at(board, y) || [], x)

      if letter == String.slice(s, 0, 1) do
        pms(board, points, String.slice(s, 1..-1//1))
      else
        0
      end
    end
  end
end

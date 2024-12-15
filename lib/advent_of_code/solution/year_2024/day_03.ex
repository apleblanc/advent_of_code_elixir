defmodule AdventOfCode.Solution.Year2024.Day03 do
  def part1(input) do
    Regex.scan(~r/mul\((\d{1,3}),(\d{1,3})\)/, input)
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end

  def part2(input) do
    Regex.scan(~r/(?:mul\((\d{1,3}),(\d{1,3})\))|(?:do\(\))|(?:don't\(\))/, input)
    |> Enum.reduce({true, 0}, fn tok, {enabled, sum} ->
      case tok do
        ["do()"] ->
          {true, sum}

        ["don't()"] ->
          {false, sum}

        [_, a, b] ->
          {enabled, sum + ((enabled && String.to_integer(a) * String.to_integer(b)) || 0)}
      end
    end)
    |> elem(1)
  end
end

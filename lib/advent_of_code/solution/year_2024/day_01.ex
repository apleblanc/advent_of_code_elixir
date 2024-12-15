defmodule AdventOfCode.Solution.Year2024.Day01 do
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&Enum.sort/1)
    |> List.zip()
    |> Enum.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()
  end

  def part2(input) do
    [l, r] = parse_input(input)

    l
    |> Enum.map(fn num -> num * Enum.count(r, &(num == &1)) end)
    |> Enum.sum()

  end
end

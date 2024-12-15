defmodule AdventOfCode.Solution.Year2024.Day07 do
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [l, r] = String.split(line, ":") |> Enum.map(&String.trim/1)
      test_val = String.to_integer(l)
      numbers = r |> String.split() |> Enum.map(&String.to_integer/1)
      {test_val, numbers}
    end)
  end

  def combos(0, _), do: [[]]

  def combos(n, l) do
    l
    |> Stream.flat_map(fn c ->
      combos(n - 1, l)
      |> Stream.map(&[c | &1])
    end)
  end

  def solve([number], []), do: number

  def solve([number, next_number | rest_nums], [op | rest_ops]) do
    solve([op.(number, next_number)] ++ rest_nums, rest_ops)
  end

  def solvable(test_val, numbers, operations) do
    (length(numbers) - 1)
    |> combos(operations)
    |> Enum.any?(&(solve(numbers, &1) == test_val))
  end

  def cat(a, b), do: String.to_integer("#{a}#{b}")

  def part1(input) do
    equations = input |> parse_input()

    equations
    |> Enum.filter(fn {test_val, numbers} ->
      solvable(test_val, numbers, [&Kernel.+/2, &Kernel.*/2])
    end)
    |> Enum.map(fn {test_val, _} -> test_val end)
    |> Enum.sum()
  end

  def part2(input) do
    equations = input |> parse_input()

    equations
    |> Enum.filter(fn {test_val, numbers} ->
      solvable(test_val, numbers, [&Kernel.+/2, &Kernel.*/2, &cat/2])
    end)
    |> Enum.map(fn {test_val, _} -> test_val end)
    |> Enum.sum()
  end
end

defmodule AdventOfCode.Solution.Year2024.Day02 do
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> line |> String.split() |> Enum.map(&String.to_integer/1) end)
  end

  def is_safe1(report) do
    deltas =
      report
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    Enum.all?(deltas, &(&1 <= -1 and &1 >= -3)) or
      Enum.all?(deltas, &(&1 >= 1 and &1 <= 3))
  end

  def is_safe2(report) do
    Enum.map(0..length(report), fn i ->
      List.delete_at(report, i)
    end)
    |> Enum.any?(&is_safe1/1)
  end

  def part1(input) do
    parse_input(input)
    |> Enum.count(&is_safe1/1)
  end

  def part2(input) do
    parse_input(input)
    |> Enum.count(&(is_safe1(&1) or is_safe2(&1)))
  end
end

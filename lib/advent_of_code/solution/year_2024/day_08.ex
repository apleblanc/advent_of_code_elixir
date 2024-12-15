defmodule AdventOfCode.Solution.Year2024.Day08 do
  def parse_input(input) do
    input = input |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)

    points = for y <- 0..(length(input) - 1), x <- 0..(length(Enum.at(input, 0)) - 1), do: {x, y}

    antennae =
      points
      |> Enum.reduce(%{}, fn {x, y}, acc ->
        case Enum.at(Enum.at(input, y), x) do
          "." -> acc
          other -> Map.put(acc, {x, y}, other)
        end
      end)

    {antennae, length(Enum.at(input, 0)), length(input)}
  end

  def part1(input) do
    {antennae, w, h} = input |> parse_input()

    Enum.reduce(Map.keys(antennae), MapSet.new(), fn {x, y}, acc ->
      freq = Map.get(antennae, {x, y})

      others =
        Map.filter(antennae, fn {k, v} -> v == freq and k != {x, y} end)
        |> Enum.flat_map(fn {{ox, oy}, _} ->
          {dx, dy} = {ox - x, oy - y}
          [{x - dx, y - dy}, {ox + dx, oy + dy}]
        end)
        |> Enum.filter(fn {x, y} ->
          x >= 0 and y >= 0 and x < w and y < h
        end)

      MapSet.union(acc, MapSet.new(others))
    end)
    |> MapSet.size()
  end

  def part2(input) do
    {antennae, w, h} = parse_input(input)

    Enum.reduce(Map.keys(antennae), MapSet.new(), fn {x, y}, acc ->
      freq = Map.get(antennae, {x, y})

      others =
        Map.filter(antennae, fn {k, v} -> v == freq and k != {x, y} end)
        |> Enum.flat_map(fn {{ox, oy}, _} ->
          {dx, dy} = {ox - x, oy - y}

          findAntinodes({x, y}, {-dx, -dy}, {w, y}) ++
            findAntinodes({ox, oy}, {dx, dy}, {w, h}) ++ [{x, y}, {ox, oy}]
        end)

      MapSet.union(acc, MapSet.new(others))
    end)
    |> MapSet.size()
  end

  def findAntinodes({x, y}, {dx, dy}, {w, h}) do
    {nx, ny} = {x + dx, y + dy}

    if nx >= 0 and ny >= 0 and nx < w and ny < h do
      [{nx, ny}] ++ findAntinodes({nx, ny}, {dx, dy}, {w, h})
    else
      []
    end
  end
end

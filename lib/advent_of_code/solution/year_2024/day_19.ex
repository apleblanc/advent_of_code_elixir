defmodule AdventOfCode.Solution.Year2024.Day19 do
  def parse_input(input) do
    [patterns, bottom] = input |> String.trim() |> String.split("\n\n")
    {patterns |> String.split(", "), bottom |> String.split("\n")}
  end

  def can_make_pattern("", _, _), do: 1

  def can_make_pattern(pat, towels, cache) do
    cached = Agent.get(cache, fn state -> Map.get(state, pat, nil) end)

    if !is_nil(cached) do
      cached
    else
      count =
        towels
        |> Enum.filter(fn t -> String.starts_with?(pat, t) end)
        |> Enum.map(fn t ->
          can_make_pattern(String.slice(pat, String.length(t), String.length(pat)), towels, cache)
        end)
        |> Enum.sum()

      Agent.cast(cache, fn state -> Map.put(state, pat, count) end)
      count
    end
  end

  def part1(input) do
    {towels, patterns} = input |> parse_input()
    {:ok, cache} = Agent.start_link(fn -> %{} end)

    patterns
    |> Enum.filter(fn p ->
      IO.puts("Pattern: #{p}")

      if can_make_pattern(p, towels, cache) > 0 do
        true
      else
        false
      end
    end)
    |> Enum.count()
  end

  def part2(input) do
    {towels, patterns} = input |> parse_input()
    {:ok, cache} = Agent.start_link(fn -> %{} end)

    patterns
    |> Enum.map(fn p ->
      can_make_pattern(p, towels, cache)
    end)
    |> Enum.sum()
  end
end

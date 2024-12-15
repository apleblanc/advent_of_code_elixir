defmodule AdventOfCode.Solution.Year2024.Day11 do
  def parse_input(input) do
    input |> String.trim() |> String.split() |> Enum.map(&String.to_integer/1)
  end

  def blink_count(_rock, 0, _agent), do: 1

  def blink_count(rock, n, agent) do
    case Agent.get(agent, & Map.get(&1, {rock, n})) do
      nil ->
        s = "#{rock}"
        l = String.length(s)

        val =
          cond do
            rock == 0 ->
              blink_count(1, n - 1, agent)

            rem(l, 2) == 0 ->
              {a, b} = String.split_at(s, floor(l / 2))

              blink_count(String.to_integer(a), n - 1, agent) +
                blink_count(String.to_integer(b), n - 1, agent)

            true ->
              blink_count(rock * 2024, n - 1, agent)
          end

        Agent.cast(agent, & Map.put(&1, {rock, n}, val))
        val

      val ->
        val
    end
  end

  def part1(input) do
    {:ok, agent} = Agent.start_link(fn -> %{} end)

    input
    |> parse_input()
    |> Enum.map(& blink_count(&1, 25, agent))
    |> Enum.sum()
  end

  def part2(input) do
    {:ok, agent} = Agent.start_link(fn -> %{} end)

    input
    |> parse_input()
    |> Enum.map(& blink_count(&1, 75, agent))
    |> Enum.sum()
  end
end

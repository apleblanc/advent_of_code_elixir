defmodule AdventOfCode.Solution.Year2024.Day05 do
  def parse_input(input) do
    [a, b] =
      input
      |> String.trim()
      |> String.split("\n\n")

    rules = a |> String.trim() |> String.split("\n") |> Enum.map(&String.split(&1, "|"))
    updates = b |> String.trim() |> String.split("\n") |> Enum.map(&String.split(&1, ","))
    {rules, updates}
  end

  def validate_update(rules, update) do
    Enum.all?(rules, fn [a, b] ->
      if a in update and b in update do
        Enum.find_index(update, &(&1 == a)) < Enum.find_index(update, &(&1 == b))
      else
        true
      end
    end)
  end

  def sort_update(rules, update) do
    up =
      rules
      |> Enum.reduce(update, fn [a, b], update ->
        if a in update and b in update do
          apos = Enum.find_index(update, &(&1 == a))
          bpos = Enum.find_index(update, &(&1 == b))

          if apos > bpos do
            update
            |> List.delete_at(apos)
            |> List.insert_at(bpos, a)
          else
            update
          end
        else
          update
        end
      end)

    if validate_update(rules, up) do
      up
    else
      sort_update(rules, up)
    end
  end

  def part1(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.filter(fn update ->
      validate_update(rules, update)
    end)
    |> Enum.map(&String.to_integer(Enum.at(&1, floor(length(&1) / 2))))
    |> Enum.sum()
  end

  def part2(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.filter(fn update ->
      !validate_update(rules, update)
    end)
    |> Enum.map(&sort_update(rules, &1))
    |> Enum.map(&String.to_integer(Enum.at(&1, floor(length(&1) / 2))))
    |> Enum.sum()
  end
end

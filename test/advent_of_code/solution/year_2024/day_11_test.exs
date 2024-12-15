defmodule AdventOfCode.Solution.Year2024.Day11Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day11

  setup do
    [
      input: "0 1 10 99 999"
    ]
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)

    assert result == "1 2024 1 0 9 9 2021976"
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result
  end
end

defmodule AdventOfCode.Solution.Year2024.Day09Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day09

  setup do
    [
      input: """
2333133121414131402
"""
    ]
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)

    assert result == 1928
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result == 2858
  end
end

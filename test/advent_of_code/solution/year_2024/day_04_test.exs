defmodule AdventOfCode.Solution.Year2024.Day04Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day04

  setup do
    [
      input: """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
    ]
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)

    assert result == 18
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result == 9
  end
end

defmodule AdventOfCode.Solution.Year2024.Day19Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day19

  setup do
    [
      input: """
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
"""
    ]
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)

    assert result == 6
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result == 16
  end
end

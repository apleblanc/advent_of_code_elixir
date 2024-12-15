defmodule AdventOfCode.Solution.Year2024.Day08Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day08

  setup do
    [
      input: """
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"""
    ]
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)

    assert result == 14
  end

  @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result == 34
  end
end

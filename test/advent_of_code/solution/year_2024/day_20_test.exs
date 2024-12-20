defmodule AdventOfCode.Solution.Year2024.Day20Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day20

  setup do
    [
      input: """
###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############
"""
    ]
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)

    assert result == nil
  end

  # @tag :skip
  test "part2", %{input: input} do
    result = part2(input)

    assert result == nil
  end
end

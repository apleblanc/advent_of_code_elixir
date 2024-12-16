defmodule AdventOfCode.Solution.Year2024.Day16Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day16

  setup do
    [
      input2: """
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
""",
input: """
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
"""
    ]
  end

  @tag :skip
  test "part1", %{input: input, input2: input2} do
    result1 = part1(input)
    result2 = part1(input2)
    assert result1 == 7036
    assert result2 == 11048
  end

  @tag :skip
  test "part2", %{input: input, input2: input2} do
    result1 = part2(input)
    result2 = part2(input2)
    assert result1 == 45
    assert result2 == 64
  end
end

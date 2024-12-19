defmodule AdventOfCode.Solution.Year2024.Day17Test do
  use ExUnit.Case, async: true

  import AdventOfCode.Solution.Year2024.Day17

  setup do
    [
      input: """
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
""",
      input2: """
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
"""

]
  end

  @tag :skip
  test "part1", %{input: input} do
    result = part1(input)
    assert result == "4,6,3,5,6,3,5,2,1,0"
  end

  @tag :skip
  test "part2", %{input2: input} do
    result = part2(input)

    assert result == 117440
  end
end

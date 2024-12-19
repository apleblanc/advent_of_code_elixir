defmodule AdventOfCode.Solution.Year2024.Day17 do
  import Bitwise

  def parse_input(input) do
    [registers, program] = input |> String.trim() |> String.split("\n\n")

    registers =
      registers
      |> String.split("\n")
      |> Enum.map(fn r ->
        [_, reg, val] = Regex.run(~r/Register (\w+): (\d+)/, r)
        {reg, String.to_integer(val)}
      end)
      |> Map.new()

    program =
      String.split(program, ": ")
      |> Enum.at(1)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {v, k} -> {k, v} end)
      |> Map.new()

    {registers, program}
  end

  def combo(op, registers) do
    case op do
      i when i >= 0 and i <= 3 -> i
      4 -> Map.get(registers, "A")
      5 -> Map.get(registers, "B")
      6 -> Map.get(registers, "C")
      _ -> :error
    end
  end

  def step(program, reg, ptr, outs) do
    names = ["adv", "bxl", "bst", "jnz", "bxc", "out", "bdv", "cdv"]
    # read instruction
    ins = Map.get(program, ptr)
    op = Map.get(program, ptr + 1)
    IO.puts("(@#{ptr}) Performing #{Enum.at(names, ins)} on #{op} #{inspect(reg)}")

    {reg, ptr, outs} =
      case ins do
        0 ->
          num = Map.get(reg, "A")
          den = 2 ** combo(op, reg)
          {Map.put(reg, "A", floor(num / den)), ptr + 2, outs}

        1 ->
          val = bxor(Map.get(reg, "B"), op)
          {Map.put(reg, "B", val), ptr + 2, outs}

        2 ->
          val = rem(combo(op, reg), 8)
          {Map.put(reg, "B", val), ptr + 2, outs}

        3 ->
          if Map.get(reg, "A") != 0 do
            {reg, op, outs}
          else
            {reg, ptr + 2, outs}
          end

        4 ->
          val = bxor(Map.get(reg, "B"), Map.get(reg, "C"))
          {Map.put(reg, "B", val), ptr + 2, outs}

        5 ->
          val = rem(combo(op, reg), 8)
          outs = outs ++ [val]
          # if Map.get(program, 0) != Enum.at(outs, 0) do
          # {reg, 9999, outs}
          # else
          {reg, ptr + 2, outs}

        # end

        6 ->
          num = Map.get(reg, "A")
          den = 2 ** combo(op, reg)
          {Map.put(reg, "B", floor(num / den)), ptr + 2, outs}

        7 ->
          num = Map.get(reg, "A")
          den = 2 ** combo(op, reg)
          {Map.put(reg, "C", floor(num / den)), ptr + 2, outs}
      end

    # IO.inspect({reg, ptr, outs})
    if ptr >= 0 and ptr < map_size(program) do
      step(program, reg, ptr, outs)
    else
      {reg, ptr, outs}
    end
  end

  def part1(input) do
    {registers, program} = input |> parse_input() |> IO.inspect()

    {_, _, outs} = step(program, registers, 0, [])
    Enum.join(outs, ",")
  end

  def func(a) do
    # reverse engineered version of the bytecode loop
    # Only works for my real input,
    # update for samples
    b = rem(a, 8)
    b = bxor(b, 4)
    c = div(a, 2 ** b)
    b = bxor(b, c)
    b = bxor(b, 4)
    rem(b, 8)
  end

  def find(a, col, program, agent) do
    val = func(a)
    prog_at = Map.get(program, map_size(program) - (col + 1))

    cond do
      val != prog_at ->
        nil

      col == map_size(program) - 1 ->
        Agent.cast(agent, fn state -> MapSet.put(state, a) end)

      true ->
        0..8
        |> Enum.map(fn b ->
          find(a * 8 + b, col + 1, program, agent)
        end)
    end
  end

  def part2(input) do
    {_, program} = input |> parse_input() |> IO.inspect()
    {:ok, agent} = Agent.start_link(fn -> MapSet.new() end)

    0..8
    |> Enum.map(fn a ->
      find(a, 0, program, agent)
    end)

    options = Agent.get(agent, fn state -> state end)

    options
    |> Enum.map(fn o ->
      {_, _, outs} = step(program, %{"A" => o, "B" => 0, "C" => 0}, 0, [])
      {
        o,
        outs
          |> Enum.with_index()
          |> Enum.map(fn {k, v} -> {v, k} end)
          |> Map.new() == program
        }

    end)
    |> Enum.filter(fn ({_,v}) -> v end)
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.min()
  end
end

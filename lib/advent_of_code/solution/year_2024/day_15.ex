defmodule AdventOfCode.Solution.Year2024.Day15 do
  def parse_input(input, dbl \\ false) do
    [map, steps] = input |> String.trim() |> String.split("\n\n")
    map_lines = map |> String.split("\n")
    h = length(map_lines)
    w = String.length(Enum.at(map_lines, 0))
    w = if dbl, do: w * 2, else: w

    map =
      Enum.reduce(Enum.with_index(map_lines), %{}, fn {map_line, y}, map ->
        map_line
        |> String.codepoints()
        |> maybe_double(dbl)
        |> Enum.with_index()
        |> Enum.reduce(map, fn {char, x}, m ->
          m = Map.put(m, {x, y}, char)

          if char == "@" do
            Map.put(m, :bot, {x, y})
          else
            m
          end
        end)
      end)
      |> Map.put(:w, w)
      |> Map.put(:h, h)

    [map, steps |> String.replace("\n", "")]
  end

  def maybe_double(chars, true) do
    Enum.reduce(chars, "", fn char, nl ->
      nl <>
        case char do
          "#" -> "##"
          "O" -> "[]"
          "." -> ".."
          "@" -> "@."
        end
    end)
    |> String.codepoints()
  end

  def maybe_double(chars, false), do: chars

  def do_move(step, map) do
    # render(m)
    {bx, by} = Map.get(map, :bot)

    {dx, dy} =
      case step do
        "^" -> {0, -1}
        ">" -> {1, 0}
        "v" -> {0, 1}
        "<" -> {-1, 0}
      end

    moves = get_moves(map, {bx, by}, {dx, dy})

    if is_nil(moves) do
      # IO.puts("can't move #{step}")
      map
    else
      moves =
        moves
        |> Enum.uniq()
        |> Enum.sort(fn {ax, ay}, {bx, by} ->
          case step do
            "^" -> by >= ay
            "v" -> ay >= by
            ">" -> ax >= bx
            "<" -> bx >= ax
          end
        end)

      # IO.puts("Moving #{inspect(moves)}")
      map = Map.put(map, :bot, {bx + dx, by + dy})

      map =
        Enum.reduce(moves, map, fn {mx, my}, nm ->
          cur = {mx, my}
          prev = {mx + dx, my + dy}
          # IO.puts("moving #{inspect(cur)} to #{inspect(prev)}")

          nm
          |> Map.put(prev, Map.get(nm, cur))
          |> Map.put(cur, ".")
        end)

      Map.put(map, {bx, by}, ".")
    end
  end

  def solve(map, steps) do
    String.codepoints(steps)
    |> Enum.reduce(map, &do_move/2)
  end

  def solve(map) do
    render(map)
    inp = String.trim(IO.gets("move?"))
    if inp == "Q" do
      map
    else
      map = if Enum.find(["<", ">", "^", "v"], & &1 == inp) do
        do_move(inp, map)
      else
        map
      end
      solve(map)
    end
  end

  def calc(map, char) do
    all = for y <- 0..(Map.get(map, :h) - 1), x <- 0..(Map.get(map, :w) - 1), do: {x, y}

    all
    |> Enum.reduce(0, fn {x, y}, sum ->
      if Map.get(map, {x, y}) == char do
        sum + y * 100 + x
      else
        sum
      end
    end)
  end

  def render(map) do
    IO.puts("")

    for y <- 0..(Map.get(map, :h) - 1) do
      for x <- 0..(Map.get(map, :w) - 1) do
        Map.get(map, {x, y})
      end
      |> Enum.join()
      |> IO.puts()
    end

    map
  end

  def get_moves(map, {bx, by}, {dx, dy}) do
    at = Map.get(map, {bx + dx, by + dy}, "#")

    case at do
      "#" ->
        nil

      "." ->
        [{bx, by}]

      "O" ->
        next_moves = get_moves(map, {bx + dx, by + dy}, {dx, dy})
        if is_nil(next_moves), do: nil, else: [{bx, by}] ++ next_moves

      "[" ->
        if dy == 0 do
          next_moves = get_moves(map, {bx + dx, by + dy}, {dx, dy})
          if is_nil(next_moves), do: nil, else: [{bx, by}] ++ next_moves
        else
          b1 = get_moves(map, {bx + dx, by + dy}, {dx, dy})
          b2 = get_moves(map, {bx + dx + 1, by + dy}, {dx, dy})

          if is_nil(b1) or is_nil(b2) do
            nil
          else
            [{bx, by}] ++ b1 ++ b2
          end
        end

      "]" ->
        if dy == 0 do
          next_moves = get_moves(map, {bx + dx, by + dy}, {dx, dy})
          if is_nil(next_moves), do: nil, else: [{bx, by}] ++ next_moves
        else
          b1 = get_moves(map, {bx + dx, by + dy}, {dx, dy})
          b2 = get_moves(map, {bx + dx - 1, by + dy}, {dx, dy})

          if is_nil(b1) or is_nil(b2) do
            nil
          else
            [{bx, by}] ++ b1 ++ b2
          end
        end
    end
  end

  # use solve/1 for interactive mode
  def part1(input) do
    [map, steps] = input |> parse_input(input)

    map
    |> solve(steps)
    |> render()
    |> calc("O")
  end

  def part2(input) do
    [map, steps] = input |> parse_input(true)

    map
    |> solve(steps)
    |> render()
    |> calc("[")
  end
end

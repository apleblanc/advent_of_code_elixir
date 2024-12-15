defmodule AdventOfCode.Solution.Year2024.Day15 do
  def parse_input(input) do
    [map, steps] = input |> String.trim() |> String.split("\n\n")
    map_lines = map |> String.split("\n")
    h = length(map_lines)
    w = String.length(Enum.at(map_lines, 0))

    map =
      Enum.reduce(Enum.with_index(map_lines), %{}, fn {map_line, y}, map ->
        map_line
        |> String.codepoints()
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

  def double(chars) do
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

  def parse_input2(input) do
    [map, steps] = input |> String.trim() |> String.split("\n\n")
    map_lines = map |> String.split("\n")
    h = length(map_lines)
    w = String.length(Enum.at(map_lines, 0))

    map =
      Enum.reduce(Enum.with_index(map_lines), %{}, fn {map_line, y}, map ->
        map_line
        |> String.codepoints()
        |> double()
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
      |> Map.put(:w, w * 2)
      |> Map.put(:h, h)

    [map, steps |> String.replace("\n", "")]
  end

  def part1(input) do
    [map, steps] = input |> parse_input()

    String.codepoints(steps)
    |> Enum.reduce(map, fn step, m ->
      # render(m)
      {bx, by} = Map.get(m, :bot)

      {dx, dy} =
        case step do
          "^" -> {0, -1}
          ">" -> {1, 0}
          "v" -> {0, 1}
          "<" -> {-1, 0}
        end

      moves = get_moves(m, {bx, by}, {dx, dy})

      m =
        if is_nil(moves) do
          IO.puts("can't move #{step}")
          m
        else
          m = Map.put(m, :bot, {bx + dx, by + dy})

          m =
            Enum.reduce(moves..1, m, fn i, nm ->
              cur = {bx + i * dx, by + i * dy}
              prev = {bx + (i - 1) * dx, by + (i - 1) * dy}
              IO.puts("moving #{inspect(prev)} to #{inspect(cur)}")
              Map.put(nm, cur, Map.get(nm, prev))
            end)

          Map.put(m, {bx, by}, ".")
        end
    end)
    |> render()
    |> calc()
  end

  def get_moves(map, {bx, by}, {dx, dy}) do
    at = Map.get(map, {bx + dx, by + dy}, "#")

    case at do
      "#" ->
        nil

      "." ->
        1

      "O" ->
        next_moves = get_moves(map, {bx + dx, by + dy}, {dx, dy})
        if is_nil(next_moves), do: nil, else: 1 + next_moves
    end
  end

  def get_moves2(map, {bx, by}, {dx, dy}) do
    at = Map.get(map, {bx + dx, by + dy}, "#")

    cond do
      dy == 0 ->
        case at do
          "#" ->
            nil

          "." ->
            [{bx, by}]

          "[" ->
            next_moves = get_moves2(map, {bx + dx, by + dy}, {dx, dy})
            if is_nil(next_moves), do: nil, else: Enum.uniq([{bx, by}] ++ next_moves)

          "]" ->
            next_moves = get_moves2(map, {bx + dx, by + dy}, {dx, dy})
            if is_nil(next_moves), do: nil, else: Enum.uniq([{bx, by}] ++ next_moves)
        end

      true ->
        # vertical case needs to handle 2x width
        case at do
          "#" ->
            nil

          "." ->
            [{bx, by}]

          "[" ->
            b1 = get_moves2(map, {bx + dx, by + dy}, {dx, dy})
            b2 = get_moves2(map, {bx + dx + 1, by + dy}, {dx, dy})

            if is_nil(b1) or is_nil(b2) do
              nil
            else
              Enum.uniq([{bx, by}] ++ b1 ++ b2)
            end

          "]" ->
            b1 = get_moves2(map, {bx + dx, by + dy}, {dx, dy})
            b2 = get_moves2(map, {bx + dx - 1, by + dy}, {dx, dy})

            if is_nil(b1) or is_nil(b2) do
              nil
            else
              Enum.uniq([{bx, by}] ++ b1 ++ b2)
            end
        end
    end
  end

  def calc(map) do
    all = for y <- 0..(Map.get(map, :h) - 1), x <- 0..(Map.get(map, :w) - 1), do: {x, y}

    all
    |> Enum.reduce(0, fn {x, y}, sum ->
      if Map.get(map, {x, y}) == "O" do
        sum + y * 100 + x
      else
        sum
      end
    end)
  end

  def calc2(map) do
    all = for y <- 0..(Map.get(map, :h) - 1), x <- 0..(Map.get(map, :w) - 1), do: {x, y}

    all
    |> Enum.reduce(0, fn {x, y}, sum ->
      if Map.get(map, {x, y}) == "[" do
        sum + y * 100 + x
      else
        sum
      end
    end)
  end

  def render(map) do
    IO.puts("")

    for y <- 0..(Map.get(map, :h) - 1) do
      line =
        for x <- 0..(Map.get(map, :w) - 1) do
          Map.get(map, {x, y})
        end
        |> Enum.join()
        |> IO.puts()
    end

    map
  end

  def part2(input) do
    [map, steps] = input |> parse_input2()
    IO.puts("initial")
    render(map)

    String.codepoints(steps)
    |> Enum.reduce(map, fn step, m ->
      # IO.puts("Trying to move #{step}")
      # render(m)
      {bx, by} = Map.get(m, :bot)

      {dx, dy} =
        case step do
          "^" -> {0, -1}
          ">" -> {1, 0}
          "v" -> {0, 1}
          "<" -> {-1, 0}
        end

      moves = get_moves2(m, {bx, by}, {dx, dy})

      m =
        if is_nil(moves) do
          # IO.puts("can't move #{step}")
          m
        else
          moves =
            moves
            |> Enum.sort(fn {ax, ay}, {bx, by} ->
              case step do
                "^" -> by >= ay
                "v" -> ay >= by
                ">" -> ax >= bx
                "<" -> bx >= ax
              end
            end)

          # IO.puts("Moving #{inspect(moves)}")
          m = Map.put(m, :bot, {bx + dx, by + dy})

          m =
            Enum.reduce(moves, m, fn {mx, my}, nm ->
              cur = {mx, my}
              prev = {mx + dx, my + dy}
              # IO.puts("moving #{inspect(cur)} to #{inspect(prev)}")

              nm
              |> Map.put(prev, Map.get(nm, cur))
              |> Map.put(cur, ".")
            end)

          Map.put(m, {bx, by}, ".")
        end
    end)
    |> render()
    |> calc2()
  end
end

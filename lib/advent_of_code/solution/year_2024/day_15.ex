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

  def solve(map, steps, do_render \\ false) do
    max = String.length(steps)
    String.codepoints(steps)
    |> Enum.with_index()
    |> Enum.reduce(map, fn {inp, idx}, m ->
      map = do_move(inp, m)
      if do_render do
        render(map, IO.ANSI.light_cyan() <> "[" <> IO.ANSI.cyan() <> "#{idx+1}" <> IO.ANSI.light_cyan() <> "/" <> IO.ANSI.cyan() <> "#{max}" <> IO.ANSI.light_cyan() <> "] " <> IO.ANSI.yellow() <> inp <>"\n")
      else
        map
      end
  end)
  end

  def solve(map) do
    render(map)
    IO.write("\n\n"<>IO.ANSI.cursor_up(1))

    inp = String.trim(IO.gets("Move (W/A/S/D)? "))
    if inp == "Q" do
      map
    else
      map = if inp != "" and "wasd" =~ inp do
        do_move(Map.get(%{"w" => "^", "a" => "<", "s" => "v", "d" => ">"}, inp), map)
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


  def render(map, header \\ "") do
    IO.write("\x1b[?25l")
    output = for y <- 0..(Map.get(map, :h) - 1) do
      for x <- 0..(Map.get(map, :w) - 1) do
        case Map.get(map, {x, y}) do
          "@" -> IO.ANSI.format([:light_cyan, :bright, "@", :reset])
          "#" -> IO.ANSI.format([:red_background, " ", :reset])
          "." -> IO.ANSI.format([:light_black, "·", :reset])
          "[" -> IO.ANSI.format([:green, "["])
          "]" -> IO.ANSI.format([:green, "]", :reset])
          char -> char
        end
      end
      |> Enum.join()
    end
    |> Enum.join("\n")
    IO.write(IO.ANSI.cursor(0, 0) <> IO.ANSI.clear_line() <> header <> output)
    IO.write("\x1b[?25h")
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
    [map, steps] = input |> parse_input()

    map
    |> solve(steps)
    |> calc("O")
  end

  def part2(input) do
    [map, steps] = input |> parse_input(true)

    map
    |> solve(steps)
    |> calc("[")
  end
end

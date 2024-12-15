defmodule AdventOfCode.Solution.Year2024.Day06 do
  def parse_input(input) do
    field =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.codepoints/1)

    mx = length(Enum.at(field, 0)) - 1
    my = length(field) - 1

    points = for y <- 0..my, x <- 0..mx, do: {x, y}

    obstacles =
      points
      |> Enum.filter(&(getch(field, &1) == "#"))
      |> MapSet.new()

    {sx, sy} =
      Enum.find(points, &(getch(field, &1) in ["^", "v", "<", ">"]))

    {dx, dy} =
      %{"v" => {0, 1}, "^" => {0, -1}, "<" => {-1, 0}, ">" => {1, 0}}
      |> Map.get(getch(field, {sx, sy}))

    {{sx, sy}, {dx, dy}, {mx, my}, obstacles}
  end

  def getch(field, {x, y}), do: Enum.at(Enum.at(field, y), x)

  def next_dir({0, 1}), do: {-1, 0}
  def next_dir({0, -1}), do: {1, 0}
  def next_dir({1, 0}), do: {0, 1}
  def next_dir({-1, 0}), do: {0, -1}

  def get_path({x, y}, {dx, dy} = dir, {mx, my} = max, obstacles, visited) do
    visited = MapSet.put(visited, {x, y})
    {nx, ny} = {x + dx, y + dy}

    cond do
      nx < 0 or ny < 0 or nx > mx or ny > my ->
        visited

      MapSet.member?(obstacles, {nx, ny}) ->
        dir = next_dir(dir)
        get_path({x, y}, dir, max, obstacles, visited)

      true ->
        get_path({nx, ny}, dir, max, obstacles, visited)
    end
  end

  def will_loop({sx, sy} = start, {dx, dy} = dir, {mx, my} = max, obstacles, visited) do
    {nx, ny} = {sx + dx, sy + dy}

    cond do
      nx < 0 or ny < 0 or nx > mx or ny > my ->
        false

      MapSet.member?(obstacles, {nx, ny}) ->
        will_loop(start, next_dir(dir), max, obstacles, visited)

      MapSet.member?(visited, {nx, ny, dx, dy}) ->
        true

      true ->
        visited = MapSet.put(visited, {nx, ny, dx, dy})
        will_loop({nx, ny}, dir, max, obstacles, visited)
    end
  end

  def part1(input) do
    {start, dir, max, obstacles} = parse_input(input)

    get_path(start, dir, max, obstacles, MapSet.new([]))
    |> MapSet.size()
  end

  def part2(input) do
    {start, dir, max, obstacles} = parse_input(input)

    get_path(start, dir, max, obstacles, MapSet.new())
    |> Enum.map(fn point ->
      Task.async(fn ->
        cond do
          point == start ->
            false

          MapSet.member?(obstacles, point) ->
            false

          true ->
            obstacles = MapSet.put(obstacles, point)
            will_loop(start, dir, max, obstacles, MapSet.new())
        end
      end)
    end)
    |> Enum.count(&Task.await/1)
  end
end

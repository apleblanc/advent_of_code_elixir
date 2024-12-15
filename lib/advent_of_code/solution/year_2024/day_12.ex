defmodule AdventOfCode.Solution.Year2024.Day12 do
  def parse_input(input) do
    lines = input |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)
    h = length(lines)
    w = length(Enum.at(lines, 0))
    points = for y <- 0..(h - 1), x <- 0..(w - 1), do: {x, y}

    Enum.reduce(points, %{}, fn {x, y}, acc ->
      Map.put(acc, {x, y}, Enum.at(Enum.at(lines, y), x))
    end)
    |> Map.put(:width, w)
    |> Map.put(:height, h)
  end

  def get_neighbours({x, y}, grid) do
    w = Map.get(grid, :width)
    h = Map.get(grid, :height)

    [{-1, 0}, {1, 0}, {0, 1}, {0, -1}]
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.reject(fn {px, py} -> px < 0 or py < 0 or px >= w or py >= h end)
  end

  def get_all_neighbours({x, y}) do
    [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
  end

  def find_region_dims({x, y}, grid, agent) do
    neighbours =
      get_neighbours({x, y}, grid)
      |> Enum.filter(fn pt -> Map.get(grid, pt) == Map.get(grid, {x, y}) end)

    perim = 4 - length(neighbours)

    Agent.update(agent, fn state ->
      state = MapSet.put(state, {x, y})
      state
    end)

    neighbours
    |> Enum.reduce({1, perim}, fn n, {a, p} ->
      already_visited = Agent.get(agent, fn state -> MapSet.member?(state, n) end)

      if already_visited do
        {a, p}
      else
        {a2, p2} = find_region_dims(n, grid, agent)
        {a + a2, p + p2}
      end
    end)
  end

  def count_corners({x, y}, grid) do
    # IO.puts("Counting corners at #{x} #{y}")
    neighbours = get_all_neighbours({x, y})

    neighbours
    |> Enum.chunk_every(2, 1, [Enum.at(neighbours, 0)])
    |> Enum.map(fn [{p1x, p1y} = p1, {p2x, p2y} = p2] ->
      {d1x, d1y} = {p1x - x, p1y - y}
      {d2x, d2y} = {p2x - x, p2y - y}
      kitty = {x + d1x + d2x, y + d1y + d2y}
      val = Map.get(grid, {x, y})
      ext = Map.get(grid, p1) != val and Map.get(grid, p2) != val

      cond do
        ext ->
          # IO.puts("#{x} #{y} #{d1x},#{d1y}/#{d2x},#{d2y} is an external corner")
          1
        Map.get(grid, kitty) != val and Map.get(grid, p1) == val and Map.get(grid, p2) == val ->
          # IO.puts("#{x} #{y} #{d1x},#{d1y}/#{d2x},#{d2y} is an internal corner")
          1
        true -> 0
      end
    end)
    |> Enum.sum()
    # |> IO.inspect(label: "#{x},#{y} corners")
  end

  def find_region_dims2({x, y}, grid, agent) do
    corners = count_corners({x, y}, grid)

    neighbours =
      get_neighbours({x, y}, grid)
      |> Enum.filter(fn pt -> Map.get(grid, pt) == Map.get(grid, {x, y}) end)

    Agent.update(agent, fn state ->
      state = MapSet.put(state, {x, y})
      state
    end)

    neighbours
    |> Enum.reduce({1, corners}, fn n, {a, c} ->
      already_visited = Agent.get(agent, fn state -> MapSet.member?(state, n) end)

      if already_visited do
        {a, c}
      else
        {a2, p2} = find_region_dims2(n, grid, agent)
        {a + a2, c + p2}
      end
    end)
  end

  def part1(input) do
    {:ok, agent} = Agent.start_link(fn -> MapSet.new() end)
    grid = parse_input(input)
    w = Map.get(grid, :width)
    h = Map.get(grid, :height)

    for y <- 0..(h - 1), x <- 0..(w - 1) do
      {x, y}
    end
    |> Enum.reduce(0, fn pt, region_dims ->
      if Agent.get(agent, fn state -> MapSet.member?(state, pt) end) do
        region_dims
      else
        {a, p} = find_region_dims(pt, grid, agent)
        region_dims + a * p
      end
    end)
  end

  def part2(input) do
    {:ok, agent} = Agent.start_link(fn -> MapSet.new() end)
    grid = parse_input(input)
    w = Map.get(grid, :width)
    h = Map.get(grid, :height)
    # count_corners({0, 0}, grid)
    for y <- 0..(h - 1), x <- 0..(w - 1) do
      {x, y}
    end
    |> Enum.reduce(0, fn pt, region_dims ->
      if Agent.get(agent, fn state -> MapSet.member?(state, pt) end) do
        region_dims
      else
        {a, p} = find_region_dims2(pt, grid, agent)
        # IO.puts("region at #{inspect(pt)} has area #{a} and corners #{p}")
        region_dims + a * p
      end
    end)
  end
end

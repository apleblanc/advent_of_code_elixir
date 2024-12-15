defmodule AdventOfCode.Solution.Year2024.Day10 do
  def parse_input(input) do
    grid = input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> String.codepoints(line) |> Enum.map(&String.to_integer/1) end)

    h = length(grid)-1
    w = length(Enum.at(grid, 0))-1
    points = for y <- 0..h, x <- 0..w, do: {x, y}
    points |> Enum.reduce({%{}, []}, fn ({x, y}, {map, heads}) ->
      val = Enum.at(Enum.at(grid, y), x)
      map = Map.put(map, {x, y}, val)
      heads = if val == 0, do: heads ++ [{x, y}], else: heads
      {map
      |> Map.put("w", w)
      |> Map.put("h", h), heads}
    end)
  end

  def trail_score({x, y}, grid) do
    if Map.get(grid, {x, y}) == 9 do
      # IO.puts("found a 9 at #{x} #{y}")
      [{x,y}]
    else
      getneighbours({x, y}, {Map.get(grid, "w"), Map.get(grid, "h")})
      |> Enum.filter(fn {nx, ny} ->
        Map.get(grid, {nx, ny}) == Map.get(grid, {x, y}) + 1
      end)
      |> Enum.flat_map(fn {nx, ny} ->
        # IO.puts("going from #{x},#{y} (#{Map.get(grid, {x, y})}) to #{nx},#{ny} (#{Map.get(grid, {nx, ny})})")
        trail_score({nx, ny}, grid)
      end)
    end
  end

  def getneighbours({x, y}, {mx, my}) do
    [{x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}] |> Enum.reject(fn {x_, y_} ->
      x_ < 0 or y_ < 0 or y_ > my or x_ > mx
    end)
  end

  def part1(input) do
    {grid, heads} = input |> parse_input()
    Enum.map(heads, fn {x, y} ->
      trail_score({x, y}, grid)
      |> Enum.uniq()
      |> length()
    end)
    |> Enum.sum()
  end

  def trail_rating({x, y}, grid) do

    if Map.get(grid, {x, y}) == 9 do
      # IO.puts("found a 9 at #{x} #{y}")
      1
    else
      getneighbours({x, y}, {Map.get(grid, "w"), Map.get(grid, "h")})
      |> Enum.filter(fn {nx, ny} ->
        Map.get(grid, {nx, ny}) == Map.get(grid, {x, y}) + 1
      end)
      |> Enum.map(fn {nx, ny} ->
        trail_rating({nx, ny}, grid)
      end)
      |> Enum.sum()
    end

  end

  def part2(input) do
    {map, heads} = parse_input(input)
    Enum.map(heads, fn {x, y} ->
      trail_rating({x, y}, map)
    end)
    |> Enum.sum()
  end
end

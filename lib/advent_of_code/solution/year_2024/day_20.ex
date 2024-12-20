defmodule AdventOfCode.Solution.Year2024.Day20 do
  def parse_input(input) do
    lines = input |> String.trim() |> String.split("\n")
    h = length(lines)
    w = String.length(Enum.at(lines, 0))
    points = for y <- 0..h-1, x <- 0..w-1, do: {x, y}
    {map, start_pt, end_pt} = Enum.reduce(points, {%{}, nil, nil}, fn ({x, y}, {map, s, e}) ->
      char = String.at(Enum.at(lines, y), x)
      case char do
        "." -> {Map.put(map, {x, y}, true), s, e}
        "S" -> {Map.put(map, {x, y}, true), {x, y}, e}
        "E" -> {Map.put(map, {x, y}, true), s, {x, y}}
        "#" -> {map, s, e}
      end
    end)
    {map, start_pt, end_pt, w, h}
  end

  def get_path(map, s, e, _visited) when s == e, do: []
  def get_path(map, {sx, sy}, {ex, ey}, visited) do
    next = [{0, 1}, {0, -1}, {1, 0}, {-1, 0}] |> Enum.map(fn ({dx, dy}) -> {sx + dx, sy + dy} end) |> Enum.filter(fn pt ->
      cond do
        MapSet.member?(visited, pt) -> false
        not Map.has_key?(map, pt) -> false
        true -> true
      end
    end) |> List.first()
    [next] ++ get_path(map, next, {ex, ey}, MapSet.put(visited, {sx, sy}))
  end

  def sort_points({ax, ay}, {bx, by}) do
    [{ax, ay}, {bx, by}] |> Enum.sort(fn ({ax, ay}, {bx, by}) -> ax + ay < bx + by end) |> List.to_tuple()
  end

  def part1(input) do
    {map, s, e, w, h} = input |> parse_input()
    path = [s] ++ get_path(map, s, e, MapSet.new())
    path_index = path |> Enum.with_index() |> Map.new(fn {{px, py}, i} -> {i, {px, py}} end)

    l = length(path)
    IO.puts("Path Len: #{inspect(List.first(path))}->#{inspect(List.last(path))} #{l}")

    0..l-1 |> Enum.reduce(MapSet.new(), fn (ip, acc) ->
      {px, py} = Map.get(path_index, ip)
      ip..l-1 |> Enum.reduce(acc, fn (io, acc) ->
        {ox, oy} = Map.get(path_index, io)
        dist = abs(ox - px) + abs(oy - py)
        if dist <= 2 and abs(ip - io) > dist do
          MapSet.put(acc, {sort_points({px, py}, {ox, oy}), abs(ip - io) - dist})
        else
          acc
        end
      end)
    end)

    |> Enum.filter(fn ({_, score}) -> score >= 100 end)
    |> Enum.count()

  end

  def part2(input) do
    {map, s, e, w, h} = input |> parse_input()
    path = [s] ++ get_path(map, s, e, MapSet.new())
    path_index = path |> Enum.with_index() |> Map.new(fn {{px, py}, i} -> {i, {px, py}} end)

    l = length(path)
    IO.puts("Path Len: #{inspect(List.first(path))}->#{inspect(List.last(path))} #{l}")

    0..l-1 |> Enum.reduce(MapSet.new(), fn (ip, acc) ->
      {px, py} = Map.get(path_index, ip)
      ip..l-1 |> Enum.reduce(acc, fn (io, acc) ->
        {ox, oy} = Map.get(path_index, io)
        dist = abs(ox - px) + abs(oy - py)
        if dist <= 20 and abs(ip - io) > dist do
          MapSet.put(acc, {sort_points({px, py}, {ox, oy}), abs(ip - io) - dist})
        else
          acc
        end
      end)
    end)

    |> Enum.filter(fn ({_, score}) -> score >= 100 end)
    |> Enum.count()

  end
end

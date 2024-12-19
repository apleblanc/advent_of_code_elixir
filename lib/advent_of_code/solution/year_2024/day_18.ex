defmodule AdventOfCode.Solution.Year2024.Day18 do
  @up {0, -1}
  @down {0, 1}
  @left {-1, 0}
  @right {1, 0}

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      String.split(line, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  def shortest_path(map, w, h) do
    points = for y <- 0..(h - 1), x <- 0..(w - 1), do: {x, y}

    graph = points
    |> Enum.reduce(%{}, fn {x, y}, graph ->
      neighbours =
        [@up, @down, @left, @right]
        |> Enum.map(fn {dx, dy} -> {{x + dx, y + dy}, 1} end)
        |> Enum.reject(fn {{x, y}, _d} ->
          x < 0 or y < 0 or x >= w or y >= h or Map.get(map, {x, y})
        end)
      Map.put(graph, {x, y}, neighbours)
    end)

    distances = Map.new(graph, fn {node, _} -> {node, :infinity} end) |> Map.put({0, 0}, 0)
    queue = %{{0, 0} => 0}
    dijkstra(graph, distances, queue)
  end

  def dijkstra(_graph, distances, queue) when map_size(queue) == 0, do: {distances, queue}

  def dijkstra(graph, distances, queue) do
    {current_node, current_distance} = Enum.min_by(queue, fn {_, distance} -> distance end)
    queue = Map.delete(queue, current_node)

    {distances, queue} =
      Enum.reduce(
        graph[current_node] || [],
        {distances, queue},
        fn {neighbour, weight}, {distances, queue} ->
          new_distance = current_distance + weight

          cond do
            new_distance <= Map.get(distances, neighbour, :infinity) ->
              updated_distances = Map.put(distances, neighbour, new_distance)
              updated_queue = Map.put(queue, neighbour, new_distance)
              {updated_distances, updated_queue}

            true ->
              {distances, queue}
          end
        end
      )
      dijkstra(graph, distances, queue)
  end

  def part1(input) do
    w = 71
    h = 71
    blocks = input |> parse_input()

    map =
      blocks
      |> Enum.take(1024)
      |> Enum.reduce(%{}, fn b, map ->
        Map.put(map, b, true)
      end)
      # |> render(w, h)

    {distances, _} = shortest_path(map, w, h)
    distances[{w-1, h-1}]
    # distances |> Map.values() |> Enum.reject(& &1 == :infinity) |> Enum.min()
  end

  def render(map, w, h) do
    IO.puts("")

    for y <- 0..(h - 1) do
      IO.puts(
        Enum.join(
          0..(w - 1)
          |> Enum.map(fn x ->
            if Map.get(map, {x, y}, false), do: "#", else: "."
          end),
          ""
        )
      )
    end
  end

  def tryit(_map, _w, _h, []), do: nil

  def tryit(map, w, h, [block | blocks]) do
    map = Map.put(map, block, true)
    {distances, _} = shortest_path(map, w, h)
    if distances[{w-1, h-1}] < :infinity do
      tryit(map, w, h, blocks)
    else
      block
    end

      # |> render(w, h)
  end

  def part2(input) do
    w = 71
    h = 71
    blocks = input |> parse_input()
    tryit(%{}, w, h, blocks)

  end
end

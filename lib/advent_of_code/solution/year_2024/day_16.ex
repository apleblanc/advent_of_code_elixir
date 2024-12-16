defmodule AdventOfCode.Solution.Year2024.Day16 do
  def parse_input(input) do
    lines = input |> String.trim() |> String.split("\n") |> Enum.map(&String.codepoints/1)
    w = length(Enum.at(lines, 0))
    h = length(lines)

    points = for y <- 0..(h - 1), x <- 0..(w - 1), do: {x, y}

    maze =
      points
      |> Enum.reduce(%{}, fn {x, y}, map ->
        at = Enum.at(Enum.at(lines, y), x)

        if at != "#" do
          map = Map.put(map, {x, y}, true)

          map =
            if at == "S" do
              Map.put(map, :start, {x, y})
            else
              map
            end

          if at == "E" do
            Map.put(map, :end, {x, y})
          else
            map
          end
        else
          map
        end
      end)

    maze
  end

  def turn({1, 0}, :cw), do: {0, 1}
  def turn({0, 1}, :cw), do: {-1, 0}
  def turn({-1, 0}, :cw), do: {0, -1}
  def turn({0, -1}, :cw), do: {1, 0}

  def turn({1, 0}, :ccw), do: {0, -1}
  def turn({0, -1}, :ccw), do: {-1, 0}
  def turn({-1, 0}, :ccw), do: {0, 1}
  def turn({0, 1}, :ccw), do: {1, 0}

  def build_graph(maze) do
    maze
    |> Enum.filter(fn {k, _} -> k not in [:start, :end] end)
    |> Enum.reduce(%{}, fn {{x, y}, true}, acc ->
      [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
      |> Enum.reduce(acc, fn {dx, dy} = d, a ->
        Map.put(
          a,
          {{x, y}, d},
          [
            {{{x, y}, turn(d, :cw)}, 1000},
            {{{x, y}, turn(d, :ccw)}, 1000},
            {{{x + dx, y + dy}, {dx, dy}}, 1}
          ]
          |> Enum.filter(fn {{{x, y}, _}, _} ->
            Map.has_key?(maze, {x, y})
          end)
        )
      end)
    end)
  end

  def shortest_paths(maze, source) do
    graph = build_graph(maze)
    distances = Map.new(graph, fn {node, _} -> {node, :infinity} end) |> Map.put(source, 0)
    paths = Map.new(graph, fn {node, _} -> {node, []} end) |> Map.put(source, [[source]])
    queue = %{source => 0}
    dijkstra(graph, distances, paths, queue)
  end

  defp dijkstra(_, distances, paths, queue) when map_size(queue) == 0, do: {distances, paths}

  defp dijkstra(graph, distances, paths, queue) do
    {current_node, current_distance} = Enum.min_by(queue, fn {_, distance} -> distance end)
    queue = Map.delete(queue, current_node)

    {distances, paths, queue} =
      Enum.reduce(
        graph[current_node] || [],
        {distances, paths, queue},
        fn {neighbour, weight}, {distances, paths, queue} ->
          new_distance = current_distance + weight

          cond do
            new_distance < Map.get(distances, neighbour, :infinity) ->
              updated_distances = Map.put(distances, neighbour, new_distance)

              updated_paths =
                Map.put(
                  paths,
                  neighbour,
                  Enum.map(paths[current_node], fn path -> path ++ [neighbour] end)
                )

              updated_queue = Map.put(queue, neighbour, new_distance)
              {updated_distances, updated_paths, updated_queue}

            new_distance == Map.get(distances, neighbour) ->
              new_paths = Enum.map(paths[current_node], fn path -> path ++ [neighbour] end)

              updated_paths =
                Map.update!(paths, neighbour, fn existing_paths -> existing_paths ++ new_paths end)

              updated_queue = Map.put(queue, neighbour, new_distance)
              {distances, updated_paths, updated_queue}

            true ->
              {distances, paths, queue}
          end
        end
      )

    dijkstra(graph, distances, paths, queue)
  end

  def part1(input) do
    maze = input |> parse_input()
    {distances, _} = shortest_paths(maze, {maze[:start], {1, 0}})

    distances
    |> Enum.filter(fn {{p, _}, _} ->
      p == maze[:end]
    end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.min()
  end

  def part2(input) do
    maze = input |> parse_input()
    {distances, paths} = shortest_paths(maze, {maze[:start], {1, 0}})

    distances =
      distances
      |> Enum.filter(fn {{p, _}, _} ->
        p == maze[:end]
      end)
      |> Enum.sort(fn {_, v1}, {_, v2} -> v1 <= v2 end)

    min_dist = List.first(distances) |> elem(0)
    paths = Map.get(paths, min_dist)

    paths
    |> Enum.map(fn p ->
      Enum.map(p, fn {k, _} -> k end)
    end)
    |> Enum.flat_map(fn p ->
      p
    end)
    |> Enum.uniq()
    |> length()
  end
end

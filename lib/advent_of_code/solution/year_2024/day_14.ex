defmodule AdventOfCode.Solution.Year2024.Day14 do
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, px, py, vx, vy] = Regex.run(~r/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/, line)

      {{String.to_integer(px), String.to_integer(py)},
       {String.to_integer(vx), String.to_integer(vy)}}
    end)
  end

  def part1(input) do
    w = 101
    h = 103
    iters = 100
    hw = floor(w / 2)
    hh = floor(h / 2)

    parse_input(input)
    |> Enum.reduce(%{}, fn {{px, py}, {vx, vy}}, acc ->
      {nx, ny} = {rem(px + vx * iters, w), rem(py + vy * iters, h)}

      nx =
        if nx < 0 do
          w + nx
        else
          nx
        end

      ny =
        if ny < 0 do
          h + ny
        else
          ny
        end

      # IO.inspect({nx, ny}, label: "pos")

      quad =
        cond do
          nx < hw and ny < hh -> 0
          nx < hw and ny > hh -> 1
          nx > hw and ny < hh -> 2
          nx > hw and ny > hh -> 3
          true -> nil
        end

      if is_nil(quad) do
        acc
      else
        val = Map.get(acc, quad, 0) + 1
        Map.put(acc, quad, val)
      end
    end)
    |> Map.values()
    |> Enum.reduce(fn v, acc -> v * acc end)
  end

  def do_second(robots, w, h) do
    robots
    |> Enum.reduce([], fn {{px, py}, {vx, vy}}, newbots ->
      {nx, ny} = {rem(px + vx, w), rem(py + vy, h)}

      nx =
        if nx < 0 do
          w + nx
        else
          nx
        end

      ny =
        if ny < 0 do
          h + ny
        else
          ny
        end

      newbots ++ [{{nx, ny}, {vx, vy}}]
    end)
  end

  def find_cycle(robots, w, h, iter \\ 0, cache \\ %{}) do
    cache = Map.put(cache, robots, iter)
    robots = do_second(robots, w, h)

    if Map.has_key?(cache, robots) do
      cache
    else
      find_cycle(robots, w, h, iter + 1, cache)
    end
  end

  def render(robots, iter, w, h) do
    grid =
      robots
      |> Enum.reduce(%{}, fn {{rx, ry}, _}, grid ->
        val = Map.get(grid, {rx, ry}, 0) + 1
        Map.put(grid, {rx, ry}, val)
      end)

    IO.puts("Iter #{iter}")

    for y <- 0..h do
      line =
        for x <- 0..w do
          if Map.has_key?(grid, {x, y}), do: "#", else: " "
        end
        |> Enum.join()

      IO.puts(line)
    end

    robots
  end

  def get_symmetry_score(robots, w, h) do
    grid =
      robots
      |> Enum.reduce(%{}, fn {{rx, ry}, _}, grid ->
        val = Map.get(grid, {rx, ry}, 0) + 1
        Map.put(grid, {rx, ry}, val)
      end)

    cx = floor(w / 2)
    cy = floor(h / 2)
    ys = floor(cy / 4)

    y_min = cy - ys
    y_max = cy + ys
    y_min..y_max
    |> Enum.map(fn y ->
      0..w
      |> Enum.map(fn x ->
        a = Map.get(grid, {cx + x, y})
        b = Map.get(grid, {cx - x, y})

        cond do
          is_nil(a) or is_nil(b) -> 0
          a == b -> 1
          true -> 0
        end
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def part2(input) do
    w = 101
    h = 103

    {_score, {iter, state}} =
      input
      |> parse_input()
      |> find_cycle(w, h)
      |> Enum.map(fn {state, iter} ->
        {get_symmetry_score(state, w, h), {iter, state}}
      end)
      |> Enum.max(fn {k1, _}, {k2, _} -> k1 >= k2 end)

    render(state, iter, w, h)
    iter
  end
end

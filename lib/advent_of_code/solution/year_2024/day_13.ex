alias Decimal

defmodule AdventOfCode.Solution.Year2024.Day13 do
  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn chunk ->
      [a, b, prize] = chunk |> String.trim() |> String.split("\n")
      [_, ax, ay] = Regex.run(~r/Button [AB]: X\+(\d+), Y\+(\d+)/, a)
      [_, bx, by] = Regex.run(~r/Button [AB]: X\+(\d+), Y\+(\d+)/, b)
      [_, px, py] = Regex.run(~r/Prize: X=(\d+), Y=(\d+)/, prize)

      {{String.to_integer(ax), String.to_integer(ay)},
       {String.to_integer(bx), String.to_integer(by)},
       {String.to_integer(px), String.to_integer(py)}}
    end)
  end

  def compute({ax, ay}, {bx, by}, {px, py}, bcount) do
    tx = bx * bcount
    ty = by * bcount
    acount = get_max({ax, ay}, {px - tx, py - ty})
    {x, y} = {ax * acount + bx * bcount, ay * acount + by * bcount}

    cond do
      {x, y} == {px, py} -> acount * 3 + bcount
      bcount == 0 -> 0
      true -> compute({ax, ay}, {bx, by}, {px, py}, bcount - 1)
    end
  end

  def get_max({mx, my}, {px, py}) do
    # IO.puts("#{px} #{mx}")
    x = floor(px / mx)
    y = floor(py / my)
    min(x, y)
  end


  def compute2({ax, ay}, {bx, by}, {px, py}) do
    mult1 = (px / ax)
    mult2 = (px / bx)

    x1 = 0
    y1 = 0
    x2 = ax * mult1
    y2 = ay * mult1
    x3 = px
    y3 = py
    x4 = px - (bx * mult2)
    y4 = py - (by * mult2)

    dx1 = x2 - x1
    dy1 = y2 - y1
    dx2 = x4 - x3
    dy2 = y4 - y3

    det = dx1 * dy2 - dy1 * dx2

    if det == 0 do
      0
    else

      t = ((x3 - x1) * dy2 - (y3 - y1) * dx2) / det
      u = ((x3 - x1) * dy1 - (y3 - y1) * dx1) / det

      if t >= 0 and t <= 1 and u >= 0 and u <= 1 do
        ix = x1 + t * dx1

          a = ix / ax
          b = (px - ix) / bx
          if Decimal.eq?(Decimal.from_float(a), round(a), "0.001") and Decimal.eq?(Decimal.from_float(b), round(b), "0.001") do
            round(a) * 3 + round(b)
          else
            0
          end
      else
        0
      end
    end
  end


  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {a, b, p} ->
      compute2(a, b, p)
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(fn {a, b, {px, py}} ->
      Task.async(fn ->
        p = {px + 10_000_000_000_000, py + 10_000_000_000_000}
        compute2(a, b, p)
      end)
    end)
    |> Task.await_many(:infinity)
    |> Enum.sum()
  end
end

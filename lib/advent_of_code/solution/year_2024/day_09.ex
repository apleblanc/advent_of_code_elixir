defmodule AdventOfCode.Solution.Year2024.Day09 do
  def parse_input(input) do
    input |> String.trim() |> String.codepoints()
  end

  def expand(s) do
    s
    |> Enum.with_index()
    |> Enum.flat_map(fn {t, i} ->
      if rem(i, 2) == 0 do
        List.duplicate("#{floor(i / 2)}", String.to_integer(t))
      else
        List.duplicate(".", String.to_integer(t))
      end
    end)
  end

  def defrag(disk_map, l, space_idx \\ nil, file_idx \\ nil) do
    space_idx =
      if is_nil(space_idx), do: -1, else: space_idx

    file_idx =
      if is_nil(file_idx), do: l, else: file_idx

    space_idx =
      (space_idx + 1)..(file_idx - 1)
      |> Enum.find(&(Map.get(disk_map, &1) == ".")) || -1

    file_idx =
      (file_idx - 1)..(space_idx + 1)
      |> Enum.find(&(Map.get(disk_map, &1) != ".")) || -1

    cond do
      file_idx == -1 or space_idx == -1 -> disk_map
      file_idx < space_idx -> disk_map
      true ->
        disk_map = disk_map
        |> Map.put(space_idx, Map.get(disk_map, file_idx))
        |> Map.put(file_idx, ".")
        defrag(disk_map, l, space_idx, file_idx)
    end
  end

  def expand2(s) do
    s
    |> Enum.with_index()
    |> Enum.map(fn {t, i} ->
      id = if rem(i, 2) == 0, do: floor(i / 2), else: nil
      {id, String.to_integer(t)}
    end)
    |> Enum.reject(fn {i, s} -> is_nil(i) and s == 0 end)
  end

  def defrag2(in_disk) do
    files = in_disk |> Enum.reject(fn {id, _} -> is_nil(id) end) |> Enum.reverse()

    Enum.reduce(files, in_disk, fn {id, size}, disk ->
      # IO.inspect(disk)
      idx = Enum.find_index(disk, fn {i, _s} -> i == id end)
      # IO.puts("found #{id} at #{idx}")
      case disk
           |> Enum.with_index()
           |> Enum.find(fn {{i, s}, sidx} -> is_nil(i) and s >= size and sidx < idx end) do
        {{_, ^size}, space_idx} ->
          # IO.puts("perfect fit")
          disk
          |> List.replace_at(space_idx, {id, size})
          |> List.replace_at(idx, {nil, size})
          |> compact_space()

        {{_, space_size}, space_idx} ->
          # IO.puts("leftover")
          disk
          |> List.replace_at(idx, {nil, size})
          |> List.replace_at(space_idx, {nil, space_size - size})
          |> List.insert_at(space_idx, {id, size})
          |> compact_space()

        nil ->
          disk
      end
    end)
  end

  def compact_space([{nil, space_size_1}, {nil, space_size_2} | disk]) do
    compact_space([{nil, space_size_1 + space_size_2}] ++ disk)
  end

  def compact_space([h | disk]), do: [h] ++ compact_space(disk)

  def compact_space([]), do: []

  def part1(input) do
    disk =
      input
      |> parse_input()
      |> expand()

    l = length(disk)

    disk_map =
      disk
      |> Enum.with_index()
      |> Enum.map(fn {k, v} -> {v, k} end)
      |> Map.new()

    disk_map = defrag(disk_map, l)

    0..l-1 |> Enum.map(fn i ->
      b = Map.get(disk_map, i)
      cond do
        b == "." -> 0
        true ->
          String.to_integer(b) * i
      end
    end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> parse_input()
    |> expand2()
    # |> IO.inspect(label: :first)
    |> defrag2()
    # |> IO.inspect(label: :out)
    |> Enum.reduce({0, 0}, fn {id, size}, {idx, sum} ->
      val =
        if is_nil(id) or id == 0 do
          0
        else
          idx..(idx + size - 1)
          |> Enum.map(&(&1 * id))
          |> Enum.sum()
        end

      {idx + size, sum + val}
    end)
    |> elem(1)

  end
end

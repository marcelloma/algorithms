defmodule OneMax do
  @chromossome_size 1000

  defp generate_gene(), do: :rand.uniform(2) - 1

  defp generate_chromossome(),
    do: Stream.repeatedly(&generate_gene/0) |> Stream.take(@chromossome_size)

  defp generate_population(), do: Stream.repeatedly(&generate_chromossome/0) |> Stream.take(100)

  defp evaluate(population), do: population |> Enum.sort_by(&Enum.sum/1, &>=/2)

  defp select(population), do: population |> Stream.chunk_every(2) |> Stream.map(&List.to_tuple/1)

  defp crossover_reduce({parent_a, parent_b}, children) do
    crossover_point = :rand.uniform(@chromossome_size)
    {parent_a_hd, parent_a_tl} = parent_a |> Enum.split(crossover_point)
    {parent_b_hd, parent_b_tl} = parent_b |> Enum.split(crossover_point)
    [parent_a_hd ++ parent_b_tl, parent_b_hd ++ parent_a_tl | children]
  end

  defp crossover(population_in_pairs),
    do: population_in_pairs |> Enum.reduce([], &crossover_reduce/2)

  defp mutate_map(chromossome) do
    if :rand.uniform() < 0.05 do
      chromossome |> Enum.shuffle()
    else
      chromossome
    end
  end

  defp mutate(population), do: population |> Stream.map(&mutate_map/1)

  defp search(population) do
    best_chromossome = population |> Enum.max_by(&Enum.sum/1)
    best_fitness = best_chromossome |> Enum.sum()

    IO.write("\rCurrent Best: " <> Integer.to_string(best_fitness))

    if best_fitness == @chromossome_size do
      best_chromossome
    else
      population
      |> evaluate()
      |> select()
      |> crossover()
      |> mutate()
      |> search()
    end
  end

  def start do
    generate_population() |> search()
  end
end

OneMax.start()

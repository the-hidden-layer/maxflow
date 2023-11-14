defmodule PreflowPush do
  # Public function to find the maximum flow in a flow network
  def max_flow(graph, source, sink) do
    # Initialize the preflow and excess arrays
    preflow = initialize_preflow(graph, source)
    excess = initialize_excess(graph, source)
    
    # Initialize the heights array using the highest-label-first rule
    heights = initialize_heights(graph, source, sink)
    
    # Push excess flow until no vertices are active
    active_vertices = get_active_vertices(preflow, excess)
    
    while !Enum.empty?(active_vertices) do
      v = get_highest_label_vertex(active_vertices, heights)
      push_or_relabel(preflow, excess, heights, v, graph, sink)
      active_vertices = get_active_vertices(preflow, excess)
    end
    
    # Return the final maximum flow
    excess[sink]
  end

  # Private function to initialize the preflow array
  defp initialize_preflow(graph, source) do
    Enum.reduce(graph, %{}, fn {u, v, capacity}, preflow ->
      Map.put(preflow, {u, v}, 0)
    end)
  end

  # Private function to initialize the excess array
  defp initialize_excess(graph, source) do
    Enum.reduce(graph, %{}, fn {u, v, capacity}, excess ->
      if u == source, do: Map.put(excess, u, capacity), else: excess
    end)
  end


  # Private function to initialize the heights array using the highest-label-first rule
  defp initialize_heights(graph, source, sink) do
    # Initialize heights to 0 for all vertices except the source
    heights = Enum.reduce(graph, %{}, fn {u, v, _}, heights ->
      Map.put(heights, u, 0)
    end)
    
    # Set the height of the source to the number of vertices
    Map.put(heights, source, length(graph))
    
    # Initialize the queue with vertices at height n-1
    queue = Enum.filter(graph, fn {u, _, _} -> u != source end)
    
    # BFS to set heights in the highest-label-first order
    while !Enum.empty?(queue) do
      {current, _, _} = Enum.at(queue, 0)
      queue = Enum.drop(queue, 1)
      
      neighbors = Enum.filter(graph, fn {u, v, _} -> u == current and Map.get(heights, v, 0) == 0 end)
      new_vertices = Enum.map(neighbors, fn {_, v, _} ->
        Map.put(heights, v, Map.get(heights, current) - 1)
      end)
      
      queue = queue ++ new_vertices
    end
    
    heights
  end

  # Private function to get active vertices with excess flow
  defp get_active_vertices(preflow, excess) do
    Enum.filter(excess, fn {v, e} -> e > 0 end)
  end

  # Private function to get the highest label vertex among active vertices
  defp get_highest_label_vertex(active_vertices, heights) do
    Enum.reduce(active_vertices, {nil, -1}, fn {v, _}, {highest_vertex, highest_label} ->
      label = Map.get(heights, v, 0)
      if label > highest_label, do: {v, label}, else: {highest_vertex, highest_label}
    end) |> elem(0)
  end

  # Private function to push flow or relabel a vertex
  defp push_or_relabel(preflow, excess, heights, u, graph, sink) do
    neighbors = Enum.filter(graph, fn {uu, v, _} -> uu == u and excess[uu] > 0 and Map.get(heights, uu) == Map.get(heights, v) + 1 end)
    
    if !Enum.empty?(neighbors) do
      {_, v, capacity} = Enum.random(neighbors)
      push(preflow, excess, u, v, capacity)
    else
      relabel(heights, u)
    end
  end

  # Private function to push flow from u to v
  defp push(preflow, excess, u, v, capacity) do
    bottleneck_capacity = min(excess[u], capacity - Map.get(preflow, {u, v}))
    
    # Update preflow and excess
    preflow = Map.update(preflow, {u, v}, bottleneck_capacity, &(&1 + bottleneck_capacity))
    preflow = Map.update(preflow, {v, u}, -bottleneck_capacity, &(&1 - bottleneck_capacity))
    excess = Map.update(excess, u, &(&1 - bottleneck_capacity))
    excess = Map.update(excess, v, &(&1 + bottleneck_capacity))
  end
end

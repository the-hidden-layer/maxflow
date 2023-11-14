defmodule FordFulkerson do
  # Public function to find the maximum flow in a flow network
  def max_flow(graph, source, sink) do
    # Build the residual graph as a copy of the original graph
    residual_graph = build_residual_graph(graph)
    
    # Initialize the maximum flow to 0
    max_flow = 0
    
    # Continue the loop until no augmenting path is found
    while true do
      # Find an augmenting path in the residual graph
      path = find_augmenting_path(residual_graph, source, sink)
      
      # Check if no augmenting path is found
      case path do
        nil -> break
        _ -> 
          # Find the bottleneck capacity along the augmenting path
          bottleneck_capacity = find_bottleneck_capacity(residual_graph, path)
          
          # Update the residual graph based on the augmenting path
          update_residual_graph(residual_graph, path, bottleneck_capacity)
          
          # Add the bottleneck capacity to the maximum flow
          max_flow = max_flow + bottleneck_capacity
      end
    end

    # Return the final maximum flow
    max_flow
  end

  # Private function to build the residual graph as a copy of the original graph
  defp build_residual_graph(graph) do
    Enum.map(graph, fn {u, v, capacity} -> {u, v, capacity, capacity} end)
  end

  # Private function to find an augmenting path in the residual graph using BFS
  defp find_augmenting_path(graph, source, sink) do
    queue = [{source, []}]

    while !Enum.empty?(queue) do
      {current, path} = Enum.pop(queue)

      # Check if the current vertex is the sink
      if current == sink do
        # Return the augmenting path if found
        return path
      end

      # Explore neighbors and add them to the queue
      neighbors = Enum.filter(graph, fn {u, v, capacity, _} -> u == current and capacity > 0 end)
      new_paths = Enum.map(neighbors, fn {_, v, _, _} -> {v, path ++ [{current, v}]} end)
      queue = queue ++ new_paths
    end

    # Return nil if no augmenting path is found
    nil
  end

  # Private function to find the bottleneck capacity along an augmenting path
  defp find_bottleneck_capacity(graph, path) do
    capacities = Enum.map(path, fn {u, v} -> get_capacity(graph, u, v) end)
    Enum.min(capacities)
  end

  # Private function to get the capacity of a specific edge in the graph
  defp get_capacity(graph, u, v) do
    case Enum.find_value(graph, fn {uu, vv, capacity, _} -> uu == u and vv == v end) do
      {_, _, capacity, _} -> capacity
      _ -> 0
    end
  end

  # Private function to update the residual graph based on an augmenting path
  defp update_residual_graph(graph, path, bottleneck_capacity) do
    updated_graph = Enum.map(graph, fn {u, v, capacity, flow} ->
      case Enum.find(path, &(&1 == {u, v})) do
        nil -> {u, v, capacity, flow}  # Not in the augmenting path
        _ -> {u, v, capacity - bottleneck_capacity, flow + bottleneck_capacity}  # In the augmenting path
      end
    end)

    # Update the backward edges in the residual graph
    updated_graph_backward = Enum.map(updated_graph, fn {u, v, _, _} ->
      {v, u, bottleneck_capacity, 0}
    end)

    # Combine the updated forward and backward edges
    updated_graph ++ updated_graph_backward
  end
end

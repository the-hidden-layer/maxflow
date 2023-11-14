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
end

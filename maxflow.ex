defmodule MaxFlow do
  @spec max_flow(graph :: [tuple()], source :: term(), sink :: term(), strategy :: module()) :: integer()
  def max_flow(graph, source, sink, strategy) do
    strategy.max_flow(graph, source, sink)
  end
end

defmodule FordFulkersonStrategy do
  @behaviour MaxFlowStrategy

  @impl MaxFlowStrategy
  def max_flow(graph, source, sink) do
    FordFulkerson.max_flow(graph, source, sink)
  end
end

defmodule PreflowPushStrategy do
  @behaviour MaxFlowStrategy

  @impl MaxFlowStrategy
  def max_flow(graph, source, sink) do
    PreflowPush.max_flow(graph, source, sink)
  end
end

defmodule MaxFlowStrategy do
  @callback max_flow(graph :: [tuple()], source :: term(), sink :: term()) :: integer()
end


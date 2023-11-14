# Max-Flow Min-Cut

These are implementations of popular max flow algorithms. So far, Ford-Fulkerson and Preflow Push have been implemented.


### Elixir Usage

```elixir
# Using Ford-Fulkerson algorithm
MaxFlow.max_flow(graph, source, sink, FordFulkersonStrategy)

# Using Preflow-Push algorithm
MaxFlow.max_flow(graph, source, sink, PreflowPushStrategy)
```

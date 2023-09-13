# Layer 1: The graph
In this chapter, we specify how the part of the WIR looks like that specifies the high-level workflow graph.

The toplevel of the WIR itself, which mostly concerns itself with definitions, can be found in the [previous chapter](./schema.md). By contrast, the [next chapter](./instructions.md) defines the lower-level instructions that are used within edges of the graph.

We use the same [conventions](./schema.md#conventions) as in the previous chapter. We recommend you read them before continuing to understand what we wrote down.


## Edges
Graphs in the WIR are built of segments called `Edge`s. This is a misnamed term, because this represents both edges and nodes in the graph. The underlying idea, however, is that the graph is build up of edges of pre-defined shapes, like linear connectors, branches or loops, some of which happen to have a node attached to them.

To that end, 

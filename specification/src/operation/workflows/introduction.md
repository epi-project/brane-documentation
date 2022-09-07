# Workflows
The driver force behind Brane, _"that which makes it programmable"_, are the Workflows. They are basically programs fed to the main infrastructure, which defines what it needs to do but at a sufficiently high level of abstraction that it does not (necessarily) specify locations. That is left for the rest of the infrastructure to figure out, which makes it an orchestrator.

In the next sections, we will provide the design goals and main ideas behind the workflow, as well as introduce a bit of terminology used in subsequent chapters on this topic.


## Design
Because Workflows may be written in various languages, it makes most sense to think of a Workflow as an abstract representation of a program. Because we subject to policies, it is a rather unique representation that serves two purposes:
1. The workflow must be executable, i.e., the framework must be able to execute the program it represents when given;
2. The workflow must be analysable, i.e., eFLINT (or other reasoners) must be able to understand how their data flows from location to location and for what purpose.

To this end, Workflows are defined as a directed graph. Every node in this graph represents a compute or a transfer task (i.e., a data interaction), and edges represent some control flow to get there. But that's not all; the edges are mini programs themselves, which either prepare the driver for calling tasks (i.e., compute arguments) or decide exactly which branch to take next.

This offers two levels of abstraction: at graph level, the Workflow represents which tasks **may** be executed on which datasets and which results of other tasks, allowing checkers to reason about what happens to their data. At program level, it is a set of instructions that move from one node to the next, exposing which tasks **are** executed from the ones that may.


## Terminology
For the remainder of these series, we will use the following (confusing) terminology:
- Every part of the graph (both edges and nodes) are referred to as _edges_. This is awkward, but chosen since nodes are represented as simply a special kind of edge.
- Every node represents a _task_, which is an external function call that has to be orchestrated and approved.
- Every edge contain zero or more _edge instructions_, which are really low-level instructions that run the program.


## Next
The [next chapter](./graph-edges.md) in this series dives into the representation of the Workflow as used within the framework (e.g., what edges are there, what nodes, ...). Then, in the following chapters, we discuss how each of the workflow languages (e.g., BraneScript, Bakery, ...) compiles to a Workflow, revealing what structure they actually impose. Finally, in the [last chapter](./executing.md), we examine how the workflow may be executed and reasoned about.

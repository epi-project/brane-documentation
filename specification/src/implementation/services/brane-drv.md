# `brane-drv`: The driver
Arguably the most central to the framework is the `brane-drv` service. It implements the _driver_, the entrypoint and main engine behind the other services in the framework.

In a nutshell, the `brane-drv`-service waits for a user to submit a workflow (given in the [Workflow Internal Representation](../../spec/wir/introduction.md) (WIR)), prepares it for execution by sending it to [`brane-plr`](./brane-plr.md) and subsequently executes it.

This chapter will focus on the latter function mostly, which is executing the workflow in WIR-format. For the part of the driver that does user interaction, see the [specification](TODO); and for the interaction with `brane-plr`, see [that service's chapter](./brane-plr.md).


## The driver as a VM
The reference implementation defines a generic `Vm`-trait that takes care of most of the execution of a workflow. Importantly, it leaves any operation that may require outside influence open for specific implementations; 

This is done by following the procedure described in the next few subsections. First, we will discuss how the edges in a workflow graph are traversed and executed, after which we describe some implementation details of executing the instructions embedded within them. Then, finally, we will describe the procedure of executing a task from the driver's perspective.

### Unspooling workflows
In the [WIR specification](../../spec/wir/graph.md), the workflow graph is defined as a series of modular "[`Edge`](../../spec/wir/graph.md#edges)s" that compose the graph as a whole. Every such component can be thought of as having connectors, where it gets traversed from its incoming to one of its outgoing connectors. Which connector is taken, then, depends on the conditional branches embedded in the graph.

To execute the conditional branches, the driver defines a workflow-local _stack_ on which values can be pushed to and popped from as the traversing of a workflow occurs.

The driver always starts at the first edge in the `graph`-part of the WIR, which represents the main body of the workflow to execute. Starting at its incoming connector, the edge is executed and the driver moves to the next one indicated by its outgoing connector. This process is dependent on which edge is taken:
- [`Linear`](../../spec/wir/graph.md#linear): As the name suggests, this edge always progresses to a static, single next edge. However, attached to this edge may be any number of [`EdgeInstr`](../../spec/wir/instructions.md#edgeinstrs)uctions that manipulate the stack (see [below](#executing-instructions)).
- [`Node`](../../spec/wir/graph.md#node): A linear edge as well, this edge always progresses to a static, single next edge. However, attached to this edge is a task call that must be executed before continuing (see [below](TODO)).
- [`Stop`](../../spec/wir/graph.md#stop): An edge that has no outgoing connector. Whenever this one is traversed, the driver simply stops executing the workflow and completes the interaction with the user.
- [`Branch`](../../spec/wir/graph.md#branch): An edge that optionally takes one of two chains of edges (i.e., it has two outgoing connectors). Which of the two is taken depends on the current state of the stack.
- [`Parallel`](../../spec/wir/graph.md#parallel): An edge that has multiple outgoing connectors, but where _all_ of those are taken concurrently. This edge is matches with a [`Join`](../../spec/wir/graph.md#join)-edge that merges the chains back together to one connector.
- [`Join`](../../spec/wir/graph.md#join): A counterpart to the [`Parallel`](../../spec/wir/graph.md#parallel) that joins the concurrent streams of edges back into one outgoing connector. Doing so, the join may combine results coming from each branch in hardcoded, but configurable, ways.
- [`Loop`](../../spec/wir/graph.md#loop): An edge that represents a conditional loop. Specifically, it has three connectors: one that points to a stream of edges for preparing the stack to analyse the condition at the start of every iteration; one that represents the edges that are repeatedly taken; and then one that is taken when the loop stops.
- [`Call`](../../spec/wir/graph.md#call): An edge that emulates a function call. While it is represented like a linear edge, first, a secondary body of edges is taken depending on the function identifier annotated to this edge. The driver only resumes traversing the outgoing connector once the secondary body hits a [`Return`](../../spec/wir/graph.md#return) edge.
- [`Return`](../../spec/wir/graph.md#return): An edge that lets a secondary function body return to the place where it was called from. Like function returns, this may manipulate the stack to push back function results.

### Executing instructions
A few auxillary systems have to be in place, besides the stack, that is necessary for executing instructions.

First, the driver implements a _frame stack_ as a separate entity from the stack itself. This defines where the driver should return to after every successive [`Call`](../../spec/wir/graph.md#call)-edge, as well as any variables that are defined in that function body (such that they may be undeclared upon a return). Further, the framestack is also used to manage shadowing variable-, function- or type-declarations, as the current implementation does not do any name mangling.

Next, the driver also implements a _variable register_. This is used to keep track of values with a different lifetime from typical stack values, and that need to be stored temporarily during execution. Essentially, the variable register is a table of variable identifiers to values, where variables can be added ([`VarDec`](../../spec/wir/instructions.md#vardec)), removed ([`VarUndec`](../../spec/wir/instructions.md#varundec)), assigned new values ([`VarSet`](../../spec/wir/instructions.md#varset)) or asked to provide their stored values ([`VarGet`](../../spec/wir/instructions.md#varget)).

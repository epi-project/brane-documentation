# Virtual Machine (VM) for the WIR
An important part of the the Brane Framework is the execution engine for the [Workflow Intermediate Representation](../../spec/wir/introduction.md) (WIR). Because the WIR is implemented as a binary-like set of edges and instructions, this execution engine is known as a Virtual Machine (VM) because it emulates a full set of resources needed to execute the WIR.

In these chapters, we will discuss the [reference implementation](https://github.com/epi-project/brane) of the VM. Note that it is assumed that you are already familiar with the WIR and have read the matching chapters in this book.


## VM with plugins
In Brane, a workflow might be executed in different contexts, which changes what effects a workflow has.

In particular, if we think of executing a workflow as translating it to a series of events that must be processed in-order, then how we process these events differs on the execution environment. In [`brane-cli`](TODO), this environment is on a single machine and for testing purposes only; whereas in [`brane-drv`](../services/brane-drv.md), the environment is a full Brane instance with multiple domains, different backends and policies to take into account.

To support this variety of use-cases, the VM has a notion of _plugins_ that handle the resulting events. In particular, the traversal and processing of a workflow is universalised in the base implementation of the VM. Then, the processing of any "outward-facing" events (e.g., task processing, file transfer, feedback to user) is delegated to configurable pieces of code that handle these different based on the use-case.


## Source code
In the reference implementation, the base part of the VM is implemented in the [`brane-exe`](https://github.com/epi-project/brane/tree/v2.0.0/brane-exe)-crate. Then, [`brane-cli`](https://github.com/epi-project/brane/blob/v2.0.0/brane-cli/src/vm.rs) implements plugins for a local, offline execution, whereas [`brane-drv`](https://github.com/epi-project/brane/blob/v2.0.0/brane-drv/src/vm.rs) implements the plugins for the in-instance, online execution. Finally, a set of dummy plugins for testing purposes exists in [`brane-exe`](https://github.com/epi-project/brane/blob/v2.0.0/brane-exe/src/dummy.rs) as well.


## Next
In the [next chapter](./overview.md), we start by considering the main structure and overview of the VM, including how the VM handles threads and plugins. Then, we examine various implementations of subsystems: the [expression stack](./stack.md) (including the VM's notion of values), the [variable register](./var_reg.md) and the [frame stack](./frame_stack.md) (including virtual symbol tables).

If you're interesting in another topic than the VM, you can select it in the sidebar to the left.

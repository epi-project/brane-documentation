# Virtual Machine (VM) for the WIR
An important part of the the Brane Framework is the execution engine for the [Workflow Intermediate Representation](../../spec/wir/introduction.md) (WIR). Because the WIR is implemented as a binary-like set of edges and instructions, this execution engine is known as a Virtual Machine (VM) because it emulates a full set of resources needed to execute the WIR.

In these chapters, we will discuss the [reference implementation](https://github.com/epi-project/brane) of the VM. Note that it is assumed that you are already familiar with the WIR and have read the matching chapters in this book.


## VM with plugins
In Brane, a workflow might be executed in different contexts, which changes how the 


In the reference implementation, the base part of the VM is implemented in the [`brane-exe`](https://github.com/epi-project/brane/tree/v2.0.0/brane-exe)-crate.

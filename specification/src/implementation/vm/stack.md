# Expression stack
In this chapter, we will discuss the [reference implementation](https://github.com/epi-project/brane)'s implementation of the expression stack for the Virtual Machine (VM) globally introduced in the [previous chapter](./overview.md). Because it is a thread that will execute a single workflow, we will discuss the stack's behaviour in the context of a thread.

First, we will discuss the [basic view](#basic-view) of the stack, after which we discuss the stack's notion of [values](#values-and-fullvalues) (including [dynamic popping](#dynamic-popping)).


## Basic view
The stack acts as a scratchpad memory for the thread to which it belongs. As the thread processes graph [edges](../../spec/wir/graph.md#edges) and their attached [instructions](../../spec/wir/instructions.md#edgeinstrs), these may _push_ values on the stack of _pop_ values from them. This is done in FIFO-order, i.e., pushing adds new values on top of the stack, whereas popping removes them in reverse order (newest first). Typically, instructions consume values, perform some operation on them and then push them back.

Some edges, then, may introduce conditionality by taking one of multiple next possible branches in the tree. Which branch is taken then depends on the top value of the stack, which typically uses a boolean true to denote that the branch should be taken or a boolean false to denote it shouldn't.

Note that the stack in the implementation is relatively simple. It is bounded to a static size (allowing `Stack overflow` errors to potentially occur), and it does not store large objects, such as strings, arrays and instances, by reference but instead by value. This means that, everytime an operation is performed on such an object, the object needs to be re-created or copied instead of simply pushing a handle to it.


## Value's and FullValue's
The things stored on the stack are valled _values_, and represent one particular value that is used or mutated in expressions and/or stored in variables (see the [next chapter](./var_reg.md)). Specifically, values in the stack are typed, and may be of any [data type defined in the WIR](../../spec/wir/schema.md#the-datatype).



### Dynamic popping


## Next
> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 2px; margin-bottom: -2px"/> This section will be written soon.

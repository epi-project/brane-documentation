# Expression stack
In this chapter, we will discuss the [reference implementation](https://github.com/epi-project/brane)'s implementation of the expression stack for the Virtual Machine (VM) globally introduced in the [previous chapter](./overview.md). Because it is a thread that will execute a single workflow, we will discuss the stack's behaviour in the context of a thread.

First, we will discuss the [basic view](#basic-view) of the stack, after which we discuss the stack's notion of [values](#values-and-fullvalues) (including [dynamic popping](#dynamic-popping)).


## Basic view
The stack acts as a scratchpad memory for the thread to which it belongs. As the thread processes graph [edges](../../spec/wir/graph.md#edges) and their attached [instructions](../../spec/wir/instructions.md#edgeinstrs), these may _push_ values on the stack of _pop_ values from them. This is done in FIFO-order, i.e., pushing adds new values on top of the stack, whereas popping removes them in reverse order (newest first). Typically, instructions consume values, perform some operation on them and then push them back. This is visualised in Figure 1.

![Visualisation of a typical stack operation](../../assets/diagrams/ExprStack.png)  
_**Figure 1**: Visualisation of an arithmetic operation (subtraction) on the stack. Operations are defined as rewrite rules on the top values of the stack, popping input as necessary and pushing results as computed. In this example, note that possibly counter-intuitive ordering of arguments due to the FIFO nature of the stack._

Some edges, then, may introduce conditionality by taking one of multiple next possible branches in the tree. Which branch is taken then depends on the top value of the stack, which typically uses a boolean true to denote that the branch should be taken or a boolean false to denote it shouldn't.

Note that the stack in the implementation is relatively simple. It is bounded to a static size (allowing `Stack overflow` errors to potentially occur), and it does not store large objects, such as strings, arrays and instances, by reference but instead by value. This means that, everytime an operation is performed on such an object, the object needs to be re-created or copied instead of simply pushing a handle to it.


## Value's and FullValue's
The things stored on the stack are valled _values_, and represent one particular value that is used or mutated in expressions and/or stored in variables (see the [next chapter](./var_reg.md)). Specifically, values in the stack are typed, and may be of any [data type defined in the WIR](../../spec/wir/schema.md#the-datatype) _except_ any grouping of types, including `DataType::Any`. This latter implies that all types will be resolved at runtime, even if they aren't always known beforehand in the given workflow.

Note, however, that the values on the stack do not embed their type information completely. Customized information, such as a class definition or function header, lives on the [frame stack](./frame_stack.md) and is scoped to the function that we're calling. As such, values only contain identifiers to the specific definition currently in scope.

There exists a variant of value's, _full values_, which do embed their definitions. These are used when values are communicated outside of the VM, such as return values of workflows.


### Dynamic popping
A special case of value on the stack is a _dynamic pop marker_, which is used in [dynamic popping](../../spec/wir/instructions.md#dynamicpop). This is used when the return value of a function cannot be typed at runtime, and an unknown number of items have to be popped from the stack after the function returns.

To this end, the pop marker is used. First, it is pushed to the stack before the function call; then, when executing a dynamic pop, the stack will simply pop values until it has popped the dynamic pop marker. For all other operations, the pop marker is invisible and acts as though the value below it is on top of the stack instead.


## Next
In the next chapter, we discuss the next component of the VM, the [variable register](./var_reg.md). The [frame stack](./frame_stack.md) will be discussed after that.

If you like have an overview of what the VM does as a whole, check the [previous chapter](./overview.md). You can also select a different topic altogether in the sidebar to the left.

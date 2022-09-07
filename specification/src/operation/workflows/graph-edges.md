# Graph Edges
In this chapter, we will outline the specific representation used in the framework. This will simply be an enumeration of the edges and instructions that are supported.

First, we will discuss the possible edges. Then, we will go to an overview of all instructions and the model behind them; and in the final section, we will make some final remarks about communicating the representation and storing it.


## Edges
Looking at edges from the higher level of abstraction, each of them defines a kind of control-flow operation that, when brought together, define how the nodes link together.

Concretely, every edge we talk about is a building block to construct a 'real' edge in the graph. An example of such construction is given at the end of this section.

First, we will go through a list of all the edge building blocks in a Workflow. In this list, we will draw some simple ASCII-diagrams that have the following legend:
- `Nx`: An node with label `x`. E.g., `N1` refers to a node with label 1.
- `--`: A line that may branch, turn, or flow; represents the most 'direct' control flow.
- `..`: A line that represents 'virtual links', i.e., links to 'function edges' (see below).

We can classify two types of edges. The first type are _atomic_ edges, which are very simple and useful during execution:
- **Node edges** (pardon the terminology) define a linear connection that will run a certain task before proceeding. Since they are linear, they themselves may form connections between two other edges.  
  Node edges schematically look as follows:
  ```
  N1 ---T--- N2
  ```
  (where `T` is the to-be-executed task)
- **Linear edges** define a simple, linear connection from one edge to the next. They are mostly useful because they may contain edge instructions, and thus represent a part of serial program code (i.e., code that does not branch*).  
  Linear edges schematically look as follows:
  ```
  N1 ------- N2
  ```
  The order of linear edges is explicitly defined, so it is possible that multiple linear edges point to the same next edge.
- **Branching edges** define a place where the control flow may go either of two ways. Typically, the reasoner may expect that one of the branches runs a node and the other may not, or both branches will run different node(s).  
  Branching edges schematically look as follows:
  ```
        ┌--- N2
  N1 ---┤
        └--- N3
  ```
  Note that joining a Branching edge happens naturally, since the linear edges will naturally converge back into one at some point (unless they return; see below).
- **Parallel edges** (and their associated **join edges**) define a section of the workflow that may be run concurrently. There can be an arbitrary amount of branches, and they will run in isolation from each other. Only at the join node are their results awaited (if any), which also synchronizes execution of the workflow (i.e., makes sure that all branches have completed before continuing if desired).  
  Parallel edges schematically look as follows:
  ```
        ┌--- N2 ---┐
  N1 ---┼--- N3 ---o--- N5
        └--- N4 ---┘
  ```
  (where `o` is the special join edge)
- **Calling edges** (and their associated **return edges**) don't define a control flow operation as much as they do an optimization. Every call can be thought of as a 'reference' to another, disconnected series of edges that should be followed instead. After those edges have reached a conclusion, the graph should be followed starting from the calling edge again.  
  They are quite unfortunate for reasoning, but are a necessary part of the control flow due to the Workflows possibly being compiled from script-like language.  
  Calling edges schematically look as follows:
  ```
       .--- N3 --- r
       .
       .
  N1 --c-- N2
  ```
  where `c` is the calling edge and `r` is the returning edge. The execution starts at `N1`, encounters `c`, starts executing edges part in the branch of `N3` until it reached `r`, and then resumes the original branch until `N2`.  
  For reasoning, the schema above may be unrolled to:
  ```
  N1 ---N2--- N3
  ```
- **Stopping edges** are edges that simply stop the workflow. They have no next edge, and will always halt workflow execution whenever encountered.  
  Stopping edges schematically look as follows:
  ```
  N1 --- *
  ```
  (where `*` means that nothing follows)

_* As you will see in the next chapter, the code may actually still branch. However, any such code will be guaranteed not to run tasks, so it's linear from a checker's perspective._

<!-- Aside from the atomic edges, there are more complex edges that group other edges together to make reasoning easier:
- **Test** -->


## Instructions
As mentioned in the previous section, some edges may contain one or multiple edge instructions which execute some program. In this section, we will examine how this works and what instructions there are.

At the lower level of abstraction, a Workflow implements a stack machine with a bit uncomfortable structuring. Following from this, executing a workflow requires defining a workflow-wide stack (except in the case of parallel branches; see the [last chapter](./execution.md)) to which every edge instructions pushes or pops as a way of keeping track of temporary state. Aside from that, there is also a variable register (which acts as a heap) and a frame stack (which is used to execute calling edges). More details on how this execution works is specified in the [last chapter](./execution.md) of the series.

The instructions themselves are given into the following subsections to try and impose a little ordering.

### Stack operations
- `.cast`: Converts the top value of the stack from its current type to a new one. Failing to do so will crash the VM.
  - _Arguments_: The `.cast` always defines the target type.
  - _Pops_: A single value from the stack that should be convertible to the target type.
  - _Pushes_: The converted value back on the stack.
- `.pop`: Pops the top value off the stack without doing anything with it. Will crash the VM if the stack was empty.
  - _Arguments_: -
  - _Pops_: A single value of arbitrary type.
  - _Pushes_: -
- `.pop_marker`: Pushes a special, "invisible" value onto the stack that is used to run `.dpop` (see below).
  - _Arguments_: -
  - _Pops_: -
  - _Pushes_: nothing officially, but secretly a `PopMarker`-value.
- `.dpop`: Pops from the top of the stack until (and including) a `PopMarker`-value pushed by `.pop_marker`. This is used to pop a 'dynamic' amount off the stack, which is necessary since the script-like origins of a Workflow may mean the type of a value is unknown until runtime.
  - _Arguments_: -
  - _Pops_: An runtime-dependent number of values of arbitrary type, until a `PopMarker` is popped. Crashes the VM if not such value is popped before the stack is empty.
  - _Pushes_: -

### Control-flow operations
- `.brch`: Defines a low-level-only branch that jumps if the top value on the stack is 'true'. This is still a control flow operation, but one that the higher level may be agnostic to. As a consequence, it is guaranteed that the branch is local within the same edge.
  - _Arguments_: The relative position to jump to, in number of edges. A position of '0' means that the branch is executed again (so to 'do no jump', pass a position of '1').
  - _Pops_: A single value that must be a boolean. If this value if true, the branch is taken; otherwise, the next instruction is executed.
  - _Pushes_: - 
- `.nbrch`: Defines a low-level-only branch that jumps if the top value on the stack is _not_ 'true'. This means it is an optimized instruction for a `.brch` after a `.not`.
  - _Arguments_: The relative position to jump to, in number of edges. A position of '0' means that the branch is executed again (so to 'do no jump', pass a position of '1').
  - _Pops_: A single value that must be a boolean. If this value if false, the branch is taken; otherwise, the next instruction is executed.
  - _Pushes_: - 

### Unary operations
- `.not`: Performs a logical not on the top value on the stack.
  - _Arguments_: -
  - _Pops_: A single value that must be a boolean.
  - _Pushes_: A single boolean value that is 'true' if the top value was 'false' and vice versa.
- `.neg`: Performs an arithmetic negation on the top value on the stack.
  - _Arguments_: -
  - _Pops_: A single value that must be numeric (i.e., an integer or a real).
  - _Pushes_: A single value that is of the same type as the popped value, but now multiplied by '-1'.

### Binary operations - logical
- `.and`: Performs the logical conjunction on the top two values on the stack.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be boolean.
  - _Pushes_: A single boolean that represents the result of the operation.
- `.or`: Performs the logical disjunction on the top two values on the stack.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be boolean.
  - _Pushes_: A single boolean that represents the result of the operation.

### Binary operations - arithmetic
- `.add`: Performs the arithmetic addition on the top two values on the stack. If the top two values are strings, however, then it performs a concatenation.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be integer, real or string, and both must be of the same type.
  - _Pushes_: A single value that represents the result of the operation, of the same type as given.
- `.sub`: Performs the arithmetic subtraction on the top two values on the stack.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be numeric (i.e., integer or real), and both must be of the same type.
  - _Pushes_: A single value that represents the result of the operation, of the same type as given.
- `.mul`: Performs the arithmetic multiplication on the top two values on the stack.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be numeric (i.e., integer or real), and both must be of the same type.
  - _Pushes_: A single value that represents the result of the operation, of the same type as given.
- `.div`: Performs the arithmetic division on the top two values on the stack.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be numeric (i.e., integer or real), and both must be of the same type.
  - _Pushes_: A single value that represents the result of the operation, of the same type as given.
- `.mod`: Takes the arithmetic modulo on the top two values on the stack.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be integral.
  - _Pushes_: A single value that represents the result of the operation, as an integer.

### Binary operations - comparative
- `.eq`: Pops the top two values off the stack, and pushes if they are equal to each other.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values can have arbitrary type (and can differ in types).
  - _Pushes_: 'true' if the two values are the same, or 'false' otherwise. This comparison is always performed value-wise (not pointer-wise).
- `.ne`: Pops the top two values off the stack, and pushes if they are _not_ equal to each other.
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values can have arbitrary type (and can differ in types).
  - _Pushes_: 'false' if the two values are the same, or 'true' otherwise. This comparison is always performed value-wise (not pointer-wise).
- `.lt`: Pops the top two values off the stack, and pushes if the bottom of the two (the lefhand-side) was strictly smaller than the upper of the two (the righthand-side).
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be numeric (i.e., integer or real), and both must be of the same type.
  - _Pushes_: 'true' if the one is smaller than the other, or 'false' otherwise.
- `.le`: Pops the top two values off the stack, and pushes if the bottom of the two (the lefhand-side) was strictly smaller than or equal to the upper of the two (the righthand-side).
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be numeric (i.e., integer or real), and both must be of the same type.
  - _Pushes_: 'true' if the one is smaller than or equal to the other, or 'false' otherwise.
- `.gt`: Pops the top two values off the stack, and pushes if the bottom of the two (the lefhand-side) was strictly greater than the upper of the two (the righthand-side).
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be numeric (i.e., integer or real), and both must be of the same type.
  - _Pushes_: 'true' if the one is greater than the other, or 'false' otherwise.
- `.ge`: Pops the top two values off the stack, and pushes if the bottom of the two (the lefhand-side) was strictly greater than or equal to the upper of the two (the righthand-side).
  - _Arguments_: -
  - _Pops_: Two values, a lefthand-side and a righthand-side, with the latter on top of the stack (i.e., pops them in reverse order). Both values must be numeric (i.e., integer or real), and both must be of the same type.
  - _Pushes_: 'true' if the one is greater than or equal to the other, or 'false' otherwise.

### Composite operations
- `.arr`: Collects the top N values off the stack, and replaces them with an Array value containing all of them. It will crash the VM if elements have the wrong type (or inconsistent types).
  - _Arguments_: The `.arr` defines the size of the array (N) and its element type.
  - _Pops_: N elements off the stack, in reverse order (i.e., the last element of the array is popped first). They all have to be of the type defined in the instruction, unless that is of type `Any`; in that case, they have to be of the same type.
  - _Pushes_: A new Array-value with the popped values stored within it (order-sensitive). The element type of the Array is that specified in the instruction _or_ the type shared by its elements if the specified type was `Any`.
- `.arr_idx`: Returns a specific element in an array.
  - _Arguments_: The type of the array's element and thus of the pushed value.
  - _Pops_: First, pops the index off the stack, which must be an integer value. Then, it pops an Array value that must have the same element type as specified in the `.arr_idx` (unless the type in the `.arr_idx` was `Any`; then any type is valid).
  - _Pushes_: A new value that is the indexed element. Its type is that of the element type specified in the `.arr_idx` _unless_ it is `Any`; in that case, it has the same type as the indexed Array.
- `.inst`: Creates a new instance of a certain class. The values of the class' properties are determined by the top N values on the stack, where N is the class' number of properties; the order of the properties is then alphabetical, where the latest fieldname is popped first (e.g., field 'z' is popped first, then field 'a', ...).
  - _Arguments_: A reference to the class definition that is instantiated.
  - _Pops_: N elements off the stack, where N is the number of fields in the instantiated Class. They are popped alphabetically but in reverse order (e.g., field 'z' is popped first).
  - _Pushes_: A new value that is an instance of the target class. Its properties will be set to the values popped from the stack.
- `.proj`: Indexes an instance by accessing the proper field in that instance. The VM will fail if the class does not have the indexed field.
  - _Arguments_: The name of the field that is indexed.
  - _Pops_: A single value that is the instance to index.
  - _Pushes_: The value of the indexed field on top of the stack.

### Variable operations
- `.get`: Pushes the value of the referenced variable in the variable register on top of the stack.
  - _Arguments_: A reference to the variable who's value to push.
  - _Pops_: -
  - _Pushes_: The value the variable currently has in the variable register. Consequently, has the same type as that variable.
- `.set`: Pops the top value off the stack, and then loads it as the value for the referenced variable in the variable register.
  - _Arguments_: A reference to the variable who's value to update.
  - _Pops_: A single value that will become the variable's value. Consequently, must be of the same type as the referenced variable.
  - _Pushes_: -

### Literal operations
- `.bool`: Pushes a boolean value on top of the stack.
  - _Arguments_: The value of the boolean.
  - _Pops_: -
  - _Pushes_: The boolean value contained within.
- `.int`: Pushes an integral value on top of the stack.
  - _Arguments_: The value of the integer.
  - _Pops_: -
  - _Pushes_: The integral value contained within.
- `.real`: Pushes a real value on top of the stack.
  - _Arguments_: The value of the real.
  - _Pops_: -
  - _Pushes_: The real value contained within.
- `.str`: Pushes a string value on top of the stack.
  - _Arguments_: The value of the string.
  - _Pops_: -
  - _Pushes_: The string value contained within.
- `.ver`: Pushes a semver-value on top of the stack.
  - _Arguments_: The value of the version.
  - _Pops_: -
  - _Pushes_: The semver-value contained within.
- `.func`: Pushes a function object on the stack that represents a referenced function.
  - _Arguments_: A reference to the function to push.
  - _Pops_: -
  - _Pushes_: A new callable object that references the target function.

### Edges
Although they are not strictly instructions, edges often interact with the stack as well. They do so in the following way:
- **Node edges** executes a task, which can be thought of as a function call with extra steps.
  - _Arguments_: A reference to the task to execute.
  - _Pops_: N values off the stack, where N is the arity of the task. Consequently, the values must have matching types. The last argument of the task is popped as first.
  - _Pushes_: The result of the task on top of the stack after it has been executed. Consequently, has the same type as the return type of the task.
- **Linear edges**, for the context of this abstraction layer, are simple a series of instructions, and so their interaction is solely defined by the instructions within.
- **Branching edges** go either one edge or the other. To decide which, they branch on the top value on the stack (much like a `.brch` instruction).
  - _Arguments_: The absolute positions of the two edges (a 'true'-branch or a 'false'-branch) that may be taken.
  - _Pops_: A single value that must be a boolean. If this value if true, the true-branch is taken; otherwise, the false-branch is taken.
  - _Pushes_: - 
- **Parallel edges** themselves do not perform stack interactions. However, their associated **join edges**, do: these push the returned value of the parallel. This is either nothing (if the parallel did not return a value) or the result of all branches according to the join's _merge strategy_.
  - _Arguments_: The merge strategy to use to combine all the branch values into one.
  - _Pops_: -
  - _Pushes_: A single value on top of the stack representing the parallel's result. The value's type depends on the returned type and the merge strategy chosen.
- **Calling edges** represent normal function calls. Like nodes, they pop arguments and push results. However, unlike nodes, is the callsite completely stack-dependent.
  - _Arguments_: -
  - _Pops_: A callable object on top of the stack. Then, pops N values off the stack, where N is the arity of the callable object. Consequently, the values must have matching types. The last argument of the callable object is popped as first.
  - _Pushes_: The result of the function call on top of the stack after it has been executed. Consequently, has the same type as the return type of the callable object.
- **Stopping edges** neither push or pop to the stack; they simply stop program execution.
  - _Arguments_: -
  - _Pops_: -
  - _Pushes_: -


## Representation
### Binary
An executable Workflow is represented by a _workflow table_ and a _graph_. The first contains all function, task, class and variable definitions in the entire workflow (regardless of its scope). These are then referenced in the latter, which contains the edges to be executed.

Additionally, it also features zero or more _graph chunks_. Where the normal graph is the 'main' workflow, every graph chunk defined a piece of reusable graph (i.e., a function).


### On the wire
To transmit Workflows reliably between two hosts (e.g., a client CLI and a driver), it is serialized to a somewhat minimal JSON representation. This is done to avoid having to write a lot of parsers, but is definitely inefficient. In the future, this may be replaced by a much more compact binary representation.

One upside is that it is semi-readable. Note, though, that it does _not_ use the same identifiers as presented here for brevity, so it may be hard to read.


## Next
In the [next chapter](./branescript-and-bakery), we will discuss how to compile a Workflow from BraneScript and Bakery (i.e., Brane-unique languages). Check the sidebar on the left for other languages, or skip to the [last chapter](./execution.md) in this series to learn more about the virtual machine executing workflows.

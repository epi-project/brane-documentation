# Layer 2: Instructions
This chapter looks at the lowest level of the WIR, which implements a simply assembly-like instruction language for manipulating the stack that determines the graph control flow.

The edges of the graph themselves are defined in the [previous chapter](./graph.md), and the [chapter before that](./schema.md) talks about the toplevel of the WIR representation tying the edges together.

We use the same [conventions](./schema.md#conventions) as in the previous chapters. We recommend you read them before continuing to understand what we wrote down.


## EdgeInstrs
A [`Linear`](./graph.md#linear)-edge may be annotated with zero or more `EdgeInstr`uctions, which are assembly-like instructions that manipulate a workflow-wide stack. Some [`Edge`](./graph.md#edges)s manipulate the stack too, most often reading from it, but most work is done by explicitly stating the instructions.

As discussed in the [`introduction chapter`](./introduction.md), the instructions essentially implement a second layer of computation. Where the edges mostly related to "on-graph" computation, the edge instructions can be thought of as "off-graph" computation that typically matters less for reasoners.

As far as the specification goes, the the following fields are shared by all instructions:
- `kind` (string): Denotes which variant of the `EdgeInstr` this object describes. The identifiers used are given below in each subsections.

### Cast
_Identifier: `"cst"`_

The `Cast` takes the top value off the stack and attempts to perform a type conversion on it. Then, the result is pushed back on top of the stack.

Specification-wise, the `Cast` needs one additional field:
- `t` ([`DataType`](./schema.md#the-datatype)): Defines the datatype the top value on the stack to.

Stack-wise, the `Cast` manipulates the stack in the following way:
- _pops_ [`DataType::Any`](./schema.md#the-datatype) from the stack; and
- _pushes_ An object of type `t` on top of the stack representing the same value but as another type.

Note that this conversion may fail, since not all types can be converted into other types. Specifically, the following convertions are defined, where `T` and `U` represent arbitrary types and `Ts` and `Us` represents lists of arbitrary, possibly heterogenously typed values:
- `bool` to `int` creates a 1 if the input value is true or a 0 otherwise.
- `bool` to `str` creates a "true" if the input value is true, or a "false" if the input value is false.
- `int` to `bool` creates true if the input value is non-zero, or false otherwise.
- `int` to `real` creates an equivalent floating-point number.
- `int` to `str` writes the integer as a serialized number.
- `real` to `int` writes the floating-point value rounded down to the nearest integer.
- `real` to `str` writes the floating-point number as a serialized number.
- `arr<T>` to `str` casts the elements in the array from `T` to `str` and then serializes them within square brackets (`[]`), separated by comma's (`,`) (e.g., `"[ 42, 43, 44 ]"`).
- `arr<T>` to `arr<U>` casts every element in the array from `T` to `U`.
- `func(Ts) -> T` to `func(Us) -> U` is a no-op but _only_ if `Ts == Us` and `T == U`.
- `func(Ts) -> T` to `str` casts the values in `Ts` to `str` and `T` to `str` and then writes the name of the function followed by the arguments in parenthesis (`()`) followed by `->` and the return type (e.g., `"foo(int, real) -> str"`). If the function is a class method, then the class name and `::` are prefixed to the function name (e.g., `Foo::foo(Foo, int, real) -> str`).
- `func(Ts) -> T` to `clss` is a no-op, even keeping the same type, but _only_ if the function is a method and belongs to the class it is casted to. This can be used to assert that a method is part of a class(?).
- `clss<Ts>` to `str` casts the values in `Ts` to `str` and then serializes it as the class name followed by the values in the class serialized as name `:=` value separated by comma's in between curly brackets (`{}`) (e.g., `Foo { foo := 42, bar := "test" }`).
- `Data` to `str` writes `Data`, and then the name of the data in triangular brackets (`<>`) (e.g., `"Data<Foo>"`).
- `Data` to `IntermediateResult` is a no-op.
- `IntermediateResult` to `str` writes `IntermediateResult`, and then the name of the data in triangular brackets (`<>`) (e.g., `"IntermediateResult<Foo>"`).
- `T` to `T` performs a no-op.
- `T` to `Any` performs a no-op and just changes the type.

Any convertion not mentioned here is defined to be illegal.

As such, the `Cast` can throw the following errors:
- `Empty stack` when popping;
- `Stack overflow` when pushing; or
- `Illegal cast` when the value cannot be casted to type `t`.

The following is an example `Cast`-instruction:
```json
{
    "kind": "cst",
    "t": "str"
}
```

### Pop
_Identifier: `"pop"`_

Pops the top value off the stack and discards it.

This instruction does not require any additional fields.

Stack-wise, the `Pop` does the following:
- _pops_ `DataType::Any` from the stack.

It may throw the following error:
- `Empty stack` when popping.

An example:
```json
{
    "kind": "pop"
}
```

### PopMarker
_Identifier: `"mpp"`_

Pushes a so-called _pop marker_ onto the stack, which can then be popped using the [`DynamicPop`](#dynamicpop)-instruction. This combination can be used when popping an unknown number of values off the stack.

This instruction does not require any additional fields.

Stack-wise, the `PopMarker` does the following:
- _pushes_ a special value onto the stack that is invisible to most operations except [`DynamicPop`](#dynamicpop).

It may throw the following error:
- `Stack overflow` when pushing.

An example:
```json
{
    "kind": "mpp"
}
```

### DynamicPop
_Identifier: `"dpp"`_

_Dynamically pops_ the stack until a [`PopMarker`](#popmarker) is popped. This combination can be used when popping an unknown number of values off the stack.

This instruction does not require any additional fields.

Stack-wise, the `PopMarker` does the following:
- _pops_ a dynamic amount of values off the stack until [`PopMarker`](#popmarker)'s special value is popped.

Doing so may make it throw the following error:
- `Empty stack` when popping.

An example:
```json
{
    "kind": "dpp"
}
```

### Branch
_Identifier: `"brc"`_

Not to be confused with the [`Branch`](./graph.md#branch)-edge, this instruction implements a branch in the instruction stream only. This is only allowed when it's possible to do this within the same linear edge, implying the branch does not influence directly which nodes are executed.

The branch is taken when the top value on the stack is true; otherwise, it is ignored and implements a no-op.

The `Branch` defines the following fields:
- `n` (number): The relative offset to jump to. This can be thought of as "number of instructions to skip", where a value of -1 points to the previous instruction, 0 points to the `Branch`-instruction itself and 1 points to the next instruction.

Stack-wise, the `Branch` does the following:
- _pops_ `DataType::Boolean` from the stack.

As such, it can throw the following errors:
- `Empty stack` when popping; or
- `Type error` when the popped value is not a `bool`.

Note that skipping outside of the sequence of instructions belonging to a [`Linear`](./graph.md#linear)-edge means the VM simply stops executing.

An example `Branch`-instruction:
```json
{
    "kind": "brc",
    "n": 5
}
```

### BranchNot
_Identifier: `"brn"`_

Counterpart to the [`Branch`](#branch)-instruction that behaves the same except that it branches when the value on the stack is false instead of true.

The `BranchNot` defines the following fields:
- `n` (number): The relative offset to jump to. This can be thought of as "number of instructions to skip", where a value of -1 points to the previous instruction, 0 points to the `BranchNot`-instruction itself and 1 points to the next instruction.

Stack-wise, the `Branch` does the following:
- _pops_ `DataType::Boolean` from the stack.

As such, it can throw the following errors:
- `Empty stack` when popping; or
- `Type error` when the popped value is not a `bool`.

Note that skipping outside of the sequence of instructions belonging to a [`Linear`](./graph.md#linear)-edge means the VM simply stops executing.

An example `Branch`-instruction:
```json
{
    "kind": "brn",
    "n": 5
}
```

### Not
_Identifier: `"not"`_

Implements a logical negation on the top value on the stack.

The `Not` does not need additional fields to do this.

Stack-wise, the `Not` does the following:
- _pops_ `DataType::Boolean` from the stack; and
- _pushes_ `DataType::Boolean` on top of the stack.

As such, it can throw the following errors:
- `Empty stack` when popping;
- `Type error` when the popped value is not a `bool`; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "not"
}
```

### Neg
_Identifier: `"neg"`_

Implements a arithmetic negation on the top value on the stack.

The `Neg` does not need additional fields to do this.

Stack-wise, the `Neg` does the following:
- _pops_ `DataType::Numeric` from the stack; and
- _pushes_ `DataType::Numeric` on top of the stack.

As such, it can throw the following errors:
- `Empty stack` when popping;
- `Type error` when the popped value is not an `int` or `real`; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "neg"
}
```

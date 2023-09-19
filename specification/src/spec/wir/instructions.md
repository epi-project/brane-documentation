# Layer 2: Instructions
This chapter looks at the lowest level of the WIR, which implements a simply assembly-like instruction language for manipulating the stack that determines the graph control flow.

The edges of the graph themselves are defined in the [previous chapter](./graph.md), and the [chapter before that](./schema.md) talks about the toplevel of the WIR representation tying the edges together.

We use the same [conventions](./schema.md#conventions) as in the previous chapters. We recommend you read them before continuing to understand what we wrote down.


## EdgeInstrs
A [`Linear`](./graph.md#linear)-edge may be annotated with zero or more `EdgeInstr`uctions, which are assembly-like instructions that manipulate a workflow-wide stack. Some [`Edge`](./graph.md#edges)s manipulate the stack too, most often reading from it, but most work is done by explicitly stating the instructions.

As discussed in the [`introduction chapter`](./introduction.md), the instructions essentially implement a second layer of computation. Where the edges mostly related to "on-graph" computation, the edge instructions can be thought of as "off-graph" computation that typically matters less for reasoners.

As far as the specification goes, the the following fields are shared by all instructions:
- `kind` (string): Denotes which variant of the `EdgeInstr` this object describes. The identifiers used are given below in each subsections.

A convenient index of all instructions:
- [`Cast`](#cast): Casts a value to another type.
- [`Pop`](#pop): Discards the top value on the stack.
- [`PopMarker`](#popmarker): Pushes an invisible value that is used by...
- [`DynamicPop`](#dynamicpop): Pops values off the stack until the invisible value pushed by `PopMarker` is popped.
- [`Branch`](#branch): Conditionally jumps to another instruction within the same stream.
- [`BranchNot`](#branchnot): Conditionally jumps to another instruction within the same stream but negated.
- [`Not`](#not): Performs logical negation.
- [`Neg`](#neg): Performs arithmetic negation.
- [`And`](#and): Performs logical conjunction.
- [`Or`](#or): Performs logical disjunction.
- [`Add`](#add): Performs arithmetic addition / string concatenation.
- [`Sub`](#sub): Performs arithmetic subtraction.
- [`Mul`](#mul): Performs arithmetic multiplication.
- [`Div`](#div): Performs arithmetic division.
- [`Mod`](#mod): Performs arithmetic modulo.
- [`Eq`](#eq): Compares two values.
- [`Ne`](#ne): Compares two values but negated.
- [`Lt`](#lt): Compares two numerical values in a less-than fashion.
- [`Le`](#le): Compares two numerical values in a less-than-or-equal-to fashion.
- [`Gt`](#gt): Compares two numerical values in a greater-than fashion.
- [`Ge`](#ge): Compares two numerical values in a greater-than-or-equal-to fashion.
- [`Array`](#array): Pushes an array literal onto the stack (or rather, creates one out of existing values).
- [`ArrayIndex`](#arrayindex): Takes an array and an index and pushes the element of the array at that index.
- [`Instance`](#instance): Pushes a new instance of a class onto the stack by popping existing values.

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

### And
_Identifier: `"and"`_

Performs logical conjunction on the top two values on the stack.

No additional fields are needed to do this.

Stack-wise, the `And` does the following:
- _pops_ `DataType::Boolean` for the righthand-side;
- _pops_ `DataType::Boolean` for the lefthand-side; and
- _pushes_ `DataType::Boolean` that is the conjunction of the LHS and RHS.

The following errors can occur during this process:
- `Empty stack` when popping;
- `Type error` when the popped values are not a `bool`; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "and"
}
```

### Or
_Identifier: `"or"`_

Performs logical disjunction on the top two values on the stack.

No additional fields are needed to do this.

Stack-wise, the `Or` does the following:
- _pops_ `DataType::Boolean` for the righthand-side;
- _pops_ `DataType::Boolean` for the lefthand-side; and
- _pushes_ `DataType::Boolean` that is the disjunction of the LHS and RHS.

The following errors can occur during this process:
- `Empty stack` when popping;
- `Type error` when the popped values are not a `bool`; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "or"
}
```

### Add
_Identifier: `"add"`_

Performs arithmetic addition _or_ string concatenation on the top two values on the stack. Which of the two depends on the types of the popped values.

The `Add` does not introduce additional fields.

Stack-wise, the `Add` does the following:
- _pops_ `DataType::Integer`, `DataType::Real` or `DataType::String` for the righthand-side;
- _pops_ `DataType::Integer`, `DataType::Real` or `DataType::String` for the lefthand-side; and
- _pushes_ `DataType::Integer`, `DataType::Real` or `DataType::String` depending on the input types:
    - If both arguments are `DataType::Integer`, then a new integer is pushed that is the arithmetic addition of the LHS and RHS;
    - If both arguments are `DataType::Real`, then a new real is pushed that is the arithmetic addition of both the LHS and RHS; and
    - If both arguments are `DataType::String`, then a new string is pushed that is the concatenation of the LHS and then the RHS.

The following errors may occur when processing an `Add`:
- `Empty stack` when popping;
- `Type error` when the popped values do not match any of the three cases above;
- `Overflow error` when the addition results in integer/real addition; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "add"
}
```

### Sub
_Identifier: `"sub"`_

Performs arithmetic subtraction on the top two values on the stack.

The `Sub` does not introduce additional fields.

Stack-wise, the `Sub` does the following:
- _pops_ `DataType::Integer` or `DataType::Real` for the righthand-side;
- _pops_ `DataType::Integer` or `DataType::Real` for the lefthand-side; and
- _pushes_ `DataType::Integer` or `DataType::Real` depending on the input types:
    - If both arguments are `DataType::Integer`, then a new integer is pushed that is the arithmetic subtraction of the LHS and RHS; and
    - If both arguments are `DataType::Real`, then a new real is pushed that is the arithmetic subtraction of both the LHS and RHS.

The following errors may occur when processing an `Add`:
- `Empty stack` when popping;
- `Type error` when the popped values do not match any of the two cases above;
- `Overflow error` when the subtraction results in integer/real underflow; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "sub"
}
```

### Mul
_Identifier: `"mul"`_

Performs arithmetic multiplication on the top two values on the stack.

The `Mul` does not introduce additional fields.

Stack-wise, the `Mul` does the following:
- _pops_ `DataType::Integer` or `DataType::Real` for the righthand-side;
- _pops_ `DataType::Integer` or `DataType::Real` for the lefthand-side; and
- _pushes_ `DataType::Integer` or `DataType::Real` depending on the input types:
    - If both arguments are `DataType::Integer`, then a new integer is pushed that is the arithmetic multiplication of the LHS and RHS; and
    - If both arguments are `DataType::Real`, then a new real is pushed that is the arithmetic multiplication of both the LHS and RHS.

The following errors may occur when processing an `Add`:
- `Empty stack` when popping;
- `Type error` when the popped values do not match any of the two cases above;
- `Overflow error` when the multiplication results in integer/real overflow; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "mul"
}
```

### Div
_Identifier: `"div"`_

Performs arithmetic division on the top two values on the stack.

The `Div` does not introduce additional fields.

Stack-wise, the `Div` does the following:
- _pops_ `DataType::Integer` or `DataType::Real` for the righthand-side;
- _pops_ `DataType::Integer` or `DataType::Real` for the lefthand-side; and
- _pushes_ `DataType::Integer` or `DataType::Real` depending on the input types:
    - If both arguments are `DataType::Integer`, then a new integer is pushed that is the _integer_ division of the LHS and RHS (i.e., rounded down to the nearest integer); and
    - If both arguments are `DataType::Real`, then a new real is pushed that is the _floating-point_ division of both the LHS and RHS.

The following errors may occur when processing an `Add`:
- `Empty stack` when popping;
- `Type error` when the popped values do not match any of the two cases above;
- `Overflow error` when the division results in real underflow; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "div"
}
```

### Mod
_Identifier: `"mod"`_

Computes the remainder of dividing one value on top of the stack with another.

The `Mod` does not introduce additional fields to do so.

Stack-wise, the `Mod` does the following:
- _pops_ `DataType::Integer` for the righthand-side;
- _pops_ `DataType::Integer` for the lefthand-side; and
- _pushes_ `DataType::Integer` that is the remainder of dividing the LHS by the RHS.

The following errors may occur when processing a `Mod`:
- `Empty stack` when popping;
- `Type error` when the popped values are not `int`s; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "mod"
}
```

### Eq
_Identifier: `"eq"`_

Compares the top two values on the stack for equality. This is first type-wise (their types must be equal), and then value-wise.

No additional fields are introduced to do so.

Stack-wise, the `Eq` does the following:
- _pops_ `DataType::Any` for the righthand-side;
- _pops_ `DataType::Any` for the lefthand-side; and
- _pushes_ `DataType::Boolean` with true if the LHS equals the RHS, or false otherwise.

The following errors may occur when processing an `Eq`:
- `Empty stack` when popping; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "eq"
}
```

### Ne
_Identifier: `"ne"`_

Compares the top two values on the stack for inequality. This is first type-wise (their types must be unequal), and then value-wise.

No additional fields are introduced to do so.

Stack-wise, the `Ne` does the following:
- _pops_ `DataType::Any` for the righthand-side;
- _pops_ `DataType::Any` for the lefthand-side; and
- _pushes_ `DataType::Boolean` with true if the LHS does _not_ equal the RHS, or false otherwise.

The following errors may occur when processing an `Eq`:
- `Empty stack` when popping; or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "ne"
}
```

### Lt
_Identifier: `"lt"`_

Compares the top two values on the stack for order, specifically less-than. This can only be done for numerical values.

No additional fields are introduced to do so.

Stack-wise, the `Lt` does the following:
- _pops_ `DataType::Numeric` for the righthand-side;
- _pops_ `DataType::Numeric` for the lefthand-side; and
- _pushes_ `DataType::Boolean` with true if the LHS is stricly less than the RHS, or false otherwise.

The following errors may occur when processing an `Lt`:
- `Empty stack` when popping;
- `Type error` when either argument is not a `num` _or_ they are not of the same type (i.e., cannot compare `int` with `real`); or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "lt"
}
```

### Le
_Identifier: `"le"`_

Compares the top two values on the stack for order, specifically less-than-or-equal-to. This can only be done for numerical values.

No additional fields are introduced to do so.

Stack-wise, the `Le` does the following:
- _pops_ `DataType::Numeric` for the righthand-side;
- _pops_ `DataType::Numeric` for the lefthand-side; and
- _pushes_ `DataType::Boolean` with true if the LHS is less than or equal to the RHS, or false otherwise.

The following errors may occur when processing an `Le`:
- `Empty stack` when popping;
- `Type error` when either argument is not a `num` _or_ they are not of the same type (i.e., cannot compare `int` with `real`); or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "le"
}
```

### Gt
_Identifier: `"gt"`_

Compares the top two values on the stack for order, specifically greater-than. This can only be done for numerical values.

No additional fields are introduced to do so.

Stack-wise, the `Gt` does the following:
- _pops_ `DataType::Numeric` for the righthand-side;
- _pops_ `DataType::Numeric` for the lefthand-side; and
- _pushes_ `DataType::Boolean` with true if the LHS is strictly greater than to the RHS, or false otherwise.

The following errors may occur when processing an `Gt`:
- `Empty stack` when popping;
- `Type error` when either argument is not a `num` _or_ they are not of the same type (i.e., cannot compare `int` with `real`); or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "gt"
}
```

### Ge
_Identifier: `"ge"`_

Compares the top two values on the stack for order, specifically greater-than-or-equal-to. This can only be done for numerical values.

No additional fields are introduced to do so.

Stack-wise, the `Ge` does the following:
- _pops_ `DataType::Numeric` for the righthand-side;
- _pops_ `DataType::Numeric` for the lefthand-side; and
- _pushes_ `DataType::Boolean` with true if the LHS is greater than or equal to the RHS, or false otherwise.

The following errors may occur when processing an `Ge`:
- `Empty stack` when popping;
- `Type error` when either argument is not a `num` _or_ they are not of the same type (i.e., cannot compare `int` with `real`); or
- `Stack overflow` when pushing.

Example:
```json
{
    "kind": "ge"
}
```

### Array
_Identifier: `"arr"`_

Consumes a number of values from the top off the stack and creates a new Array with them.

The `Array` specifies the following additional fields:
- `l` (number): The number of elements to pop, i.e., the length of the array.
- `t` ([`DataType`](./schema.md#the-datatype)): The data type of the array. Note that this includes the `arr` datatype and its element type.

Stack-wise, the `Array` does the following:
- _pops_ `l` values of type `t`; and
- _pushes_ `DataType::Array` with `l` elements of type `t`. Note that the order of elements is reversed (i.e., the first element popped is the last element of the array).

Doing so may trigger the following errors:
- `Empty stack` when popping;
- `Type error` when a popped value does not have type `t`; or
- `Stack overflow` when pushing.

Example:
```json
// Represents an array literal of length 5, element type `str`
{
    "kind": "arr",
    "l": 5,
    "t": { "kind": "arr", "t": { "kind": "str" } }
}
```

### ArrayIndex
_Identifier: `"arx"`_

Indexes an array value on top of the stack with some index and outputs the element at that index.

The `ArrayIndex` specifies the following additional fields:
- `t` ([`DataType`](./schema.md#the-datatype)): The data type of the element. This is the type of the pushed value.

Stack-wise, the `ArrayIndex` does the following:
- _pops_ [`DataType::Integer`] for the index;
- _pops_ [`DataType::Array`] for the array to index, which must have element type `t`; and
- _pushes_ a value of type `t` that is the element at the specified index.

Doing so may trigger the following errors:
- `Empty stack` when popping;
- `Type error` when any of the popped values are incorrectly typed;
- `Array out-of-bounds` when the index is too large for the given array, or if it's negative; or
- `Stack overflow` when pushing.

Example:
```json
/// Indexes an array of string elements
{
    "kind": "arx",
    "t": { "kind": "str" }
}
```

### Instance
_Identifier: `"ins"`_



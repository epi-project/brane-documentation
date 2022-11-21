# Data types
Like most programming languages, BraneScript has a notion of data types. This determines how variable values are represented in memory, and, in the context of BraneScript, provides a way for the compiler to verify which values are allowed to go in a(n external) function so your code doesn't have to worry about this.

We will first discuss the different types that exist in BraneScript. Then, we will talk about some resolving rules for expressions, after which we conclude by talking about data types and external package calls.


## Supported types
BraneScript supports the following types as builtin-types:
- `integer` (often shortened to `int`): A simple number without a fractional part. Note that BraneScript makes no distinction between signed or unsigned numbers; every integer is represented as a 64-bit signed integer.
- `real`: A number with a fractional part. In the backend, these are presented as double-precision floating-point numbers.
- `boolean` (often shortened to `bool`): A simple `true`/`false` value.
- `string`: A unicode (UTF-8) string that contains arbitrary characters.
- `void`: A special type that cannot be created, but is used to indicate that a function does not return anything.

(Apart from `void`, the name of each type may be used in `container.yml` as input/output arguments for an external function).

Aside from that, Brane considers every Class definition to be its own type. This means that one can further limit the arguments passed to a function by defining a Class as input type. Anything not properly parsed as a builtin type is assumed to be a Class type (e.g., `Jedi` is assumed to be a class type).

Every type also has an array-variant, which represents an array of the given type. This is written as the name of the type followed by two square brackets, e.g., `integer[]` represents an integer array, and `integer[][]` represents an array of integer arrays.


## Expression rules
Typically, expressions only work on a subset of all types instead of all of them. For example, it doesn't make a whole lot of sense to subtract a `string` from a `string`, or a `Jedi` from a `boolean`.

Because expressions may grow arbitrarily large, every type of expression uses strict rules* about what can be accepted as input and what will be returned for subsequent expressions.

To showcase this, we will use the following syntax to define 'rules' for deriving types:
- We write expressions as we would in BraneScript before the arrow (`->`)
- We write the type they evaluate to after the arrow.
- We can write values (e.g., `42`) to mean 'values of this type', not 'this value only'
- We may also write types (e.g., `int`), which _do_ mean 'this type only'.
- Any non-constant letter in capital (e.g., `T`) is a placeholder; it shows patterns rather than specific types. In that case, the rule applies to any combination of types that satisfies the pattern.
- We may write an identifier between brackets (e.g., `<field>`) to mean some identifier that is the same as other occurrences, but otherwise arbitrary.

We will now provide the rules in the same organisation as the [expression](./expressions.md) chapter.


### Constants
- Integers
  - `42 -> int`
- Reals
  - `42.0 -> real`
- Booleans
  - `true -> bool`
- Strings
  - `"Hello there!" -> string`

### Array expressions
- Arrays
  - `[T, T, ...] -> T[]`

### Class instantiation
- Instances
  - `new T { <prop1>: U, <prop2>: V, ... } -> T`

### Unary operators
- Logical negation
  - `!bool -> bool`
- Arithmetic negation
  - `-int -> int`
  - `-real -> real`
- Brackets
  - `(T) -> T`

### Binary operators (arithmetic)
- Addition
  - `int + int -> int`
  - `real + int -> real`
  - `int + real -> real`
  - `real + real -> real`
  - `string + string -> string`
- Subtraction
  - `int - int -> int`
  - `real - int -> real`
  - `int - real -> real`
  - `real - real -> real`
- Multiplication
  - `int * int -> int`
  - `real * int -> real`
  - `int * real -> real`
  - `real * real -> real`
- Division
  - `int / int -> int`
  - `real / int -> real`
  - `int / real -> real`
  - `real / real -> real`
- Modulo
  - `int % int -> int`

### Binary operators (comparison)
- Less than
  - `int < int -> bool`
  - `real < int -> bool`
  - `int < real -> bool`
  - `real < real -> bool`
- Less than or equal to
  - `int <= int -> bool`
  - `real <= int -> bool`
  - `int <= real -> bool`
  - `real <= real -> bool`
- Greater than
  - `int > int -> bool`
  - `real > int -> bool`
  - `int > real -> bool`
  - `real > real -> bool`
- Greater than or equal to
  - `int >= int -> bool`
  - `real >= int -> bool`
  - `int >= real -> bool`
  - `real >= real -> bool`
- Equality
  - `T == U -> bool`
- Inequality
  - `T != U -> bool`

### Binary operators (logical)
- Disjunction
  - `bool || bool -> bool`
- Conjunction
  - `bool && bool -> bool`

### Index operators
- Array indexing
  - `T[][int] -> T`  
    (note that `T[]` is an array)
- Projection
  - `T.<field> -> U`  
    (where, obviously, the `<field>` in the class has type `U`).

### Calling
- Calling
  - `<ident>(T, U, ...) -> V`  
    (where `T`, `U` and so on should match with the function's signature, and `V` is the function's return type).

_* Although the rules are strict, the compiler is happy to do some work for you to make them appear easier; see the next section._


## (Implicit) type conversion
To make life for the programmer a bit easier, the compiler performs quite a bit of 'automatic type conversion' for you. Not all types can be converted into all others, but if the compiler detects that a conversion is needed and possible, it will automatically do so for you.

Note that the compiler is quite aggressive in this, which may lead to unexpected behaviour (see the [next section](#statement-rules)). As a rule of thumb, anywhere where a conversion _might_ happen is one where it _will_ happen.

The following conversions are allowed and may happen implicitly:
- `integer` -> `bool`  
  In this case, any non-zero integer value is converted to 'true' (also negative values), and only '0' is converted to 'false'.
- `boolean` -> `integer`  
  In this case, 'true' is converted to '1', and 'false' is converted to '0'.
- `integer` -> `real`  
  In this case, the real has no decimal part (since the integer will never either).
- `T` -> `string`  
  In this case, the given value will be converted to a properly formatted string counterpart. This property allows any value to always be printed meaningfully.
- `T` -> `T[]`  
  In this case, the array will have only one value, which is the converted one.
- `T[] -> U[]`  
  **Note**: This is only allowed if `T` -> `U` is allowed.

Then there are also conversions that are allowed but that may only happen explicitly (i.e., with a cast-expression):
- `real` -> `integer`  
  In this case, the real number is rounded-down to the nearest integral value.

A few extra cases to be aware of implicit type conversion are:
- An addition always tries to upcast the other argument to a `string` if one of them is as well.
- A division on only `integer`s is different than one on `real`s. If any of the argument is a `real`, then the other is automatically converted to one as well, resulting in a real division.
- Integers are implicitly converted to reals, but not back; this means that it gets tricky when intermixing modulos into large expressions.

On a final note, note that the compiler may not always be able to properly deduce types (especially in the case of local functions). That means that some errors are only catched during runtime, resulting in much less descriptive messages. Consider using [type hints](#type-hints) as much as possible.


## Statement rules
Now we get to a section that may get thorny if not done properly.

To be able to write code without type hints, the compiler automatically deduces the type of variables based on the value they had _the moment they were declared_. Or, put differently: the type of the expression at a `let`-statement determines the type of the variable for the rest of its lifetime (the same applies to function arguments).

This can lead to the following situations:
```branescript
// The variable is declared as an int
let a := 42;
// This variable is declared as a float
let b := 2.0;

// Uh-oh! Error, cannot assign float to int (because that implicit conversion cannot be made).
a := a + b;
```
even though one might assume that it would automatically work.

<!-- More examples needed -->


## Types & external package calls
All of the typing up to this point discusses values that never leave BraneScript. However, when external functions come into play, the variables will have to be serialized in order to be passed as environment variables. In this section, we define how every type is serialized and is thus received by external functions.

First, atomic types are converted as follows:
- `integer`: Simply converted to a string of numbers, representing the number in base 10.
- `real`: Simply converted as a string of numbers, representing the number in base 10 (with a fractional part, separated by a dot).
- `boolean`: Converted to `true` or `false` (as strings).
- `string`: Simply passed as-is to the environment variables.

Composite types (i.e., Arrays and Classes) are passed as JSON values. Specifically, an Array is passed as a JSON array:
```json
// Example array of integers
[ 0, 1, 2, 3, 4 ]

// Example array of arrays
[ [0, 1, 2], [3, 4, 5], [6, 7, 8] ]
```
and a Class as a JSON map:
```json
// We turn to our good ol' Jedi example; this represents `obi_wan`
{
    // Atomic types are now given in JSON-form as well.
    "name": "Obi-Wan Kenobi",
    "lightsaber_colour": "blue",
    "is_master": true
}

// A more complex class
{
    "list_of_arrays": [ [0, 1, 2], [3, 4, 5], [6, 7, 8] ],
    "nested_class": {
        "name": "Obi-Wan Kenobi",
        "lightsaber_colour": "blue",
        "is_master": true
    }
}
```
(note that both JSON-values are probably minified, i.e., without any whitespace).

Note that in all cases, we expect the package code to know what kind of values it expects. This includes the classes, from which follows an additional rule that classes may only be passed to external functions if it is defined in that function's package _or_ if it is a builtin class (see the [relevant chapter](./builtins.md#builtin-classes)).


## Next
If you want to know more about [statements](./statements.md) or [expressions](./expressions.md) in BraneScript, you can go back to the previous chapters (if you haven't read them yet).

Otherwise, you can go on with more language features: read about [builtin functions and classes](./builtins.md), [scoping rules](./scoping.md) or [annotations](./annotations.md).

If you are done with reading on BraneScript, you can learn how to write and upload workflows by going to the [Scientist](../scientists/introduction.md) series of chapters.

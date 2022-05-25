# Data types
Like most programming languages, BraneScript has a notion of data types. This determines how variable values are represented in memory, and, in the context of BraneScript, provides a way for the interpreter to filter which values are allowed to go in a(n external) function so your code doesn't have to worry about this.

We will first discuss the different types that exist in BraneScript. Then, we will talk about some resolving rules for expressions, after which we conclude by talking about data types and external package calls.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> This documentation is still a little rough. It will be elaborated soon.


## Supported types
BraneScript supports the following types as builtin-types:
- `integer`: A simple number without a fractional part. Note that BraneScript makes no distinction between signed or unsigned numbers; every integer is represented as a 64-bit signed integer.
- `real`: A number with a fractional part. In the backend, these are presented as double-precision floating-point numbers.
- `boolean`: A simple `true`/`false` value.
- `string`: A unicode (UTF-8) string that contains arbitrary characters.
- `unit`: Short for "unitialized", this is the default type returned by functions that don't return anything.

(Apart from `unit`, the name of each type may be used in `container.yml` as input/output arguments for an external function).

Aside from that, Brane considers every Class definition to be its own type. This means that one can further limit the arguments passed to a function by defining a Class as input type.

Every type also has an array-variant, which represents an array of the given type.


## Expression rules
When resolving expressions, Brane will usually complain if it encounters an expression with the incorrect type when applying an operator to it. Specifically, most operators only work on `integer` or `real` expressions, where they may be intermixed. If so, then the `integer` will automatically be casted to a `real` as well.

For arrays, Brane will throw a type error if one of the elements does not match any of the other, i.e., an Array has to exist of elements of the same type. For classes, this means that every element has to be an instance of the same class.

Boolean expressions are _not_ converted to integers automatically. To convert them, use a simple if-statement.


## Types & external package calls
Even though types determine the representation of variables within BraneScript, this because a bit more shakey when the values are transferred to external packages calls.

Because they are passed as environment variables, all of the values have to be serialized. For the atomic types, this is done as follows:
- `integer`: Simply converted to a string of numbers, representing the number in base 10.
- `real`: Simply converted as a string of numbers, representing the number in base 10 (with a fractional part).
- `boolean`: Converted to `true` or `false` (as strings).
- `string`: Simply passed as-is to the environment variables.

Arrays are a little more complicated, and the exact process is described in the [`container.yml` documentation](../packages/container_yml.md). However, it's good to know that its elements will be converted individually according to the rules presented here.

Classes are similarly complicated, but their properties are converted in the same way as laid out here. The only difference with arrays is that the properties are converted on an individual basis, due to their types being divergent.


## Next
If you want to know more about [statements](./statements.md) or [expressions](./expressions.md) in BraneScript, you can go back to the previous chapters (if you haven't read them yet).

Otherwise, you can learn how to write and upload workflows by going to the [Scientist](../scientists/introduction.md) series of chapters.

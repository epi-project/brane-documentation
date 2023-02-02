# Expressions
To perform calculations in the domain of BraneScript itself, it has the concept of _expressions_ (like most languages).

Unlike statements, expressions always have a return value, which may be processed by a statement to do some work.

In the following sections, we will run through the different types of expressions and operators that BraneScript supports.


## Constants
The simplest expression is using just a constant (also called a _literal_). BraneScript defines the following constants:
- Integers, which are whole numbers of the [`integer`](./types.md#integers) data type. They are written as simple numbers (positive) without any fractional parts.
  - e.g., `0`, `42`, `100204024`, ...

  You can use the arithmetic negation (see [below](#unary-operators)) to create negative constants.  
  Note that BraneScript integers are always 64-bit.
- Reals, which are numbers (either positive or negative) that have a fractional part (i.e., the [`real`](./types.md/#reals) data type).
  - e.g., `0.0`, `42.84`, `-42.333`, `101231231.1231315`, ...

  In BraneScript, they are always double-precision (i.e., 64-bit).
- Booleans, which are simple `true`/`false` binary values (the [`boolean`](./types.md#booleans) data type).
- Strings, which define a piece of unicode text (The [`string`](./types.md#strings) data type).
  - e.g., `"Hello, world!"`, ...

For example, an expression:
```bscript
42
```
will evaluate to a value of `42` of data type `integer`. Similarly,
```bscript
"Hello, world!"
```
evaluates to a value of `Hello, world!` of data type `string`.


## Identifiers
TODO


## Array expressions
Aside from just simple constants, BraneScript also supports a notion of Arrays. These are objects with zero or more elements of the same type, that will be stored together in one variable.

The formal syntax is:
```bscript
[<elem>, <elem>, <...>]
```

For example, the following defines an array that stores the integers 1 through 5:
```bscript
let one_to_five := [ 1, 2, 3, 4, 5 ];
```
These Arrays can then be _indexed_ to obtain a single value from among the array. How to do so is discussed below, in the [Unary operators](#array-indexing) section.


## Class instantiation
We can also define classes in BraneScript, as described the in [Statements](./statements.md#classes) chapter. Once defined, we can then _instantiate_ them, which is simply filling in the blueprint with a specific set of variables.

The formal syntax for this is:
```bscript
new <name> { <prop1> := <value>, <prop2> := <value>, <...> };
```
(or, more readable:)
```bscript
new <name> {
    <prop1> := <value>,
    <prop2> := <value>,
    <...>
};
```
Of course, if a class has no properties, then the list may be empty.

For example, to instantiate our [Jedi-class](./statements.md#classes), we could run:
```bscript
let obi_wan := new Jedi {
    name := "Obi-Wan Kenobi",
    is_master := true,
    lightsaber_colour := "blue"
};
```
The `obi_wan` variable will then carry an _instance_, which we may use in the rest of the workflow in an Object-Oriented Programming-style.

To know how, refer to the [projection operator](#the-projection-operator) section.


## Unary operators
A unary operator is an operator that works on a single expression. BraneScript knows of two unary operators:
- The logical negation operator `!`. This simply inverts the value of a `boolean` expression. For example:
  ```bscript
  !false
  ```
  will evaluate to `true`.
- The arithmetic negation, which multiplies some number expression (either `integer` or `real`) with `-1`. For example:
  ```bscript
  -42
  ```
  would evaluate to `-42`, and
  ```bscript
  --42.0
  ```
  would evaluate to `42.0`.

Then, it defines one other "unary" operator that is slightly more complex:
- To be able to manually specify precedence in an expression, one may use parenthesis to make sure that the expression inside of it is evaluated first.

  The formal syntax is:
  ```bscript
  (<expression>)
  ```
  The following example illustrates the effect of the brackets:
  ```bscript
  // Returns -21
  let res := 42 - 42 - 21;
  
  // Returns 21
  let res := 42 - (42 - 21);
  ```


## Binary operators
A second type of expression operators are binary operators, which operate on two expressions.

There are multiple classes of binary operators, treated in the next subsections.


### Arithmetic operators
BraneScript defines five arithmetic operators:
- Addition: In the case of integer or real expressions, adds the two together and evaluates to the resulting value. In the case of two strings, appends the second string to the first. The syntax is:
  ```bscript
  <lhs expression> + <rhs expression>
  ```
  e.g.
  - `42 + 42` -> `84`
  - `-23.0 + 22.2` -> `-0.8`
  - `42 + 42.0` -> `84.0`
  - `"Hello, " + "world!"` -> `"Hello, world!"`
- Subtraction: In the case of integer or real expressions, subtracts the right-hand side from the left-hand side and evaluates to the resulting value. The syntax is:
  ```bscript
  <lhs expression> - <rhs expression>
  ```
  e.g.
  - `42 - 42` -> `0`
  - `-23.0 - 22.2` -> `-45.2`
  - `42 - 42.0` -> `0.0`
- Multiplication: In the case of integers or reals, multiplies the left-hand side with the right-hand side, evaluating to the resulting value. The syntax is:
  ```bscript
  <lhs expression> * <rhs expression>
  ```
  e.g.
  - `42 * 42` -> `1764`
  - `-23.0 * 22.2` -> `-510.6`
  - `42 * 42.0` -> `1764.0`
- Division: In the case of two integer expressions, performs an integer division of the left-hand side divided by the right-hand side (i.e., performs the division but always rounds the result down to a whole integer. Can be thought of as "how many times does the right-hand side wholly fit in the left-hand side"). In the case of two real expressions, or a combination of integer and real expressions, performs a real division of the left-hand side divided by the right-hand side. The syntax is:
  ```bscript
  <lhs expression> / <rhs expression>
  ```
  e.g.
  - `42 / 42` -> `1`
  - `20 / 9` -> `2`
  - `-23.0 / 22.2` -> `-1.03603603604`
  - `42 / 42.0` -> `1.0`
- Modulo: In the case of two integer expressions, returns the first value modulo the second one. Can be seen as computing the 'remainder' after dividing the first value by the second. The syntax is:
  ```bscript
  <lhs expression> % <rhs expression>
  ```
  e.g.
  - `42 % 42` -> `0`
  - `20 % 9` -> `2`
  - `5 % 42` -> `5`


### Comparison operators
BraneScript also supports the usual set of comparison operators, who take integer or real expressions in and return boolean expressions that says something about their relative size.

The supported operators are:
- Less than: In the case of integer or real expressions, returns `true` only when the left-hand side is smaller than the right-hand side. The syntax is:
  ```bscript
  <lhs expression> < <rhs expression>
  ```
  e.g.
  - `42 < 84` -> `true`
  - `84.0 < 42.0` -> `false`
  - `42 < 42.0` -> `false`
  - `42 < 42.1` -> `true`
- Less than or equal to: In the case of integer or real expressions, returns `true` only when the left-hand side is smaller than the right-hand side _or_ both sides have the same value. The syntax is:
  ```bscript
  <lhs expression> <= <rhs expression>
  ```
  e.g.
  - `42 <= 84` -> `true`
  - `84.0 <= 42.0` -> `false`
  - `42 <= 42.0` -> `true`
  - `42 <= 42.1` -> `true`
- Greater than: In the case of integer or real expressions, returns `true` only when the left-hand side is larger than the right-hand side. The syntax is:
  ```bscript
  <lhs expression> > <rhs expression>
  ```
  e.g.
  - `42 > 84` -> `false`
  - `84.0 > 42.0` -> `true`
  - `42 > 42.0` -> `false`
  - `42 > 42.1` -> `false`
- Greater than or equal to: In the case of integer or real expressions, returns `true` only when the left-hand side is greater than the right-hand side _or_ both sides have the same value. The syntax is:
  ```bscript
  <lhs expression> >= <rhs expression>
  ```
  e.g.
  - `42 >= 84` -> `false`
  - `84.0 >= 42.0` -> `false`
  - `42 >= 42.0` -> `true`
  - `42 >= 42.1` -> `false`

As a special case of the comparison operators, we also define the equals and not-equals operators, which work on any two values (regardless of the type):
- Equals: For any two expressions, returns `true` only if they have the same data type and evaluate to the same value. Note that this means that when comparing an integer with a real, this operator always returns `false` regardless whether they actually represent the same value. The syntax is:
  ```bscript
  <lhs expression> == <rhs expression>
  ```
  e.g.
  - `42 == 84` -> `false`
  - `42 == 42` -> `true`
  - `"Hello there!" == "Hello there!"` -> `true`
  - `42.0 == 42` -> `false`
  - `88 == "Hello there!"` -> `false`
- Not equals: The opposite of Equals. For any two expressions, returns `true` only if they have different data types _or_ evaluate to different values if they do have the same data type. Note that this means that when comparing an integer with a real, this operator always returns `true` regardless whether they actually represent the same value. The syntax is:
  ```bscript
  <lhs expression> != <rhs expression>
  ```
  e.g.
  - `42 != 84` -> `true`
  - `42 != 42` -> `false`
  - `"Hello there!" != "Hello there!"` -> `false`
  - `42.0 != 42` -> `true`
  - `88 != "Hello there!"` -> `true`


### Logical operators
Then there are some binary operators who only work on two boolean expressions:
- Logical disjunction: In the case of two boolean expressions, returns `true` only if only one or both of the expressions evaluate to `true`. The syntax is:
  ```bscript
  <lhs expression> || <rhs expression>
  ```
  e.g.
  - `true || true` -> `true`
  - `true || false` -> `true`
  - `false || true` -> `true`
  - `false || false` -> `false`
- Logical and: In the case of two boolean expressions, returns `true` only if both of the expressions evaluate to `true`. The syntax is:
  ```bscript
  <lhs expression> && <rhs expression>
  ```
  e.g.
  - `true && true` -> `true`
  - `true && false` -> `false`
  - `false && true` -> `false`
  - `false && false` -> `false`

Note that BraneScript uses short-circuit boolean evaluation. This means that, if we can already deduce the value of either of these operators based on their left-hand side (e.g., `true || false`), then we do not evaluate the righthand-side. This matters in the following example:
```bscript
func print_true() {
    print("I'm printing true!");
    return true;
}

func print_false() {
    print("I'm printing false!");
    return false;
}

print_true() | print_false();
```
This will only print `"I'm printing true!"`, and not `"I'm printing false!"`.


## Index operators
### Array indexing
To get a single value from an Array, we can use the Array index operator to get the value of one. It is defined as follows:
```bscript
<array>[<integer expression>]
```
which evaluates to a single value of the same type as the Array.

The index to retrieve is calculated by the integer expression. Note that BraneScript arrays are zero-indexed. For example:
```bscript
let test := [ 1, 2, 3 ];
let one := test[0];
let two := test[1];
let three := test[2];
```
causes the variables `one`, `two` and `three` to have the same value as their name.


### The projection-operator
To get a single property from a class, BraneScript defines the projection operator. Given an object instance and a name, it will evaluate to the value of that property in _that specific instance_.

The formal syntax is:
```bscript
<instance>.<property>
```

For example, we might use our [instantiated Jedi class](#class-instantiation) to query about the name of the `obi_wan` Jedi:
```bscript
print("The Jedi's name is " + obi_wan.name);
```
In this example, we query the value of the `name` property in the Jedi class. While the name and its type are constant across all instantiations, its value may differ. For example:
```bscript
// I'm using the same class definition
let anakin := new Jedi { name := "Anakin Skywalker", is_master := false, lightsaber_colour := "blue" };
print("The Jedi's name is " + anakin.name);
```
This will print `Anakin Skywalker` instead of `Obi-Wan Kenobi`.

In a similar manner, the dot operator can also help us call functions:
```bscript
obi_wan.swoosh()
```
Note that we do not have to pass the `self` parameter of our function. BraneScript will do this automatically in the background. Any other arguments _do_ have to be passed normally.


## Calling
Finally, BraneScript can, of course, call other functions.

For both local as external functions, the syntax is the same:
```bscript
<ident>(<arg1>, <arg2>, ...)
```

This calls a function with identifier `<ident>` with the given arguments. For example:
```bscript
print("Finally, we get to this one")
```

For methods (i.e., functions in classes) you have to use a projection first:
```bscript
obi_wan.swoosh()
```
Remember that in that case, the `self`-argument is automatically given by the compiler.


## Next
In the [next chapter](./types.md), we will discuss various data types that Brane supports, and also some more details on how these are propagated through statements and expressions. We recommend reading this to anyone, as the compiler attempts to deduce quite a lot by itself, which may lead to unexpected consequences.

You can also start writing workflows, by reading the [chapters for Scientists](../scientists/introduction.md).

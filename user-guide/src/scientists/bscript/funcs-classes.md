# Functions & Composite Types
In the [previous chapter](./basics.md), we discussed the basic functionality and constructs of the BraneScript language: variables, control flow constructructs (if, for, while, parallel) and function calls.

This chapter will extend on that, and explains how to define functions (to match with the function calls). Moreover, we will also discuss classes and, while at it, arrays.


## Function definitions
To start, we will examine function definitions.

As already discussed in the [previous chapter](./basics.md#functions), functions are essentially snippets of code that can be executed from somewhere "in between" other code. We've already discussed how to call them, i.e., run their code from somewhere else; in this section we discuss how to define them.

A definition uses the following syntax:
```bscript
func <ID> ( <ARG1>, <ARG2>, ... ) {
    <STATEMENTS>
}
```
Just as with a call, the `<ID>` is the name of the new function, and in between the parenthesis (`()`) are zero or more arguments that this function can accept. They are given as identifiers, each of those specifying the name of that specific argument. The `<STATEMENTS>`, then, are the statements that are executed when this function is called.

The simplest function is one that neither takes any arguments, nor returns any value. An example of such a function is:
```bscript
// Define the function first
func print_hello_world() {
    println("Hello, world!");
}

// Now run it
print_hello_world();
```
This should print the string `Hello, world!` to the terminal.

In practise, however, there will be very few functions that neither take nor produce any values. So let's consider a function that takes some arguments:
```bscript
func print_text(text) {
    println(text);
}
```
The `text` is the argument that we want to pass to the function, and `println(text)` then uses that argument to pass as input to the `println` function. It may seem like arguments can be used very similar to variables, and that would be exactly write - because they are. They act and are local variables who are initialized with the values passed to the function.

Another example that is a bit more complex:
```bscript
func print_greeting_place(greeting, place) {
    print(greeting);
    print(", ");
    print(place);
    println("!");
}

// To do the same as `print_hello_world()`, we can run:
print_greeting_place("Hello", "world");

// But we can also do other stuff now
print_greeting_place("Sup", "planet");
```

The only thing left, then, is to define how a function returns a value.

To do so, we use the return-statement. It has the following syntax:
```bscript
return <EXPR>;
```
where `<EXPR>` is the expression that creates the value to return.

An example of how this works is by implementing the `zero()`- and `add()`-functions from the [previous chapter](./basics.md#functions):
```bscript
func zero() {
    return 0;
}

func add(lhs, rhs) {
    return lhs + rhs;
}
```
When called, this functions will evaluate to `0` or the sum of its arguments, respectively.

In addition to just returning values, a return acts as a 'quit'-command for a function; whenever it is called, the function is exited immediately, and the program resumes execution from the function call onwards - even if there are subsequent statements in the function body.

For example, consider the following function:
```bscript
func greet(person) {
    // Filter out rude names
    if (person == "stinky") {
        println("That is rude, I won't print that.");
        return;
    }

    // Otherwise, we can print
    print("Hello, ");
    print(person);
    println("!");
}
```
(Note that the expression can be omitted from the return-statement if the function does not return a value, as in this example. But it can also be used with expression.)

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Unlike other languages, BraneScript also allows the usage of a return-statement from the main workflow body (i.e., outside of a function). In this case, it can be used to early-quit the workflow (e.g., in an infinite while-loop) or to return a value from a workflow (relevant for packaged workflows (see [here](TODO)) or automatically downloading datasets (see [here](./data-results.md))).


## Arrays
Next, we will talk about arrays before we will talk about classes.

Most languages that have a concept of variables, also have a concept of arrays. These are essentially (ordered) sequences of values, collected into a single object. You can thus think of them as a single variable that contains multiple values, instead of one.

Note, however, that arrays can only accept values of the same type. For example, they can contain multiple integers, or multiple strings - but not a mix of those. This essentially makes them _homogeneous_ - every element has the same layout.

There are multiple syntaxes for working with arrays. The first is the _array literal_:
```bscript
[ <EXPR1>, <EXPR2>, ... ]
```
Here, there are zero or more expressions, where every `<EXPRX>` is some expression who's evaluated value we will store in the array.

For example, this will generate an array with the values `1`, `-5` and `0`:
```bscript
let value := -5;
let array := [ 1, value, zero() ];
```
It is also possible to create an array of arrays:
```bscript
let array := [ [ 0, 1, 2 ], [ 3, 4, 5 ], [ 6, 7, 8 ] ];
```

Then, to read a specific element in an array, or to write to the element, we can _index_ it. This is done using the following syntax:
```bscript
<ARRAY-EXPR>[ <INDEX-EXPR> ]
```
The `<ARRAY-EXPR>` is something that evaluates to an array (e.g., an array literal, a variable that contains an array, ...), and the `<INDEX-EXPR>` is something that evaluates to an integral number. Note that array indices in BraneScript are zero-indexed, so the first elements is addressed by `0`, the second by `1` and so on.

The following examples show some array indexing:
```bscript
let array1 := [ 1, 2, 3 ];
println(array1[0]);

let index1 := 2;
println(array1[index1])

println([ 4, 5, 6 ][1]);
println(generate_array_with_zeroes()[0]);
println(array1[zero()]);
```
This will print `1`, `3`, `5`, `0` and `1`, respectively.

We use the same syntax to write to an array, except that we then use the array in the variable position in an assignment:
```bscript
let array2 := [ 7, 8, 9 ];
array2[0] := 42;
println(array2);
```
This will print `[ 42, 8, 9 ]`.


## Classes
It is probably easier to understand classes after you understand arrays, so be sure to check out [their section](#arrays) first.

If arrays provide some _homogeneous_ collection of values, then classes provide a _heterogeneous_ collection. Specifically, we can think of classes as a collection of values but values who _can_ be of different types. Usually, because of this inherent difference between the values, we don't index classes by positions (like arrays), but instead we assign a name to each value and index by that. Some languages allow this quite literally (e.g., JavaScript), whereas other choose a different kind of syntax called _projection_ (e.g., C or Python). BraneScript uses the latter syntax as well.

Because of this heterogeneity, BraneScript requires you to specifically define classes, so that it knows beforehand which values are allowed in a specific class and how to name them.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> A specific class definition will act as its own type in BraneScript. This means that it's usually impossible to assign one class to another.
> 
> Technically, however, arrays do this as well, since it usually makes no sense to assign an array of strings to an array of integers. However, because of their uniform element type, array types are more lenient, whereas classes are almost always completely disjoint from each other.

Another key difference between arrays and classes (at least, in BraneScript) is that a class can associate functions with it, usually called methods. These methods, then, work on an explicit _instance_ of that class (i.e., a particular set of values) in addition to their normal arguments. This allows for Object-Oriented Programming (OOP) design patterns. For more information on OOP in general, see [here](https://www.educative.io/blog/object-oriented-programming).

We will first discuss the syntax and usage of classes as just data containers. To define a class, use the following syntax:
```bscript
class <ID> {
    <FIELD-ID-1>: <FIELD-TYPE-1>;
    <FIELD-ID-2>: <FIELD-TYPE-2>;
    ...
}
```
Here, `<ID>` is the name of the class (conventially written in [upper camel case](https://en.wikipedia.org/wiki/Camel_case)). Then follow zero or more _field definitions_ (an element within a class is referred to as a field), which consists of some identifier (`<FIELD-ID>`) as name and the type that determines what kind of values are allowed for that field (`<FIELD-TYPE>`).

To illustrate, consider the following class:
```bscript
class Jedi {
    name: string;
    lightsaber_colour: string;
    is_master: bool;
}
```
This class will contain three fields, or `string`, `string` and `bool`-type respectively.

Note, however, that class definitions ask like "blueprints" rather than a usable value. To do so, we _instantiate_ a class, which is the act of assigning values to the fields to create an object that we can use. In BraneScript, we use the following syntax for that:
```bscript
new <ID> {
    <FIELD-ID-1> := <EXPR1>,
    <FIELD-ID-2> := <EXPR2>,
    ...
}
```
(Note the usage of comma's (`,`) instead of semicolons (`;`) at the end of each line)

This tells the backend to create a new object from the definition with the name `<ID>`, and then populate the fields with the given names (`FIELD-ID`) with the value that the given expression evaluates to (`EXPR`).

Note that this is an expression itself, which will thus evaluate to an instance of the referred class. Furthermore, because the fields are named anyway, you don't have to use the same order as used in the class.

For example, we can instantiate our Jedi class as follows:
```bscript
let anakin := new Jedi {
    name := "Anakin Skywalker",
    lightsaber_colour := "blue",
    is_master := false,
};
```
Similary, we can create another `Jedi` with different properties:
```bscript
let obi_wan := new Jedi {
    name := "Obi-Wan Kenobi",
    lightsaber_colour := "blue",
    is_master := true,
};
```
As long as they refer to the same class, they have the same type, and can thus be used interchangeably.



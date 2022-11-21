# Statements
Like most languages, BraneScript defines _statements_, which it executes in the order it encounters them.

Every statement in BraneScript must be terminated with a semicolon `;`. While this may be tedious at times, it does mean that BraneScript is line-agnostic, i.e., you can execute multiple statements on the same line.

The specific statements that BraneScript supports are covered in the following sub-sections.


## Comments
Although not really a statement, BraneScript also has a concept of single-line comments. These are defined by a double forward slash (`//`) that cause the interpreted to ignore the rest of the current line.

For example:
```
// Even though all of this is illegal BraneScript, this is valid BraneScript!
```


## Variable assignments
BraneScript wouldn't be a scripting language if it did not support variables. However, unlike more dynamic languages like [Lua](https://lua.org), it knows a distinction between _defining_ variables and _updating_ them. Moreover, it has no concept of a `null` value that may be assigned to every type.

Thus, BraneScript has two different variable assignments. The first, the `let`-assignment, defines a variable and immediately assigns a value to it (because it cannot be `null`). It has the following syntax:
```branescript
let <variable_name> := <expr>;
```

Then, to update a variable, we can use the same syntax but without the `let`:
```branescript
<variable_name> := <expr>;
```

For example:
```branescript
let zero_or_one := 0;
zero_or_one := 1;
zero_or_one := 0;
```

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that, even though none are explicitly defined, every variable has a strict type that is deduced at the point of declaration (i.e., the `let`-statement). In some cases, this can lead to surprising results; check the chapter on [Data types](./types.md).


## If-statements
If-statements in BraneScript work like in most other languages. They define a choice for the interpreter to make based on some boolean expression. If this is true, the first codeblock is executed, and if it false, the second codeblock (or _else-clause_) is run.

It's syntax is as follows:
```branescript
if (<boolean expression>) {
    <statements-if-true>
} else {
    <statements-if-false>
}
```
where the else-part may be omitted for more concise code.

For example, a very simple if/else-statement might be:
```branescript
let number := 0;
if (true) {
    number := 1;
} else {
    number := 2;
}
```
which would result in the `number` variable having the value `1`.

Note, though, that unlike other languages, BraneScript has no syntactic sugar for an `else if` clause. Instead, you just have to nest the if-statements in the else-clause:
```branescript
if (<test>) {
    <some code>
} else {
    if (<alternative test>) {
        <other code>
    } else {
        ...
    }
}
```


## While-loops
To run code repeatedly, BraneScript defines while-loop. These work as expected, repeating their nested codeblock as long as some boolean expression evaluates to true.

Their syntax is as follows:
```branescript
while(<boolean expression>) {
    <statements>
}
```
To loop indefinitely, one might use a `true` boolean expression. However, be aware that BraneScript does not have a `break` statement, so this will typically block your program forever. The only way to escape loops is by using `return`s instead (see [below](#functions)).


## For-loops
Another way of running code repeatedly is using a special case of while-loops, called for-loops. These loops always iterate for a fixed number of loops, and are great when wanting to apply some operation to all elements in an array (see the [Expressions](./expressions.md#array-indexing) chapter).

The syntax is very similar to C, but is much more restrictive. Where in C, you are able to use any statement during the loop, BraneScript's is limited to:
```branescript
for (let <var> := <init>; <boolean expression>; <var> := <update>) {
    <statements>
}
```
For example, to iterate five times where, in each iteration, we step the loop variable with 1:
```branescript
let values := [ 0, 0, 0, 0, 0 ];
for (let i := 0; i < 5; i := i + 1) {
    values[i] := i;
}
```
This example should populate the `values` array with `[ 0, 1, 2, 3, 4 ]`.

Another example, but now we decrease the step variable by 5 on every iteration:
```branescript
let five := 0;
for (let i := 25; i > 0; i := i - 5) {
    five := five + 1;
}
```


## Functions
The main feature of BraneScript is being able to call functions.

It defines two types of functions: external or package functions (see [below](#imports)), and internal or DSL functions.

The latter can be defined as a function in BraneScript itself, to bundle code. This can be done by using the `func` keyword, defining a name, and then writing a comma-separated list of zero or more argument names enclosed in brackets. Formally:
```branescript
func <name>(<arg1>, <arg2>, ...) {
    <statements>
}
```

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note the lack of `;` at the end of the function definition. Unlike most statements, the compiler will complain if you add it here.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Unlike package functions, BraneScript functions do not (yet) define specific input or output types. Instead, these are deduced at runtime based on the actual types accepted in and returned by your function.

To return values from a function, we can use a `return`-statement like in other languages. For example, we can define a simple addition function:
```branescript
func add(lhs, rhs) {
    return lhs + rhs;
}
```

`return`-statements may also be used to early-quit a function that returns nothing:
```branescript
func hello_world(print_world) {
    print("Hello");
    if (!print_world) { return; }
    print(", World!");
}
```

See the relevant [expression definition](./expressions.md#function-calls) to find out how to call the functions.


## Classes
Variables and functions may be bundled together in a Class, which is an arbitrary collection of already existing types collected in a single object. Where arrays can be thought of as a memory area of _homogeneous_ elements, a class can be thought of as a memory area with _heterogeneous_ elements.

In addition to just being a container of types, classes also typically define _methods_, which are functions that work on a specific instance of that class.

For a proper tutorial on how classes work in general, check: [https://simple.wikipedia.org/wiki/Class_(programming)](https://simple.wikipedia.org/wiki/Class_(programming)).

We can distinguish three "stages" of a class: first, we define it, which is like describing a blueprint for each class. Then, we _instantiate_ it, which means that we build a specific object from the class with values. Finally, we can use the instance to carry around values or call functions.

The general syntax for defining classes looks as follows:
```branescript
class <name> {
    <property>
    <method>
    <property>
    ...
}
```
where properties and functions may be interlaced arbitrarily.

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note the lack of `;` at the end of the class definition. Unlike most statements, the compiler will complain if you add it here.

Defining a property, which is simply defining a variable to be part of this class, looks as follows:
```branescript
<name>: <type>;
```

Defining a method is very similar to defining normal functions, except that they are now defined within the body of the class. However, note that every class function gets the instantiated version as the first parameter, called `self`:
```branescript
func <name>(self, <args>) {
    <statements>
}
```
Unlike other languages, BraneScript has no concept of static methods; thus, all methods **must** have a `self`-argument.

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note the lack of `;` at the end of the method definition. Unlike most statements, the compiler will complain if you add it here.

For example, we may define a Jedi class, which describes all the information needed to define a single Jedi. Additionally, it also contains a `swoosh` method, which will let the Jedi "swing their sword":
```branescript
class Jedi {
    // Three properties
    name: string;
    is_master: bool;
    lightsaber_colour: string;

    // A method
    func swoosh(self) {
        print(self.name + " is swinging their " + self.lightsaber_colour + " lightsaber!");
    }
}
```

How to instantiate classes and use them is defined in the [Expressions](./expressions.md) chapter. Specifically, how to instantiate them can be found in the [Class instantiation](./expressions.md#class-instantiation) section, and how to use them in the [Dot operator](./expressions.md#the-dot-operator) section.


## Imports
Now we arrive at a more specialized construct in BraneScript.

In order to use package functions, there has to have some way of identifying them and defining the functions inside. In BraneScript, this is done using the `import`-statement: this pulls all package functions and types into the workflow namespace, allowing them to be used.

For example, if we have a package called `hello_world` and it defines a function called `say_hello_world`, then we can do the following:

```branescript
import hello_world;

say_hello_world();
```
Without the import statement, the interpreter will return that the function is undefined.

You can select a specific version by adding brackets and then the version number to the statement:
```branescript
// Obviously, the version '1.0.0' has to exist.
import hello_world[1.0.0];
```

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that import statements obey [scoping rules](./scoping.md), like any other statement. This means that the following works without any problems:
> ```branescript
> {
>     // Here we use version 1
>     import hello_world[1.0.0];
>     say_hello_world();
> }
> 
> {
>     // And here we happily use version 2, in the same workflow
>     import hello_world[2.0.0];
>     say_hello_world();
> }
> ```


## On
Another special statement for BraneScript is the `on`-statement, which forces any package calls to run on a specific site.

The syntax is:
```branescript
on <string literal> {
    <statements>
}
```
The list of location names can be requested with the Brane administrators.

For example, if we want to run it on the location called `location1`:
```branescript
on "location1" {
    print("Hello, world!");
}
```

Alternatively, one may also use a `location`-annotation (check [annotations](#annotations)).


## Parallel
The final Brane-specific construct if the `parallel`-statement. This statement defines an arbitrary number of blocks, each of which are then run concurrently. It can be thought of as basically 'forking' your script, possibly running each of the blocks (and most importantly, the external calls within it) in parallel. Then, after the parallel statement, the program makes sure that any synchronization is applied before continuing, and then continious as a normal, sequential program.

The syntax for such as a statement is:
```branescript
parallel [{
    <statements>
}, {
    <statements>
}, ...]
```

For example:
```branescript
parallel [{
    print("This is run...");
}, {
    print("...at the same time as this!");
}]
```

However, using parallel statements like this can easily introduce data races. To battle this, BraneScript uses the following rules when dealing with parallel statements:
- Every branch in the parallel statement will get a _copy_ of all variables and values. This means that, if you modify a global variable in one branch, the other will not see the modification. But both will see the value of the variable at the moment the parallel statement was initiated.
- Values cannot be returned from a parallel statement _except_ for using `return`-statements. In that case, a single value must be returned from each branch that must be of the same type as the other branches (see the [typing](./types.md) chapter for more information on how the type is analysed). Then, after the parallel statements 'joins' back into one, these are combined into one value according to a certain _merge strategy_:
  - `first`: Returns the value of the first branch that returns, waiting until all branches have completed before continuing. Note that this order is undefined due to the scheduling of threads and tasks.
  - `first*`: The same as `first`, except now that the other branches (who would return later) are actually terminated instead of waiting for their completion.
  - `last`: Returns the value of the last branch that returns. Here, too, the order of returning is undefinged due to the scheduling of threads and tasks.
  - `+` or `sum`: The values of all branches are added together. Can only used if they return addable values (see the [expression](./expressions.md) chapter).
  - `*` or `product`: The values of all branches are multiplied together. Can only used if they return multiplyable values (see the [expression](./expressions.md) chapter).
  - `max`: Returns the maximum value returned.
  - `min`: Returns the minimum value returned.
  - `all`: Returns all values as an array. Note that the order of values is undefined due to the scheduling of threads and tasks.

Using parallels to compute values probably warrants a few examples:
```branescript
let a := 42;
parallel [{
    a := a + 5;
    // Prints 47, not 42
    print(a);
}, {
    a := a - 5;
    // Prints 37, not 42
    print(a);
}];
```
```branescript
// Note the 'let' here to catch the value. The '[sum]' defines the merge strategy used.
let res := parallel [sum] [{
    return 42;
}, {
    return 42;
}];
// Prints '84'
print(res);
```
```branescript
// Another merge strategy
let res := parallel [first] [{
    return 24;
}, {
    return 42;
}];
// Prints '24' or '42', whichever happened to be scheduled and executed first
print(res);
```
```branescript
// Yet another merge strategy
let a := 24;
let res := parallel [max] [{
    a := a - 24;
    return a;
}, {
    a := a + 24;
    return a;
}];
// Prints '42'
print(res);
```
```branescript
// Final one
let res := parallel [all] [{
    return 24;
}, {
    return 42;
}];
// Prints '24' or '42', whichever happened to be completed first.
print(res[0]);
```


## Blocks
A final type of statement is a simple, loose block of other statements. It is written as:
```branescript
{
    <statements>
}
```
For example:
```branescript
print("Hello there!");

{
    print("General Kenobi! You are a bold one!");
}
```

Although it has no functional value, blocks are used to influence the scoping rules. See the relevant [chapter](./scoping.md) for more information.


## Next
In the [next chapter](./expressions.md), we will go through the possible expressions that BraneScript supports. For other parts of the language, refer to the sidebar to select your cup of tea.

Alternatively, you can also start using BraneScript "in the field", by following the chapters for [Scientists](../scientists/introduction.md).

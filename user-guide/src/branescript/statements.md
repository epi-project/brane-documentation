# Statements
Like most languages, BraneScript defines _statements_, which it executes in the order it encounters them.

Every statement in BraneScript must be terminated with a semicolon `;`. While this may be tedious at times, it does mean that BraneScript is line-agnostic, i.e., you can execute multiple statements on the same line.

The specific statements that BraneScript supports are covered in the following sub-sections.


## Variable assignments
BraneScript wouldn't be a scripting language if it did not support variables. However, unlike more dynamic languages like [Lua](https://lua.org), it knows a distinction between _defining_ variables and _updating_ them. Moreover, it has no concept of a `null` value that may be assigned to every type.

Thus, BraneScript has two different variable assignments. The first, the `let`-assignment, defines a variable and immediately assigns a value to it (because it cannot be `null`). It has the following syntax:
```branescript
let <variable_name> := <expr>;
```

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> When choosing your variable name, take care that it does not start with a keyword, such as `on`, `parallel`, `for`, ...

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


## If-statements
If-statements in BraneScript work like in most other languages. They define a choice for the interpreter to make based on some boolean expression. If this is true, the first codeblock is executed, and if it false, the second codeblock (or _else-clause_) is ran.

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

Note, though, that unlike other languages, BraneScript has no syntactic sugar for an `else if` clause. Instead, you just have to next the if-statements in the else-clause:
```branescript
if (<test>) {
    <some code>
} else {
    if (<alternative test>) {
        <other code>
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
To loop indefinitely, one might use a `true` boolean expression. However, be aware that BraneScript does not have a `break` statement, so you can only do this without blocking forever if you run the loop in a function use `return` instead (see [below](#functions)).


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

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note the lack of `;` at the end of the class definition. Unlike most statements, Brane will crash if you add it here.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Unlike package functions, BraneScript functions do not (yet) define specific input or output types. Instead, these are deduced at runtime based on the actual types accepted in and returned by your function.

To return values from a function, we can use a `return`-statement like in other languages. For example, we can define a simple addition function:
```branescript
func add(lhs, rhs) {
    return lhs + rhs;
}
```

See the relevant [expression definition](./expressions.md#function-calls) to find out how to call the functions.


## Classes
Variables and functions may be bundled together in a Class, which is an arbitrary collection of already existing types collect in a single object.

We can distinguish three "stages" of a class: first, we define it, which is like describing a blueprint for each class. Then, we _instantiate_ it, which means that we build a specific object from the class with some set values. Finally, we can use the instance to carry around values or call functions.

The general syntax for defining classes looks as follows:
```branescript
class <name> {
    <property>
    <function>
    <property>
    ...
}
```
Properties and functions may be alternated arbitrarily.

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note the lack of `;` at the end of the class definition. Unlike most statements, Brane will crash if you add it here.

Defining a property, which is simply defining a variable to be part of this class, looks as follows:
```branescript
<name>: <type>;
```

Defining a function is similar to defining normal functions, except that they are now defined within the body of the class. However, note that every class function gets the instantiated version as the first parameter, conventionally called `self`:
```branescript
func <name>(self, <args>) {
    <statements>
}
```

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note the lack of `;` at the end of the class definition. Unlike most statements, Brane will crash if you add it here.

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> For now, class functions do not support any variables other than `self`. This will be updated in the future.

For example, we may define a Jedi class, which describes all the information needed to define a single Jedi. Additionally, it also contains a `swoosh` method, which will let the Jedi "swing their sword":
```branescript
class Jedi {
    name: string;
    is_master: bool;
    lightsaber_colour: string;

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


## On
Another special statement for BraneScript is the `on`-statement, which forces any package calls to run on a specific site.

The syntax is:
```branescript
on <string expression> {
    <statements>
}
```
The list of location names can be requested with the Brane administrators.

For example, if we want to run it on the location called `location1`:
```branescript
on "location1" {
    print("Hello, world!");
}

// It's an expression, so we can also store in variables etc
let loc := "location1";
on loc {
    print("Hello, world!");
}
```


## Parallel
The final Brane-specific construct if the `parallel`-statement. This statement defines an arbitrary number of blocks. Each block will be attempted to run in parallel on the remote sites. Or more accurately, each block is run in a separate thread in the VM, meaning that the external function calls in each block will be handled in parallel as well (although the function calls within a block are still sequential).

One big downside of this approach is that this induces race-conditions when writing to any global variables defined outside of the parallel blocks. Thus, to fix that, Brane simply does not allow this. Any nested parallel block can be thought of as a new 'main space'.

The best way to get results out of a parallel statement, then, is to write the data to the [shared filesystem](../software-engineers/filesystem.md) and use it in calls after the parallel statements have returned.

The syntax for such a statement is:
```branescript
parallel [{
    <statements>
}, {
    <statements>
}, ...]
```
The part after `parallel` is thus an Array of codeblocks.

For example:
```branescript
parallel [{
    print("Hello from block1");
}, {
    print("Hello from block2");
}]
```
If it's alright, you should see the order in which the statements arrive differ pre-run, as the threads are scheduled arbitrarily on your machine.


## Comments
Although not really a statement, BraneScript also has a concept of single-line comments. These are defined by a double forward slash (`//`) that cause the interpreted to ignore the rest of the current line.

For example:
```
// Even though all of this is illegal BraneScript, this is valid BraneScript!
```


## Next
In the [next chapter](./expressions.md), we will go through the possible expressions that BraneScript supports. We can then talk about [data types](./types.md) in the chapter after that.

Alternatively, you can also start using BraneScript in the field, by following the chapters for [Scientists](../scientists/introduction.md).

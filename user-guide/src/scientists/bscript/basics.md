# Basic concepts
In the [previous chapter](./workflow.md), we discussed your first "Hello, world!"-workflow. In this chapter, we will extend upon this, and go over the basic language features of BraneScript. We will talk about things like variables, if-statements and loops, parallel statements and on-structs.

More complex features, such as arrays, function definitions, classes or Data and IntermediateResults, are left to the next few chapters.


## Variables
First things first: how do variables work in BraneScript?

They work like in most languages, where you can think of a variable as a single memory location where we can store some information. Similarly to most languages, it can be used to store a single _object_ only; e.g., we can only store a single number, string or other value in a single variable[^arrays].

Variables are also _typed_, i.e., a single variable can only store values of the same type. While in some low-level languages, such as C or Rust, this is necessary to be able to compute the size of the variable, BraneScript only implements this for the purpose of being able to do _static analysis_: it can tell you beforehand whether the correct types are passed to the correct variables, which will help to eliminate mistakes made before you run a potentially lengthy workflow.

Finally, unlike other languages such as Python, BraneScript has an explicit notion of _declaration_: there is a difference between _creating_ a new variable and _updating_ it. This is also done to make static analysis easier, since the compiler can explicitly know which variables exist and how to analyse them.

So, how can we use this? The first step is to declare a new variable, to make BraneScript aware that it exists. The general syntax for this is:
```branescript
let <ID> := <EXPR>;
```
where `<ID>` is some identifier that you want to use for your variable (existing only of alphanumeric characters and an underscore, `_`), and `<EXPR>` is some code that _evaluates_ to a certain value. We've already seen an example of this: a function call is an expression, since it has a return value that we can pass to other functions or statements. Other expressions include _literal values_ (e.g., `true`, `42`, `3.14` or `"Hello, there!"`) or logical or mathmatical operations (e.g., addition, subtraction, logical conjunction, comparison, etc). For some more examples, see [below](#arrays), or check the [BraneScript documentation](../../branescript/expressions.md) for a full overview.

Yet another example of an expression is a _variable reference_, which effectively reads a particular variable. To use it, simply specify the identifier of the variable you declared (`ID`) any time you can use an expression. For example:
```branescript
// Declare one variable with a value
let foo := 21 + 21;

// We can use it here to assign the same value to `bar`!
let bar := foo;
```

Finally, you can also update the value of a variable using similar syntax to a declaration:
```branescript
<ID> := <EXPR>;
```
(note the omission of the `let`).

This is known as an _assignment_, and can only be done on variables already declared. For example:
```branescript
// This will print '42'...
let foo := 42;
println(foo);

// ...and this will print '84'
foo := 84;
println(foo);
```

Technically, variables won't be updated until the expression is _evaluated_ (i.e., computed). This guaranteed ordering means that the following also works:
```branescript
// This works because foo is first read to compute `foo * 2`, and only then updated
let foo := 42;
foo := foo * 2;
// Foo is now 84
```

[^arrays]: You may already have guessed that Arrays or Classes may contain multiple variables themselves. However, arrays or classes are objects too; and while they can contain any number of nested values, we still consider them a single object themselves.


## Control flow
Another very important and common feature of a programming language is that it typically has syntax for defining the _control flow_ of a language. In BraneScript, this is even more important, since effectively that is what a workflow is: defining some control flow for a set of function calls.

To that end, BraneScript supports different kind of statements that can allow your workflow to branch or loop, or define things such as where functions are executed.

In the following subsections, we will go through each of the control-flow statements currently supported.


### If-statements
Arguably one of the most important statements, an if-statement allows your code to take _one_ of two branches based on some condition. Most languages feature an if-statement, and most feature them in comparable syntax.

For BraneScript, this syntax is:
```branescript
if (<EXPR>) {
    <STATEMENTS>
}
```
This means that, if the `<EXPR>` evaluates to a `true`-boolean value, the code inside the block (i.e., the curly brackets `{}`) is executed; but if it evaluates to `false`, then it isn't.

An example of an if-statement is:
```branescript
// Let's assume this has an arbitrary value
let some_value := 42;

if (some_value == 42) {
    println("some_value was 42!");
}
```
Because the expression `value == 42` is computed at runtime, this allows the program to become flexible and respond differently to different values stored in variables.

The if-statement also comes in another form:
```branescript
if (<EXPR>) {
    <STATEMENTS>
} else {
    <OTHER-STATEMENTS>
}
```
This is known as an _if-else_-statement, and essentially has the same definition _except_ that, if the condition now evaluates to `false`, the second block of statements is run instead of nothing. To illustrate: these two blocks of code are equivalent:
```branescript
let some_value := 42;
if (some_value == 42) {
    println("some_value was 42!");
} else {
    println("some_value was not 42 :(");
}
```

```branescript
let some_value := 42;
if (some_value == 42) {
    println("some_value was 42!");
}
if (some_value != 42) {
    println("some_value was not 42 :(");
}
```

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> From other languages, you may be familiar with a sequence of _else-if_'s. For example, C allows you to do:
> ```c
> int some_value = 42;
> if (some_value == 42) {
>     printf("some_value was 42!");
> } else if (some_value == 43) {
>     printf("some_value was 43!");
> } else if (some_value == 44) {
>     printf("some_value was 44!");
> } else {
>     printf("some_value had some other value :(");
> }
> ```
> BraneScript, however, has no such syntax (yet). Instead, you should write the following to emulate the same behaviour:
> ```branescript
> let some_value := 42;
> if (some_value == 42) {
>     println("some_value was 42!");
> } else {
>     if (some_value == 43) {
>         println("some_value was 43!");
>     } else {
>         if (some_value == 44) {
>             println("some_value was 44!");
>         } else {
>             println("some_value had some other value :(");
>         }
>     }
> }
> ```
> Tedious, but produces equivalent results.


### For-loop
Another type of control-flow statement is a so-called _for-loop_. These repeat a piece of code multiple times, based on some specific kind of condition being true.

Let's start with the syntax:
```branescript
for (<STATEMENT>; <EXPR>; <STATEMENT>) {
    <STATEMENTS>
}
```

BraneScript for-loops are very similar to C for-loops, in that they have three parts (respectively):
- An _initializer_, which is a statement that is run once before any iteration;
- A _condition_, which is ran at the start of every iteration. The iteration continues if it evaluates to `true`, or else the loop quits;
- and an _increment_, which is a statement that is run at the end of every loop.

Typically, you use the initializer to initialize some variable, the condition to check if the variable has exceeded some bounds and the increment to increment the variable at the end of every iteration. For example:
```branescript
for (let i := 0; i < 10; i := i + 1) {
    println("Hello there!");
}
```
This will print the phrase `Hello there!` exactly 10 times.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that the syntax for for-loops might become a lot more restrictive in the future. This is because they are quite similar to while-loops the way they are now (see [below](#while-loop)), but without the advantage that the compiler can easily deduce the number of iterations that a loop does if it is statically available.


### While-loop
While loops are generalizations of for-loops, which repeat a piece of code multiple times as long as _some_ condition holds true. Essentially, they only define the _condition_-part of a for-loop; the initializer and increment are left open to be implemented as normal statements.

The syntax for a while-loop is as follows:
```branescript
while (<EXPR>) {
    <STATEMENTS>
}
```
The statements in the body of the while-loop are thus executed as long as the expression evaluates to `true`. Just as with the for-loop, this check happens at the _start_ of every iteration.

For example, we can emulate the same for-loop as above by writing the following:
```branescript
let i := 0;
while (i < 10) {
    println("Hello there!");
    i := i + 1;
}
```

More interestingly, we often represent a while-loop to do work that requires an unknown amount of iterations. A classic example would be to iterate while an error is larger than some factor:
```branescript
let err := 100.0;
while (err > 1.0) {
    train_some_network();
    err := compute_error();
}
```
(A real example would probably require arguments in the functions, but they are left out here for simplicity).

Finally, another common pattern, which is an infinite loop, can also most easily be written with while-loops:
```branescript
print("The");
while (true) {
    print(" end is never the");
}
```

Note, however, that BraneScript currently has no support for a `break`-statement (like you may find in other languages). Instead, use a simple boolean variable to iterate until you like to stop, or use a `return`-statement (see [below](#returning)).


### Parallel statements
A feature that is a bit more unique to BraneScript is a parallel-statement. Like if-statements, they have multiple branches, but instead of taking only one of them, _all_ of them are taken - in parallel.

The syntax for a parallel statement is:
```branescript
parallel [{
    <STATEMENTS>
}, {
    <MORE-STATEMENTS>
}, ...]
```
(Think of it as a list (`[]`) of one or more code blocks (`{}`))

Unlike the if-statement, a parallel-statement can have any number of branches. For example:
```branescript
parallel [{
    println("This is printed...");
}, {
    println("...while this is printed...");
}, {
    println("...at the same time this is printed!");
}]
```

There is more to say about parallel branches, but we keep this for the [chapter on advanced workflows](./advanced-workflows.md) since it mixes with other BraneScript features. For now, assume that the branches run in parallel are run in arbitrary order, and (conceptually) at the same time. Once every branch has completed, the workflow continues (i.e., the "end" of the parallel statement acts as a joining point).


## Annotations
Although it looks like a control-flow construct, it actually isn't. 


## Next
This chapter is quite a beefy one, but reading through it should have // TODO

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


## Arrays
Another more complex form of an expression is an _array_. This is simply a(n ordered) collections of values, indexable by an integral number. They are very similar to arrays used in other languages.

To create an array, use the following syntax:
```branescript
[ <VALUE>, <ANOTHER-VALUE>, ... ]
```
Note that arrays are _homogeneous_ in the sense that all elements _must_ have the same type. For example, this will throw errors:
```branescript
let uh_oh := [ 42, "fourty two", 42.0 ];
```
Instead, assign it with values of the same type:
```branescript
let ok := [ 83, 112, 97, 109 ];
```

To index an array, use the following syntax:
```branescript
<ARRAY-EXPR> [ <INDEX-EXPR> ]
```
This may be a bit confusing, but the first expression is an expression that evaluates to an array to index (i.e., a literal array, a variable or a function call), and the second expression is an expression that evaluates to a number that is used as index. Some examples:
```branescript
let array1 := [ 1, 2, 3 ];
// Arrays are zero-indexed, so this refers to the first element
println(array1[0]);

let index1 := 2;
// And this to the last element
println(array1[index1])

// Some other examples using weirder expressions
println([ 4, 5, 6 ][1]);
println(generate_array_with_zeroes()[0]);
println(array1[zero()]);
```
This will print `1`, `3`, `5`, `0` and `1`, respectively.

Array indexing can be used to assign a value as well as read it:
```branescript
let array1 := [ "a", "b", "c" ];
array1[0] := "z";
println(array1);
// Will print '[ z, b, c ]'
```

Finally, when you have an array that you got from some function or other source that you don't know the size of, you can retrieve it using the builtin `len`-function:
```branescript
println(len([ 0, 0, 0 ]));
// Will print 3
```

This is very useful when iterating over an array with a for-loop (see [below](#for-loop)).


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


### Returning
A different kind of control flow statement is the return-statement. This is used to essentially halt the current control flow, and go to whatever was the calling context. In other languages, this is often used in [functions](TODO), but in BraneScript its used a bit more general.

The syntax is:
```branescript
return;
```
Writing this statement can be thought as a 'stop' or 'exit' command, and any statement following it (if not in a [branch](#if-statements)) can be ignored.

There are two possible ways to use a return statement:
- When used in a function, the function is exited immediately and the program resumes execution from the function call onwards (see the [next chapter](TODO)).
- When used in another context, the function exits the workflow entirely. This can be used to early-quit the workflow if desired.

For example, this workflow:
```branescript
println("Hello, ");
return;
println("world!");
```
will only print `Hello, `, not `world!`, because of the early quit in between the statements.

A really useful alternative syntax of the return-statement allows it to carry a value to the calling scope:
```branescript
return <EXPR>;
```
This is used to return a value from a function, or to return a value from a workflow.

For example, one can run this workflow in the Brane CLI:
```branescript
return "A special value";
```

<img src="../../assets/img/control-flow-return.png" alt="A workflow returning the string 'A special value'" width="600"/>

While this doesn't seem a lot different than just printing, this actually matters in a few use-cases such as [automatically downloading datasets](TODO) or [creating a workflow package](TODO).


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

// TODO: Move some of the below to `advanced workflows` since, well, it's pretty advanced. Same for arrays (up top) and returning (above this one).

Note that there are a few peculiarities about parallel statements:
- The code inside the blocks is run in parallel, which means that the statement itself will only return once all of the branches do. To illustrate:
  ```branescript
  parallel [{
      println("The order of this print...");
  }, {
      println("...and this print may vary");
  }];
  println("But this print is only run after the other two finished");
  ```
- Instead of being able to refer to variables like normal, every branch receives its own _copy_ of those variables. In practise, this means that any changes they make to variables are only local to that branch. For example:
  ```branescript
  let value := 42;
  parallel [{
      println(value);   // Will print 42
  }, {
      value := 84;
      println(value);   // Will print 84
  }];
  println(value);   // Will still print 42!
  ```
- The order of execution of the branches is arbitrary (as hinted to above), as it depends on the scheduling of the runtime itself and of the OS' scheduling of the VM threads.
- In addition, although they are _said_ to run in parallel, in practise, the only guarantee is that each branch is run _concurrently_ (but still _may_ be run in parallel, depending on the setup). To understand the precise difference, check <https://freecontent.manning.com/concurrency-vs-parallelism/>.
- Each parallel branch forms their own "workflow": or, to be more precise, when your return in a parallel branch, it actually returns the branch - not the workflow. For example:
  ```branescript
  parallel [{
      println("1");
      return;
      println("2");
  }];
  println("3");
  ```
  will actually print `1` and `3`, in that order.
- The only way to return from a parallel branch is to use the _declaration syntax_ of the parallel statement. It looks like the parallel statement is assigned to a variable declaration:
  ```branescript
  let <ID> := parallel[{ <STATEMENTS> }, { <MORE-STATEMENTS> }, ...];
  ```
  If this syntax is used, then every branch _must_ return a value of the same type (using a return-statement). For example:
  ```branescript
  let jedis := parallel [{
      return "Obi-Wan Kenobi";
  }, {
      return "Anakin Skywalker";
  }, {
      return "Master Yoda";
  }];
  println(jedis);
  ```
  Will actually print [an array](#arrays) with the returned strings.
  > <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Note that the undefined order of execution, the order of the array is also undefined; it is first-come first-serve, so it typically only makes sense to process these array using some loop (e.g., a [for-loop](#for-loop)).
- Finally, as a variation on returning an array, multiple _merge strategies_ exist to do different things with the result. For example, one such strategy is the `sum`-strategy, that simply adds the results returned by the parallel-statement. The syntax to define it is:
  ```branescript
  parallel [ <STRATEGY> ] [{
      <STATEMENTS>
  }, ...]
  ```
  To merge using `sum`:
  ```branescript
  let res := parallel [all] [{
      return 42;
  }, {
      return 42;
  }];
  println(res);
  ```
  which will print `84`.
  > <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> For a complete overview of all merge strategies, check the [BraneScript documentation](../../branescript/statements.md).

// TODO: On-structs?


## Next
This chapter is quite a beefy one, but reading through it should have // TODO

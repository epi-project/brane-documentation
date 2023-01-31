# Basic concepts
In the [previous chapter](./workflow.md), we discussed your first "Hello, world!"-workflow. In this chapter, we will extend upon this, and go over the basic language features of BraneScript. We will talk about things like variables, if-statements and loops, parallel statements and on-structs.

More complex features, like Data and IntermediateResults, are left to the [next chapter](./workflows-data.md) to not have this chapter blow up in size.


## Variables
First things first: how do variables work in BraneScript?

They work like in most languages, where you can think of a variable as a single memory location where we can store some information. Similarly to most languages, it can be used to store a single _object_ only; e.g., we can only store a single number, string or other value in a single variable[^arrays].

Variables are also _typed_, i.e., a single variable can only store values of the same type. While in some low-level languages, such as C or Rust, this is necessary to be able to compute the size of the variable, BraneScript only implements this for the purpose of being able to do _static analysis_: it can tell you beforehand whether the correct types are passed to the correct variables, which will help to eliminate mistakes made before you run a potentially lengthy workflow.

Finally, unlike other languages such as Python, BraneScript has an explicit notion of _declaration_: there is a difference between _creating_ a new variable and _updating_ it. This is also done to make static analysis easier, since the compiler can explicitly know which variables exist and how to analyse them.

So, how can we use this? The first step is to declare a new variable, to make BraneScript aware that it exists. The general syntax for this is:
```branescript
let <ID> := <EXPR>;
```
where `<ID>` is some identifier that you want to use for your variable (existing only of alphanumeric characters and an underscore, `_`), and `<EXPR>` is some code that _evaluates_ to a certain value. We've already seen an example of this: a function call is an expression, since it has a return value that we can pass to other functions or statements. Other expressions include _literal values_ (e.g., `true`, `42`, `3.14` or `"Hello, there!"`) or logical or mathmatical operations (e.g., addition, subtraction, logical conjunction, comparison, etc).

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


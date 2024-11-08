# Scoping rules
In this chapter, we will detail BraneScript's scoping rules and how variables are bound to their declaration. This matches the procedure followed in the [`resolve`](/docs/brane_ast/traversals/resolve/index.html) compiler traversal.

It is recommended to read the [Features](./features.md)-chapter first to have an overview of the language as a whole before diving into the specifics.


## Variables VS functions
TODO


## Scoping - why we care
At the start of every workflow compilation, there is a compiler traversal (the [`resolve`](/docs/brane_ast/traversals/resolve/index.html)-traversal) that attempts to link variables references (e.g., `foo`) to variable declarations (e.g., `let foo := ...`). You can think of this step as relating identifiers with each other, creating _symbol tables_ to keep track of which variables are introduced and where they are set and read.

For example:
```bscript
// This tells the compiler we define a new variable
let foo := 42;

// Knowing that, it can relate this `foo` to that `foo`
println(foo);

// Uh-oh! We are using some `bar` we've never seen before, and therefore cannot relate!
println(bar);
```
As this process is done using name-matching, one may note that this strategy normally means we would muddy our namespace quite quickly. For example, what if we want to introduce a temporary variable; if there was only one scope, it would be around forever; e.g.,
```bscript
// We only need this here
let foo := 42;
println(foo);

...

// Much later, we want to name something foo again - but confusion strikes, as it's
// not obvious if we mean this foo or the previous one!
let foo := 84;
```

As a solution to this problem, we create _scopes_ to help the compiler identify which variable is meant when they share the same name.


## The magic brackets
As a rule of thumb, a new scope is introduced for every opening curly bracket `{`, and closed on every closing curly bracket `}`. For example:
```bscript
// The global scope


{
    // A nested scope!
}


if (true) {
    // A scope for the true-branch, nested in `global`
} else {
    // A scope for the false-branch, nested in `global` too
}


func foo() {
    // A scope for only this function!
    {
        // This scope is nested in `global` and then `foo`
    }
}
```

A variable declared in a particular scope (e.g., `let foo := ...`) is known _only_ in that scope, _and_ all its nested scopes. For example:
```bscript
// Known everywhere, as it is defined in the "root" scope
let foo := 42;
{
    println(foo);   // works
    if (true) {
        println(foo);   // works
    }
}
println(foo);   // works
```
```bscript
{
    // Only known in this scope and below
    let foo := 42;
    println(foo);   // works
    if (true) {
        println(foo);   // works
    }
}
println(foo);   // does not work!
```


## Shadowing variables
One particular usage of a scope is to _shadow_ variables; i.e., we can "override" an identifier to be used for a variable in a lower scope, while the same variable is used in a higher scope. For example:
```bscript
let foo := 42;
println(foo);   // 42
{
    // This `foo` shadows the top one; same name, but actually a new variable!
    let foo := 84;
    println(foo);   // 84
}
println(foo);   // 42 again!
```

In fact, BraneScript also allows shadowing in the _same_ scope. This only means that the old variable may never be referenced again:
```bscript
let foo := 42;
println(foo);   // 42

// This declares a _new_ variable
let foo := "Hello, world!";
println(foo);   // Hello, world!

// There is just no way for us now to refer to the first variable
```

This may raise the question as to why BraneScript even has scopes, as the main motivating reason was to help the compiler disambiguate variables with the same name, but it turns out we can do that without even needing them. For that, see the [future work](./future.md#destructors)-chapter.


## Assignment scoping
There is a second scoping rule that is used to resolve variables. Suppose that we want to store an _old_ foo into a _new_ foo:
```bscript
let foo := 42;
// May seem redundant, but we would expect it to work!
let foo := foo + 1;
```
However, now the compiler may be led into ambiguity, as the two `foo`s appear in the same statement. So which foo refers to which?

To resolve, the assignment operator `:=` also introduces a kind of change in scope. In particular, anything to the right of the scope is **evaluated first using the old scope**. Then, the `foo` on the left is created, virtually creating a new scope that holds from that point onwards.


## Function body scoping
Functions have a few particular rules about them when discussing scoping.

First, the scope of a function body is _not_ nested in the parent scope. For example:
```bscript
// Refresher; this works usually
let foo := 42;
println(foo);

// But this doesn't, as the function has no access to the parent scope
func bar() {
    println(foo);   // 'Undeclared variable' error
}
```
This is a design decision made for BraneScript, which simplifies the resolve process when submitting a workflow as successive snippets (see the [background](./introduction.md#background)).

Instead, values can be passed to functions through parameters:
```bscript
let foo := 42;

func bar(foo) {
    println(foo);
}

// Call, then:
bar(foo);
```
Where parameters are always declared in the scope of the function.


## Class scoping
TODO

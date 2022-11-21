# Scoping rules
In BraneScript, there are variables, and the variables are referenced by a (string) identifier. To make this concrete, consider the following example:
```branescript
let a := 0;
a := 1;
b := 2;
```
Because the compiler uses the identifiers (`a` and `b`, in this case) to know which variables has been defined or not and which one is updated, it can rightly throw an error that `b` is not defined.

However, in many cases, it would be very cluttering if a variabel is defined forever. Consider having two consecutive for-loops:
```branescript
for (let i := 0; i < 10; i := i + 1) {
    // We can use i happily here
}

// If we cannot re-use i here, we would soon run out of commonly used iteration variables
for (let j := 0; j < 10; j := j + 1) {
}
```
To address this issue, BraneScript makes heavy use of [scoping](https://en.wikipedia.org/wiki/Scope_(computer_science)). How this works exactly in BraneScript is what we explain in this chapter.


## Blocks
In BraneScript, any variable or definition (so also function and class definitions!) is valid only for the _block_ in which it lives (i.e., a block is any series of staments wrapped in `{` and `}`). Whether this is a function block, an if-statement block or a loose block, this does not matter; any area where there are curly brackets defines its own _scope_ - i.e., an area in which all of its variable references are valid.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> For the purpose of scoping, you can consider the script itself (i.e., any statement not within a block) to be a block as well; this outermost scope is often referred to as the _global scope_.

This allows us to do the following:
```branescript
{
    // Works
    let i := 1;
}

{
    // Also works, even though they have a different name!
    let i := 2;
}

// This does not work, since there is no 'i' defined in the global scope
i := 3;
```

As a rule of thumb, any declaration made 'near' a block is made 'within' that block. Concretely, for for-loop and function-definitions, this means the the arguments and iterator variabels are defined within that for-loop's or function's scope:
```branescript
for (let i := 0; i < 10; i := i + 1) {
    // We can use i happily here
}
// And here!
let i := 0;

// And the same for arg
func fn(arg) {
    // ...
}
let arg := 0;
```

The final rule to know about blocks is that any _nested_ block (i.e., block defined within a block) _also_ has access to its parent's definitions (and its parent, and its parent, ...). This way, we can still access things in the global scope but not in the inner:
```branescript
{
    let hello := "Hello!";
    for (let i := 0; i < 10; i++) {
        // We can use 'hello' here, because it's nested...
        print(hello);
    }
}

// But not here
print(hello); // crash
```

When we talk about a 'block' being a 'scope', what we really mean is: 'all variables within this block have the same scope' // TODO


## Shadowing
On initially confusing technique that BraneScript supports is called _shadowing_.

As shown in the previous section, the block scoping rules define that it's allowed to define two variables with the same name if they are not within each other's scope:
```branescript
{
    // Allowed
    let i := 0;
}

{
    // Allowed
    let i := 1;
}
```

When we try to define two variables within the same block


## Let-scope


# Structure
BraneScript is a scripting-like language, and as such has many of the same concepts and structure of languages like [Lua](https://lua.org) or [Python](https://www.python.org).

In this chapter, we will briefly describe the overall idea behind BraneScript before we go into the formal definitions given in the [Abstract syntax](./syntax.md) and [Semantics](./semantics.md) chapters.

```bscript
/* Some example BraneScript! */

// Printing something
println("Hello, world!");

// Doing arithmetic
let value := 21 * 2;
println(value);

// Functions!
func add(left, right) {
    return left + right;
}
println(add(21, 21));

// Control flow!
for (let i := 0; i < 10; i := i + 1) {
    if (i == 0) {
        print("We have i = "); print(i); println("...");
    } else {
        if (i < 9) {
            print(i); println("...");
        } else {
            println("And "); print(i); println("!");
        }
    }
}
```
_**Listing 1**: Some example BraneScript code highlighting a few language features._


## In a nutshell
Like most imperative languages, BraneScript's toplevel grammar exists of _statements_ which each are a full, valid snippet of BraneScript. For example, a statement may be a function call, if-statement or variable declaration. The sequence of statements matters, as that is the sequence in which they are executed.

Then, real work happens in _expressions_. These represent some computation, either arithmetically or logically, and describe how values are mutated and transferred. Even though expressions are not BraneScript's focus, they are complex enough to capture more control-flow use-cases such as counting, boolean or integer comparisons, function calls, andsoforth.

Aside from statements and expressions, BraneScript has a notion of _variables_ (i.e., named spaces in memory that can be assigned a value which is then later read from) and _functions_ (i.e., named series of statements that can be executed intermittently in another series of statements).

More unique to BraneScript, it features _external functions calls_ as function calls. Specifically, some functions are not defined internally or as BraneScript, but rather as a _packages_ of tasks. At runtime, these tasks are then executed on the connected compute sites as clusters. When seeing workflows as graphs, these external function calls represent nodes.

Further, there are two specific control flow statements: the on-struct, which limits where a particular task can be executed; and a parallel-struct, which indicates that there is no sequential dependencies between two series of statements.


## Next
Now that you have a very course understanding of the language as a whole, you can examine its syntax in the [Abstract syntax](./syntax.md) chapter. This defines what can be expressed and how. If you're rather interested in the [semantics](./semantics.md), you can also skip ahead to that chapter.

Alternatively, you can also see the future of BraneScript in the [Future work](./future.md) chapter.

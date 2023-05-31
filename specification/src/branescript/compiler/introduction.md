# BraneScript Compiler
These chapters describe the inner workings of the BraneScript compiler.

Note that these chapters are about the new syntax compiler. The biggest difference between this and the old syntax compiler -in addition to language improvements- is the explicit detachment between compilation and linking. This allows us to reason about the delay in information in a REPL setting more clearly and formally.

In particular, the compiler has a notion of _resolved entries_, which are symbol table entries that are known at compile time, and _phantom entries_, which are essentially external references. Because BraneScript is a scripting language, it does not require any header information about phantom entries; instead, it deduces what it can based on the phantom entry's usage, and then attempts to merge that with the entry's actual type at link time.

This means that the compiler actually provides a best-effort static analysis. The resulting binary is actually still unresolved, both on the planning and the actual type information, which can be resolved with information from the to-be-linked modules or -especially relevant for the REPL- previous snippets.


## Traversals
The BraneScript compiler has various traversals. A brief description of each of them:
1. [Annotation parsing](./traversals/annotations.md) is the first traversal, which converts the raw tokens passed in an annotation (`#[ ... ]`) into a semantically correct annotation. In addition, the actual annotation tokens are removed from the AST, and instead added as metadata to the nodes they are annotating.
2. [Symbol resolution](./traversals/resolving.md) is the traversal that builds symbol tables. This heavily leans into the concept of resolved and phantom entries, where we mark symbols for which we find a definition as resolved, and symbols for which we only find references as phantom. Consequently, though perhaps surprisingly, does this traversal throw almost no errors, except for a few semantic ones relating to methods (which must always contain 'self') or the validity of function- and variable identifiers in calls and assignments, respectively.
3. [Type analysis](./traversals/typing.md) is the traversal that resolves type information. This is once again a best-effort implementation, but it _can_ find conflicts already if the user sufficiently annotated the script with type information. Most importantly, though, this traversal will propagate type information as much as possible by deducing the types of variables and functions as much as it can. In addition, it also policies some type correctness it can already deduce, such as whether blocks return expressions when expected and so forth. Note that this traversal is actually repeatedly executed, until no further type deductions can be made.

They have their own chapters going into detail. Simply click on the name of the compiler, or select the chapter in the sidebar to the left.

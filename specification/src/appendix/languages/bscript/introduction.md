# Appendix A: BraneScript specification
Brane is designed to be loosely-coupled between how scientists interact with it and how the framework receives its input (see [Design requirements](../../../requirements/introduction.md)). As such, the framework specification itself only specifies the [Workflow Internal Representation](../../../spec/wir/introduction.md) (WIR), which unifies all frontends into one language.

That said, the framework does feature its own workflow language, BraneScript. These chapters are dedicated to documenting the language. To learn how to use the language, refer to [The User Guide](/user-guide/branescript/introduction.html) instead.


## Background
BraneScript is originally designed as a counterpart to _Bakery_, a workflow language that featured natural-language-like syntax for better compatability with domain scientists who do not have any programming experience. BraneScript was designed as a more developer-friendly counterpart, and eventually became the predominantly used language for the framework.

BraneScript is a compiled language, meaning that the frontend of the framework reads the submitted files and translates them to another representation before execution (specifically, Brane's [WIR](../../../spec/wir/introduction.md)). Because it is compiled, this gives the opportunity for the compiler to perform checks and analysis before accepting the program or not, allow it to catch programmer mistakes early.

A downside of compilation is that it plays less nice with Brane's Read-Eval-Print Loop (REPL). The REPL is a feature of the `brane`-executable that allows a workflow to be defined step-by-step, interleaving execution and definition. For example, it means that submitting an entire program
```bscript
import hello_world();
let test1 := hello_world();
println(hello_world());
```
as one file must give the same result as submitting
```bscript
import hello_world();
```
```bscript
let test1 := hello_world();
```
```bscript
println(hello_world());
```
as three separate snippets within the same REPL-session.

To support this, the BraneScript compiler has a notion of _[compile state](/docs/brane_ast/state/struct.CompileState.html)_ that is kept in between compilation runs. This complicates the compilation process, as can be seen through the chapters in this series.


## Layout
The chapters are structured as follows. First, in the [Features](./features.md)-chapter, we discuss the concepts of the language and which statements exist. Then, we examine particulars of the language: the [grammar](./syntax.md), [scoping rules](./scoping.md), [typing rules](./typing.md), [workflow analysis](./workflow.md) and concrete [compilation steps](./compilation.md).

Finally, in the [Future work](./future.md)-chapter, we elaborate on ideas and improvements not yet implemented.

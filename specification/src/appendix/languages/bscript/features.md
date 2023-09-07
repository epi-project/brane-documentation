# Features
In this chapter, we explain BraneScript from a user experience perspective. We go over the main design choices and language concepts it features to understand what the rest of this appendix is working towards.

If you are already familiar with BraneScript as a user and want to learn how to parse it, refer to the [Formal grammar](./syntax.md) chapter; if you are instead interesting in compiling the resulting AST to the [Workflow Intermediate Representation](TODO) (WIR), refer to the [subsequent chapters](TODO) instead.


## BraneScript: A scripting-like language
Primarily, BraneScript is designed to emulate a scripting-like language for defining workflows. As such, it is not approximating a graph structure, as we typically represent workflows, but instead we define a series of statements and expressions that can arbitrarily call upon external tasks. This means the language is very similar in usage as [Lua](https://lua.org) and [Python](https://wiki.python.org). Listing 1 shows an example BraneScript snippet.

```bscript
// Import a package that defines external tasks
import hello_world;

// Print some text running it on a particular location!
on "site_1" {
    println("A message has come in:");
    println(hello_world());
}



// Print a lot more text running it on another location!
on "site_2" {
    println("Multiple messages coming in!:");
    for (let i := 0; i < 10; i := i + 1) {
        print("Message "); print(i); print(": ");
        println(hello_world());
    }
}
```
_**Listing 1**: Example BraneScript snippet showing how the language looks using a typical "Hello, world!" example._

Then, at compile time, the statements can be analysed to derive the intended workflow graph. Such a graph matching to Listing 1 can be found in Figure 1.

![Workflow graph extracted from Listing 1](../../../assets/diagrams/WorkflowExample2.png)  
_**Figure 1**: Workflow graph that can be extracted from Listing 1. It shows the initial task execution and then the repeated execution of the same function. In practise, this loop might be unrolled for simpler analysis, but this cannot always be done (e.g., conditional loops)._


## Main concepts
BraneScript leans on well-established concepts from other programming languages.

First, a BraneScript program is defined as a series of _statements_. These are the smallest units of coherent programs. Like most scripting languages, they can be given at the toplevel of the program.

Actual work is performed in _expressions_, which can be thought of as imperative formulas creating, transforming and consuming values. Aside from _literal values_ (booleans, integers, real numbers, strings), BraneScript also supports _arrays_ of values (i.e., dynamically-sized containers of multiple of the same values) and _classes_ (i.e., statically-sized containers of different values).

Then it also has a concept of _variables_, which can remember values across statements. Essentially, these are named segments of memory that can be assigned values that can later be read.

_Functions_ can be used to make the codebase more efficient, or implement specific programming paradigms such as [recursion](https://en.wikipedia.org/wiki/Recursion). Concretely, they are named series of statements that can be called in the middle of other statements, allowing the re-use of particular snippets of code at certain moments. Like most other languages, functions can take in values as arguments to configure their execution, and output a value to contribute to the site where they were called. Classes can also be associated with functions to describe _class methods_.

Finally, specific to BraneScript, _external functions_ are imported as _packages_ and executed like normal functions. However, instead of execution BraneScript statements, these functions execute a workflow task. Their result is translated back to BraneScript concepts.


## Statements
This section lists the specific statements supported by BraneScript.



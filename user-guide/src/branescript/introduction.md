# Introduction
The whole Brane framework revolves around the workflows, which define how package functions need to be called, in what order and with what data.

Because Brane aims to be easily accessible by multiple roles (the famous separation of concerns), it provides two Domain-Specific Languages (DSLs) that can be used to write workflows: BraneScript and [Bakery](../bakery/introduction.md).

Under the hood, these languages translate to the same code, and thus have the same _semantics_ (i.e., meaning behind the code). Their syntax, however, is different: BraneScript resembles classical scripting languages (such as [Bash](https://www.gnu.org/software/bash/) or [Lua](http://www.lua.org/)), whereas Bakery is designed to be more "natural language-like", to help scientists without much programming experience to understand the code.

In this series of chapters, we will be focussing on BraneScript and its syntax. For Bakery, you should refer to [its own series of chapters](../bakery/introduction.md).


## Concept & Terminology
As stated, BraneScript is designed as a workflow specification. This means that the real work of any BraneScript file is not performed within the domain of BraneScript, but rather in the domain of the package functions that BraneScript calls. It only acts as a way to "glue" all these functions together and show the result(s) to the caller of the workflow.

In these few chapters, we will refer to BraneScript files as both _workflows_ and _scripts_, making the terms interchangeable for the purpose of this documentation. Anything that the _workflows_ call is referred to as _package functions_ or _external functions_, which are implemented by deploying the _package container_ and running the appropriate function therein.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the code snippets in these chapters, we wil use text enclosed in triangular brackets (`<example>`) to define parts of the syntax that are variable. For example, `Hello <world>` means that there must be a token `Hello`, followed by some arbitrary token that we will name `world` for being able to reference it.


## Nexts
In the [next chapter](./statements.md), we will dive in to statements of BraneScript, which will show the basic constructs you may use. Then, in the [chapter after that](./expressions.md), we will examine BraneScript's expressions. Finally, we will consider its [data types](./types.md). The last chapter may be most relevant if you're writing packages.

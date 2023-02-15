# Introduction
The whole Brane framework revolves around the workflows, which define how package functions need to be called, in what order and with what data.

Because Brane aims to be easily accessible by multiple roles (the famous separation of concerns), it provides two Domain-Specific Languages (DSLs) that can be used to write workflows: BraneScript and [Bakery](../bakery/introduction.md).

Under the hood, these languages translate to the same code, and thus have the same _semantics_ (i.e., meaning behind the code). Their syntax, however, is different: BraneScript resembles classical scripting languages (such as [Bash](https://www.gnu.org/software/bash/) or [Lua](http://www.lua.org/)) and is aimed to be convienient in use by software engineers; Bakery, in contrast, is designed to be more "natural language-like", to help scientists without much programming experience to understand the code they are writing or that someone else wrote.

In this series of chapters, we will be focussing on BraneScript and its syntax. For Bakery, you should refer to [its own series of chapters](../bakery/introduction.md).


## Concept & Terminology
As stated, BraneScript is designed as a workflow specification. This means that the real work of any BraneScript file is not performed within the domain of BraneScript, but rather in the domain of the package functions that BraneScript calls. It only acts as a way to "glue" all these functions together and show the result(s) to the caller of the workflow.

In these few chapters, we will refer to BraneScript files as both _workflows_ and _scripts_, making the terms interchangeable for the purpose of this documentation. Anything that the _workflows_ call is referred to as _package functions_ or _external functions_, which are implemented by deploying the _package container_ and running the appropriate function therein.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the code snippets in these chapters, we wil use text enclosed in triangular brackets (`<example>`) to define parts of the syntax that are variable. For example, `Hello <world>` means that there must be a token `Hello`, followed by some arbitrary token that we will name `world` for being able to reference it.


## Structure
This series aims to be a comprehensive introduction to BraneScript's features, much more elaborate than given in the [chapters for Scientists](../scientists/bscript/introduction.md). It will list all of BraneScript's language features in a tutorial-like fashion, assuming minimal programming experience in languages such as Python, Lua, C or Java.

In the [first chapter](./hello-world.md), we will write a simple "Hello, world!" workflow to get your feet wet in the dirt, and to practise submitting workflows. Then, [chapter two](./basics.md)


## Nexts
You can start this series by reading the [next chapter](TODO), which will set you on your journey. It is recommended to follow the chapters in-order if it is your first time reading about BraneScript, but you can also jump between them using the sidebar on the left.

Alternatively, if you are looking for more technical details on how the BraneScript language is specified, we recommend you to inspect the [specifications](/specification/branescript/introduction.md) of the language in the [Brane: A Specification](/specification) book.

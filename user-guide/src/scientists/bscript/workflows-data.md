# Workflows and Data
In the [previous chapter](./workflow.md), we've discussed writing the simplest workflow possible in BraneScript. In this chapter, we will build on this, and examine the concepts of _data_ and _intermediate results_.

We will start by introducing the concepts of data and intermediate results as far as Brane is concerned. Then, we will introduce additional BraneScript concepts that we need to work with data, after which we will use them to write a new workflow. Finally, we will make some remarks about datasets and how to manage them as a scientist.


## Background: Data and Intermediate Results
In Brane, there is an explicit distinction between _variables_ and _data_.

Variables are probably familiar to you from other programming languages. There, they can be though of as (simple) values or data structures that live in memory only, and is something that the processor is typically able to directly[^note1] manipulate. This is almost exactly the same in Brane, except that they are emphesised to be _simple_, and mostly used for configuration or control flow decisions only.

Data, on the other hand, represents the complex, large data structures that typically live on disk or on remote servers. In Brane, this is typically the information that a package wants to work on, and is also the information that may be sensitive. It is thus subject to [policies](TODO).

Another useful advantage of being able to separate variables and data this way is that we can now leave the transfer of large datasets up to the framework to handle. This significantly reduces complexity when attempting to use data from different sources.

As a rule of thumb, something is a variable if it can be created, accessed and manipulated in BraneScript (or Bakery). In contrast, data can only be accessed by the code in packages, and only exist in BraneScript itself as a reference. It isn't possible to inspect any of the data in a dataset in BraneScript, unless a package is used.

[^note1]: From a programmer's perspective, anyway.

### Datasets & Intermediate Results
Data itself, however, knows a smaller but important distinction. Brane will call a certain piece of data either _datasets_ or _intermediate results_. Conceptually, they are both data (i.e., referencing some file on a disk or some other source), but the first one _can_ outlive a workflow whereas the other _can't_. This distinction is used for policies, where it's important that intermediate results can only be referenced by users in the framework participating within the same workflow and not by others.

For you, a scientist, the important thing to know is that you will always have to explicitly _commit_ data returned by functions before you can access it. This essentially tells the framework which results are relevant to the outside world, and which aren't - which means policies can be more lenient towards them if they want. It's thus good practice to try and commit as little results as possible.


## Variables and Classes
With the background in mind, it is time to apply this to workflows.

To use datasets, we will introduce two new concepts: _variables_ and _classes_. The former is strictly not necessary to work with data, but very useful and this is a good moment to talk about them.

### Variables
Like most programming languages, BraneScript has a concept of _variables_. These are (typically small) areas in memory that we use to store temporary variables. Whereas they may contain anything in most languages, it is good practice in BraneScript to use them only for configuring functions or managing the control flow of a workflow. Larger pieces should be left to datasets (see below).

To work with variables, there are three pieces of syntax that one needs to know.

The first is [_declaring_ variables](../../branescript/statements.md#variable-declarations). This introduces them to the workflow, allowing you to reference them later. It has the following syntax:
```branescript
let <NAME> := <VALUE>;
```
(Don't forget the semicolon `;` at the end!)

This introduces a new variable by the name `<NAME>`, and assigns the value `<VALUE>` to it to initialize it. For example, to introduce some variable `answer` that is an integer:
```branescript
let answer := 42;
```
There are a few remarks to be made about declarations that you, as a workflow writer, have to know:
- Variables must _always_ have a value when declared (see the [advanced workflows](./advanced-workflows.md#null) chapter).
- BraneScript is [statically typed](https://developer.mozilla.org/en-US/docs/Glossary/Static_typing), and types are deduced based on the value they are assigned when declared (in the example, `42` is an integer, so `answer` will only accept integers).
- BraneScript declarations are _scoped_. This means that they are only available in the block they are declared (see the [advanced workflows](./advanced-workflows.md#scopes) chapter).
  - Additionally, BraneScript also requires that variables do not conflict with variable **declared in the same scope**. However, they are allowed to shadow variables declared in higher scopes.

The compiler will try to aid you with helpful messages if you violate any of these rules, so don't worry if they don't make a lot of sense now.

> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Some of these rules are pretty restrictive, and can lead to unintuiative code. In future releases, it is likely that changes will be implemented that either change or relax some of these rules.

The second syntax you have to know when working with variables is [_reading_ them](../../branescript/expressions.md#identifiers). To read a variable, you can simply use their name as an expression (i.e., a value).

For example, to declare a second variable `wrong_answer` we can read the value of the variable `answer`:
```branescript
let wrong_answer := answer + 1;
```
`wrong_answer` will now have the value `43`.

Finally, the third piece of syntax is the ability to [_update_ variables](../../branescript/statements.md#variable-assignments). This procedure is very similar to declaring variables, except that you don't create a new one, but update the value of an old variable. The syntax for this is also comparable:
```branescript
<NAME> := <VALUE>;
```
(Note the lack of `let`).

For example, we can update our variable `wrong_answer` to some other value:
```branescript
wrong_answer := 42;
```
`wrong_answer` now evaluates to `42` instead of `43`.

### Classes
Classes in general is a programming paradigm where data is associated with a set of functions that "act" on it. This allows for a more intuitive style of programming, where actions and parameters for those actions are kept together. For a more thorough introduction, check [this](https://www.educative.io/blog/object-oriented-programming) blogpost.

BraneScript has a rather simple view of classes, but still there is quite some syntax involved. Luckily, we won't have to deal with them when talking about data; instead, we will only focus on [_class instantiation_](../../branescript/expressions.md#class-instantiation).

For simplicity, we will focus on the builtin `Data`-class, which can be used to refer to data. Because it is builtin, you only ever have to instantiate it, which can be done in the following manner:
```branescript
new Data{ name := <VALUE> };
```
This creates a new Data instance with the name `<VALUE>`. The name is some identifier used by Brane to

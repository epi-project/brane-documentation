# Compiling from BraneScript and Bakery
The main languages that compile to Brane Workflows are, as may be expected, the custom BraneScript and Bakery DSL's.

In this chapter, we will mostly discuss how to compile BraneScript. This is, as noted more often when talking about them, because both BraneScript and Bakery compile to the same _abstract syntax tree_ (AST); in other words, only their most superficial syntax differs, but their important syntax and semantics are equivalent.

Note that we will not dive into the specific syntax here; we will describe how to convert a BraneScript AST (i.e., its semantics) to a Workflow. For syntax, check the [Brane: The User Guide](https://wiki.enablingpersonalizedinterventions.nl/user-guide) book.


## Compilation stages
To compile from one AST to the next, we define a few important compiler stages that are taken to arrive at an optimal Workflow.

First, before we start to convert between representations, extra analysis on BraneScript is required to fully prepare it for a Workflow. In particular:
- _symbol table population_: BraneScript has a notion of scopes and of variables, so declarations and definitions of and references to variables, classes and functions have to be resolved first. This includes resolving external package- and data imports.
- _type analysis_: As much as possible, types of variables should be resolved beforehand. In most cases, this is not strictly necessary but rather serves to help the user catch errors before they occur; but in some cases (like function calls or class instantiations), these are also necessary to make a sensible workflow.
- _location analysis_: Specific to the framework, analysis also needs to happen about user-imposed restrictions to where certain workflows may be executed. In particular, the restrictions imposed by On-structs and location annotations need to be propagated to the function calls themselves.
- _Optimisation_: In order to produce fast and efficient workflow, an (optional) stage is in between that can compute operations at compile-time where possible, remove dead code or unfolds constants. Note that this traversal does not provide any functional benfits; the only benefits are that of program size and execution time.
- _AST pruning_: Before we can compile workflows, some inconsistencies or syntactic sugar (like patterns or for-loops) must be resolved or pruned before we can compile. An example of an inconsistency is making sure all functions have explicit return-statements.
> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the source code, these four stages (or "traversals") are referred to as `resolve`, `typing`, `location`, 'optimise' and `prune`, respectively.

Then, we can initiate the actual compile-stage that converts from one AST to the other. How it does so specifically is discussed in the next section, but it is important that it does not produce an executable workflow immediately; instead, it first produces a so-called _unresolved workflow_, where the links between edges is not yet resolved directly but rather by providing a linked-list-like structure where they are stored in instead. This is done to make inserting or removing edges much easier in subsequent stages.

After we have an unresolved workflow, we can apply the final two stages:
- _Workflow optimisation_: Once compiled, we can (and should) optimize the workflow. This is both to speedup the VM, but also to aid in reasoning about the workflow, since the compile stage produces only atomic edges (see the [previous chapter](./graph-edges.md#edges)). Thus, composite edges won't be generated until this stage.
- _Workflow resolving_: Finally, we converted our unresolved workflow to a resolved workflow by creating an array with edges instead of a linked list with referenced that go by index. The Workflow is now send- and execute-ready.
> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> In the source code, these three stages (or "traversals") are referred to as `compile`, `workflow_optimise` and `workflow_resolve`, respectively.

We will now examine the compiler stage in more detail, since that is where BraneScript/Bakery constructs are translated to Workflow edges. For information on other stages, check the source code.


## From If to Branch
The most interesting part is how BraneScript/Bakery control-flow constructs are translated to Workflow edges.

Because the design of BraneScript and Workflows is intertwined (Workflows are designed to be compiled to from BraneScript), most of the translation is straight-forward.

`// TODO`

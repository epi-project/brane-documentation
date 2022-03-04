# Overview
In this chapter, we will provide an overview of what the framework is build to do and what kind of features it supports. Then, we will also briefly talk about how the rest of this book looks like.

We recommend that everyone who works with this framework reads this chapter first, so that everyone starts on the same page. However, if you're very eager to start, you can skip ahead to the [quick installation](./general/quick-installation.md) or the [quick start](./general/quick-start.md) chapters.


## Framework in a nutshell
The Brane framework is primarily designed to act as an abstraction over multiple nodes spread over multiple sites. It is designed to take a workflow that describes some algorithm or some job to execute, and tries to execute it efficiently over the multiple _compute sites_ it is connected to (see figure 1).

![An image showing the abstraction the Brane framework provides over multiple compute sites](./assets/img/abstraction.svg)
_Figure 1: Schematic showing the abstraction Brane provides over multiple infrastructures / compute sites. The framework orchestrates over multiple sites, where each sites orchestrates over its own nodes. Together, this allows the user to utilize the work of all compute sites together as if they were one._

An important additional feature is that it tries to provide and intuitive interface to the three different roles that are needed when trying to run workflows: **system engineers**, who build and manage the compute sites; **software engineers**, who write the bulk of the algorithms used; and **scientists**, who use the workflows to perform their research.

This separation of concerns means that the framework provides different levels of abstraction to interact with it. For system engineers, it hosts a tool and configuration files to setup the underlying infrastructures; for software engineers, the framework allows them to write code in their preferred languages and package them using provided tools; and for scientists, the framework provides more natural language-like domain-specific languages to write the workflows in that allow them to reason more easily about the work done.

As part of the [EPI project](https://enablingpersonalizedinterventions.nl), the Brane framework will additionaly police data access according to (legal) policies defined by the data owners. Because this project is focused on health data, policies Brane is designed to handle are also those often occurring in the health sector.


## General functionality
The Brane framework is primarily build to execute incoming workflows and return the result of the processing to the user. To do so, it alleviates a **packageing system** that allows software engineers to build the functions that the workflows orchestrate.

We will first discuss a bit more in-depth what the workflows are. Put simply, a workflow is a (typically) small, high-level program that contains the control flow that decides what functions to run and in what order. Each such a function is then an algorithm or a computation that actually performs work on the data. Since these functions are bundled in packages, the idea of Brane is to have a central repository where many commonly-used algorithms are stored, which can then be easily imported in the workflows.

In Brane, each package is implemented as a completely self-contained containerized application. This means that the package code itself can be written in any language, after which it is wrapped by a Brane executable that provides the entrypoint to this container. This executable takes the commands and the arguments from the workflow, and relays them to the code in a standardized manner. This building of packages is usually done by the software engineers.

To write workflows, Brane offers two semantically identical domain-specific languages but with different syntaxes: **BraneScript**, which is more like a traditional scripting language and aimed at software engineers; and **Bakery**, which is closer to natural-language and thus aimed at scientists. The programs written in these DSLs are the workflows that orchestrate the package functions created by the software engineers.

Finally, to work with multiple sites at once, the Brane framework allows **infrastructures** to be registered with certain properties. It is designed to alliviate orchestration software already present on the site itself (e.g., [Slurm](https://github.com/SchedMD/slurm) or [Kubernetes](https://kubernetes.io/)), meaning that system engineers only have to specify which interface to use when connecting to their compute site and what resources are available.


## Book outline
The remainder of this book is structured in four groups of chapters that will be aimed to different audiences.

The [first group of chapters](./management/introduction.md) is aimed for the people who manage the framework and are in charge of the control nodes. It will discuss how to setup a Brane instance and how to connect with it in simple cases. It is also a good place to start if you're just interested in the framework and want to play with a test instance locally.

The [second group of chapters](./infrastructures/introduction.dm) describes how to work with the framework from a system engineer-perspective. They discuss how to setup your infrastructure for Brane to work with it, and then how to let the framework know it can access your infrastructure and how it should do so.

The [third group of chapters](./packages/introduction.md) is for software engineers. These concern themselves with how to write packages, how to test them locally and how to push them to a running Brane instance. It also features an introduction and documentation of BraneScript, one of the framework's DSLs.

Finally, the [fourth group of chapters](./workflows/introduction.md) is aimed at scientists. These chapters explain how to connect to a running instance, write a workflow, submit the workflow and retrieve results. This is also where Bakery is introduced and documented, the other of the framework's DSLs.

Regardless of which group of chapters you read, we will use some terminology about the framework that is explained in the [terminology](./terminology.md) chapter. Thus, it is good to read through it once, or at least have it open to use as reference.

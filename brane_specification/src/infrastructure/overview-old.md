# Infrastructure overview
In the [previous chapter](../overview.md), we effectively gave a broad overview of the design requirements of the Brane framework. We can summarize that concretely as the three design requirements that any implementation should implement:
 1. The implementation needs to abstract computation on different compute sites simultaneously as if they were one site
 2. The implementation should facilitate three different types of roles that are involved when creating a scientific workflow: system engineers, software engineers and scientists or researchers)
 3. The implementation should police access and usage of sensitive data

These three roles are individually quite complex, and combining them even more so. That means that the framework is very complex as well, and requires different levels of abstraction to understand what it is doing. For the rest of the chapters on infrastructure, we will investigate each of these abstraction levels separately, to be able to first grasp what the framework is doing as a whole before we look at individual parts.

Before that, however, we will first elaborate on the three main design requirements in this chapter. We believe that understanding what the framework is trying to solve will better help in understanding what it is trying to do. This methodology of also looking at design requirements is also 

For the remainder of this chapter, we will better establish the design requirements to understand what drives the design of the framework. Then, in subsequent chapters, we will start at the most abstracted view of the framework, and gradually zoom in to show how it is designed.

> The chapters on the infrastructure really only focus on which parts are there and what they are supposed to do. To understand how all they all interact, refer to the chapters about the [Operation](../operation/overview.md) of the framework.

## The requirements in-depth
However, before we can dive into the design of the topmost abstraction layer, we must first better explain the requirements imposed by each of the three main design requirements.

The first requirement, the one on abstracting away different sites, means that the framework will have to handle

## The Brane instance and the CLI
The first or highest level of abstraction is defining the generic structure that the framework follows. Because we have a framework that is expected to execute some compute workflow on remote sites on demand, the framework implements a **client/server model**. In this model, each user that wants to run a workflow acts as a client, that is then scheduled on one or more compute sites.

In Brane, we call the client-side of the interaction the **Brane command-line interface**, or **CLI** for short. This CLI is simply an executable that runs on the user's machine, and hosts a number of tools that can interact with the server. This server-side is referred to as a **Brane instance** (or simply **instance**), and is thus effectively what implements the Brane framework.

A simple diagram that shows this setup can be seen in Figure 1. Here, the user interacts with the CLI, which in turn sets commands the infrastructure to perform the work the user requests. While the figure may be very simple at this abstraction level, we will extend this diagram to become more and more concrete through subsequent chapters.

![Shows the two toplevel abstraction parts: a User, the CLI and an Instance](../img/brane_1.svg)
_Figure 1: The client/server model that forms the topmost abstraction of the Brane framework_

In the [next chapter](./brane-instance.md), we will start talking about the Brane instance in more depth to see how it is implemented. Once that journey is completed in subsequent chapters, we will return to the brane-cli and see how it drives the framework exactly.

# Toplevel design
To begin or discussion on Brane's architecture, we will first introduce its general layout and the underlying models; that will be done in this chapter.

We will first describe the most toplevel layout of the framework by defining its interaction model. Then, we will move one layer deeper, and talk about the implementation of the server (the **Brane instance**). Finally, we will conclude this chapter by discussing \<TBD\>.

Note that we will mostly focus on the server-side from these chapters on. It won't be until the [command-line interface](./command-line-interface.md) chapter that we will look at the client side, and even then, most of it is delegated to the chapters on framework [operation](../operation/command-line-interface.md).


## Interaction model
In [chapter 3](../design/framework-capabilities.md), we discussed how the workflows look like that we can pass to the framework. Now, we can now start to talk about the most generic implementation of Brane to allow execution of such a workflow.

The first concern we have to think about is what kind of interaction model we want to implement for Brane. Typically, when we talk about a 'framework', we either mean some kind of programming interface or some kind of runtime software that performs the framework's duties. Because Brane does not want to limit in what programming language its packages are written, it is implemented as a service; specifically, we define a **Brane instance**, which acts as a server in a standard, centralized **client/server model** and that takes a user's workflow and executes it on its compute sites. The client is provided as a **Command-Line Interface (CLI)**, that can be used to build and manage packages and build and submit workflows. A very simple diagram showing this interaction is shown in figure 2.

<img alt="Image showing the Brane framework interaction model" id="fig2" src="../assets/img/brane_1.svg"></img>
_Figure 2: The broadest overview of the Brane framework model. It shows how a user can interact with the server (a Brane instance) via a client (a Brane CLI)._

This choice of model means that the Brane instance is **driven by** the CLI; everything run on the server can be traced back to a command given by a user. This lends itself well to the idea of submitting one workflow to a central service, which then handles executing it efficiently. Additionally, this type of model is widely adopted by grid or cluster computers, which means that Brane's function as an abstraction layer over multiple of these sites is made easier by also choosing a similar model.


## Brane instance
We now know how the most generic picture of Brane looks like, we can define the Brane instance in a bit more detail.

When we look at a workflow for the Brane framework, we can see a clear separation between a **control plane** and a **compute plane**: the workflow code is run on the control plane, which schedules packages to run in the compute plane. Because of this, Brane itself is also divided into these two planes: there is a single control node (or multiple control nodes working together as one server), and one or more compute nodes that can handle the packages scheduled by Brane. One addition, however, is that Brane has to deal with separate compute sites, which usually aren't all that interconnected; that means that its model has to have this specific grouping of compute nodes built-in.

A consequence of this design decision is that the framework has to keep sensitive health data solely in the compute plane. This is because the control plane may be situated on any of the hospital's sites (or even an external site), meaning that we can expect that no hospital would like to share their data with the infrastructure on which the control node(s) run. As we will see in later chapters, this influences the way we design the workflow system.

We have extended figure 2 in figure 3, which also shows the separation between control and compute planes. The control node(s) and compute sites also have their location annotated where they may be able to run, showing why it is important why the control plane cannot directly see sensitive data.

<img alt="Image showing the Brane framework interaction model + control & compute plane separation" id="fig3" src="../assets/img/brane_2.svg"></img>
_Figure 3: Broad overview of the Brane framework model. It shows how a user may interact with the server (a Brane instance) via a client (a Brane CLI). Furthermore, it shows how the Brane instance is split into a control plane (left) and a compute plane (right)._


In the next chapters, we will first focus on the Brane instance, and in the [next chapter](./control-plane.md) specifically we will focus on the instance's control plane. From this point on, we can really start to get concrete with Brane's implementation.

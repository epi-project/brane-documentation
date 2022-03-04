# Introduction
In the [previous chapters](../design/introduction.md), we explained the rationale behind the design of the framework and what we ask of it. In these chapters, we will finally move to the real design of the framework. Specifically, we will focus on the infrastructure and architecture of the framework: which parts do they have and what is their assigned role.

The interaction between these parts will be left for the [third part](../operation/introduction.md) of the book. That part will assume that you are familiar with the parts and terms introduced in these chapters, so we strongly recommend to read this first.

First, we will go through the [toplevel design](./toplevel-design.md) of the framework, where we talk about the general model behind the framework. Then, we will begin the infrastructure discussion in earnest by describing [control plane](./control-plane.md) and its services. From there, we will also look at the implementation of the [data plane](./data-plane.md), only conclude this part by discussing how the [client-side](./command-line-interface.md) of the framework looks like (the CLI).

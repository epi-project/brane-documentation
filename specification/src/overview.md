# Overview of the Brane framework
The Brane framework is an infrastructure designed to facilitate computing over multiple compute sites, in a site-agnostic way. It thus acts as a middleware between a workflow that a scientist wants to run and various compute facilities with different capabilities, hardware and software.

Although originally developed as a general purpose workflow execution system, it has recently been adopted for use in healthcare as part of the [Enabling Personalized Interventions](https://enablingpersonalizedinterventions.nl) (EPI) project. To this end, the framework is being adapted and redesigned with a focus on working with sensitive datasets owned by different domains, and keeping the datasets in control of the data.

Brane is federated, which means that is has a centralised part that acts as an orchestrator that mediates work between decentralised parts that are hosted on participating domains. As such, they are called the _orchestrator_ and a _domain_, respectively.

The reason that Brane is called a framework is that domains are free to implement their part of the framework as they wish, as long as they adhere to the overall framework interface. Moreover, different Brane _instances_ (i.e., a particular orchestrator with a particular set of domains) can have different implementations, too, allowing it to be tailored to a particular use case's needs.

## Book layout
We cover a number of different aspects of Brane's design in this book, separated into different groups of chapters.

First, in the [development](./development/introduction.md)-chapters, we detail how to setup your laptop such that you can develop Brane. Part of this is compiling the most recent version of the framework.

In [design requirements](./requirements/introduction.md), we will discuss the design behind Brane and what motivated decisions made. Here, we will layout the parculiarities of Brane's use case and which assumptions where made. This will help to contextualise the more technical discussion later on.

The series on [implementation](./implementation/introduction.md) details how the requirements are implemented by discussing notable implementation decisions on a high-level. For low-level implementation, refer to the auto-generated [Brane Code Documentation](/docs.html).

In [framework specification](./spec/introduction.md), we provide some lower-level details on the "specification" parts of the framework. In essence, this will give technical interfaces or APIs that allow components to communicate with each other, even if they have a custom implementation.

Finally, we discuss [future work](./future/introduction.md) for Brane: ideas not yet implemented but which we believe are essential or otherwise very practical.

In addition to the main story, there is also the [Appendix](./appendix/introduction.md) which discusses anything not part of the official story but worth noting. Most notably, the specification of the custom Domain-Specific Language (DSL) of Brane is given here, [BraneScript](./appendix/languages/bscript/introduction.md).

# Overview of the Brane framework
The Brane framework is an infrastructure designed to facilitate computing over multiple compute sites, in a site-agnostic way. It is thus meant as a middleware, between a workflow that a scientist wants to run and various compute facilities with different capabilities, hardware and software.

Although originally developed as a general purpose workflow execution system, it has recently been adopted for use in healthcare as part of the [Enabling Personalized Interventions](https://enablingpersonalizedinterventions.nl) (EPI) project. To this end, the framework is being adapted and redesigned with a focus on working with sensitive datasets owned by different domains, and keeping the datasets in control of the data.

/\* old \*/

An additional feature of the framework is that it features a separation of concerns. It tries to facilitate three different roles, that each have their own concerns and their own interface they are used to work with: **system engineers**, who manage and build the compute site; **software engineers**, who program the algorithms that are needed in the execution of a workflow; and finally **scientists**, who design the final workflow and use that workflow to do research.

This split in work means that Brane is quite complex, and features different abstraction levels on how to interact with it. Part of this are the two domain-specific languages that are included in the framework: **BraneScript**, for software engineers, and **Bakery**, for scientists. The split in abstraction allows software engineers to use tools they are familiar with, while scientists can use an easier and more intuitive way of interacting with the framework. Finally, system engineers will interact with the framework more as a tool, the way they are used to.

As part of the EPI project, the Brane framework will additionally facilitate automatic policing of data access accoring to (legal) policies defined by the data owners, and then in particular health data. It does so, again, on two different abstraction levels: it controls who can see what data with **data level policies**, and what data can be run where with **network level policies** or **system level policies**.

In this book, we try to give an overview of how Brane is designed to achieve the goals above. It's meant to go really in-depth, so that the reader can understand, reason about and perhaps even work on the framework. This book can thus be thought of as an informal specification of the Brane framework's design.

## Book layout
We cover a number of different aspects of Brane's design in this book, separated into different groups of chapters.

First, we will provide a [design](./design/introduction.md) of the framework in the first few chapters: what are the framework's goals, what are the challenges that arose during its design, and what do we want the framework to do.

Then, we move to describing the framework's [infrastructure](./infrastructure/introduction.md). In these chapters, we discuss what parts are involved in the framework and which role each of them fulfills.

After that, we talk about the [operation](./operation/introduction.md) of the framework. This is really the part that explains what Brane does, but it relies heavily on the parts before to properly explain that. We go through each of the operations that Brane supports, and show how the different services interact to make that happen according to its design.

Finally, a lot of useful diagrams and figures can be found listed together in the [appendix](./appendix/introduction.md).

# Before you read
As discussed in the [overview](./overview.md) chapter, the Brane framework is aimed at different kind of users, each of them with their own role within the framework. This split of the framework in terms of roles is referred to as the _separation of concerns_.

The four roles that this book focusses on are:
- **system engineers**, who are in charge of one of the compute sites that Brane abstracts over. They have to prepare their site for the framework and discuss its integration with the infrastructure managers.
- **software engineers**, who write the majority of the software used in the Brane framework. This software will be distributed in the form of _packages_.
- **policy makers**, who define and write the policies that are relevant to the framework. These are both _data-level policies_, which describe who can access what data and how; and _network-level policies_, which describe where the data can be send on the infrastructure and what kind of security measures are needed when that happens.
- **scientists**, who orchestrate different packages into a **workflow**, which eventually implements the computation needed for their research.

To this end, the book itself is split into four groups of chapters, one for each of the roles in the separation of concerns.


## Terminology
Before you can begin, there is also some extra terminology that will be used throughout this book and that is useful to know here.


### The Brane instance
Looked at from the highest level of abstraction, Brane has a client part (in the form of a command-line tool or a [Jupyter notebook](https://jupyter.org/)) and a server part. The first is referred to as a **Brane client**, while the latter is referred to as the **Brane instance**.


## Where next
To continue reading, we suggest you start at the first chapter for your role. You can select it in the sidebar to the left.

If you are part of the fifth, "hidden" role (the Brane administrators), you have [your own book](https://wiki.enablingpersonalizedinterventions.nl/admins); we recommend you continue there. It also details how to obtain, compile and run the framework for testing purposes.

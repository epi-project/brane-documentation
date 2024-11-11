# Introduction
In this series of chapters, we will discuss the role of system administrators and how they may prepare their system for Brane. The chapters will talk about what the requirements are on their system and what kind of information they are expected to share with the Brane instance. Finally, we will also discuss defining datasets.

To know more about the inner workings of Brane, we recommend you checkout the [Brane: A Specification](/specification) book. That details the framework's inner workings.


## Background & Terminology
The Brane instance defines a _central node_ (or _control node_), which is where the orchestrator itself and associated services run. This node is run by the _Brane administrators_. Then, as a counterpart to this central node, there is the _worker plane_, which is composed of all the different compute sites that Brane orchestrates over. Each such compute site is referred to as a _domain_, a _location_ or, since Brane treats them as a single entity, a _worker node_. Multiple worker nodes may exist per physical domain (e.g., a single hospital can have multiple domains for different tasks), but Brane will treat these as conceptually different places.

Within the framework, a _system administrator_ is someone who acts as the 'technical owner' of a certain worker node. They are the ones who can make sure their system is prepared and meets the Brane requirements, and who defines the security requirements of any operation of the framework on their system. They are also the ones who make any data technically available that is published from their domain. And although policies are typically handled by [_policy writers_](../policy-experts/introduction.md), another role in the framework, in practise, this can be the same person as the system administrator.


## The Central node
For every Brane instance, there is typically only one _central node_. Even if multiple VMs are used, the framework expects it to behave like a single node; this is due to the centralized nature of it.

The central node consists of the following few services:
- The _driver service_ is, as the name suggests, the driving service behind a central node. It takes incoming workflows submitted by scientists, and starts executing them, emitting jobs that need to be executed on the worker nodes.
- The _planner service_ takes incoming workflows submitted to the driver service and _plans_ them. This is simply the act of defining which worker node will execute which task, and takes into account available resources on each of the domains, as well as policies that determine if a domain can actually transfer data or execute the job.
- The _registry service_ (sometimes called _central registry service_ or _API service_ for disambiguation) is the centralized version of the local registry services (see [below](#the-worker-node)). It acts as a centralized database for the framework, which provides information about which dataset is located where, which domains are participating and where to find them<small><small><small><sup><a href="../assets/img/domains-and-where-to-find-them.jpg">1</a></sub></small></small></small>, and in addition hosts a central package repository.
- Finally, the _proxy service_ acts as a gateway between the other services and the outside world to _enable_ proxying (i.e., it does not accept proxied requests, but rather creates them). In addition, it is also the point that handles server certificates and parses client certificates for identifications.

For more details, check the [specification](/specification).

Note that, if you need any compute to happen on the central node, this cannot be done through the central node itself; instead, setup a [worker node](#the-worker-node) alongside the central node to emulate the same behaviour.


## The Worker node
As specified, a domain typically hosts a worker node. This worker node collectively describes both a local control part of the framework, referred to as the framework _delegate_, and some computing backend that actually executes the jobs. In this section, we provide a brief overview of both.

The _delegate_ itself consists of a few services. Their exact working is detailled in the [specification](/specification), but as a brief overview:
- The _delegate service_ is the main service on the delegate, and takes incoming job requests and will attempt to schedule them. This is also the service that directly connects to the compute backend (see below). You can think of it as a local driver service.
- The _registry service_ (sometimes called _local registry service_ for disambiguation) keeps track of the locally available datasets and intermediate results (see the [data tutorial](../software-engineers/data.md) for Software Engineers or the [data tutorial](../scientists/bscript/datasets.md) for Scientists for more information) and acts as a point from where the rest of the framework downloads them.
- The _checker service_ acts as the Policy Enforcement Point (PEP) for the framework. It hosts a [reasoner](https://github.com/epi-project/policy-reasoner), typically eFLINT, and is queried by both the delegate and registry services to see if operations are allowed.
- Finally, the local node also has _proxy service_, just like the [central node](#the-central-node).

As for the compute backend, Brane is designed to connect to different types. An overview:
{{#include ./backends/overview.md}}

More information on each backend and how to set it up is discussed in the [backends chapter(s)](./backends/introduction.md).


## Next
To start setting up your own worker node, we recommend checking out the [installation chapters](./installation/introduction.md). These will walk you through everything you need to setup a node, both central nodes and worker nodes.

For information on setting up different backends, check the [backend chapters](./backends/introduction.md).

Alternatively, if you are looking for extensive documentation on the Brane configuration files relevant to a worker node, checkout the [documentation chapters](./docs/overview.md).



<img hidden src="../assets/img/domains-and-where-to-find-them.jpg" alt="meme" width="1"/>

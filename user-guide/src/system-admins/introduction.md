# Introduction
In this series of chapters, we will discuss the role of system administrators and how they may prepare their system for Brane. The chapters will talk about what the requirements are on their system and what kind of information they are expected to share with the Brane instance. Finally, we will also discuss defining datasets.

To know more about the functionality of the part of Brane that will run locally on your system, we recommend you checkout the [Brane: A Specification](https://wiki.enablingpersonalizedinterventions.nl/specification) book. That details the framework's inner workings.


## Background & Terminology
The Brane instance defines a _control node_ (or _central node_), which is where the orchestrator itself and associated services run, which is managed by the _Brane administrators_. Then, as a counterpart to this control node, there is the _worker plane_, which is composed of all the different compute sites that Brane orchestrates over. Each such compute site is referred to as a _domain_, which typically hosts a single _worker node_. Multiple worker nodes may exist per domain, but Brane will treat these as conceptually different places.

Within the framework, a _system administrator_ is someone who acts as the 'technical owner' of a certain infrastructure. They are the ones who can make sure their system is prepared and meets the Brane requirements, and who defines the security requirements of any operation of the framework on their system. They are also the ones who manage data that is published on a domain from a technical perspective. Policies, however, are typically handled by the [_policy writers_](TODO), although in practise this can be the same person as the system administrator.


## The Central node
For every Brane instance, there is typically only one _control node_. Even if multiple VMs are used, the framework expects it to behave like a single node; this is due to the centralized nature of it.

The control node consists of the following few services:
- The _driver service_ is, as the name suggests, the driving service behing a control node. It takes incoming workflows submitted by scientists, and starts executing them, emitting jobs to be executed.
- The _planner service_ takes incoming workflows submitted to the driver service and _plans_ them. This is simply the act of filling in 'open' locations for jobs in the workflow, and takes into account available resources on each of the domains, as well as policies that determine if a domain can actually transfer data or execute the job.
- The _registry service_ (sometimes called _central registry service_ or _API service_ for disambiguation) is the centralized version of the local registry services (see [below](#the-worker-node)). It acts as a centralized database for the framework, which provides information about which dataset is located where, hosts a cental package repository and discloses information about participating domains (such as where to find them).
- Finally, the _proxy service_ is not a service that proxies but rather a service that enables proxying. All outgoing communication from the worker node is initiated by the proxy service itself, which has the ability to redirect it through the [bridging functions](TODO). This is necessary to avoid having any of the other services running in privileged mode.

For more details, check the [specification](https://wiki.enablingpersonalizedinterventions.nl/specification).

Note that, if you need any compute to happen on the central node, this cannot be done through a central node itself; instead, setup a [worker node](#the-worker-node) alongside the central node to emulate the same behaviour.


## The Worker node
As specified, a domain typically hosts a worker node. This worker node collectively describes both a local control part of the framework, referred to as the framework _delegate_, and some computing backend that actually executes the jobs. In this section, we provide a brief overview of both.

The _delegate_ itself consists out of a few services. Their exact working is detailled in the [specification](https://wiki.enablingpersonalizedinterventions.nl/specification), but as a brief overview:
- The _delegate service_ is the main service on the delegate, and takes incoming job requests and will attempt to schedule them. This is also the service that directly connects to the compute backend (see below).
- The _registry service_ keeps track of the locally available datasets and intermediate results (see the [data tutorial](../software-engineers/data.md) for Software Engineers or the [data tutorial](TODO) for Scientists for more information) and acts as a point from where to download them.
- The _checker service_ acts as the Policy Enforcement Point (PEP) for the framework. It hosts a reasoner, typically eFLINT, and is queried by both the delegate and registry services to see if operations are allowed.
- Finally, the _proxy service_ is not a service that proxies but rather a service that enables proxying (the same as on the control node). All outgoing communication from the worker node is initiated by the proxy service itself, which has the ability to redirect it through the [bridging functions](TODO). This is necessary to avoid having any of the other services running in privileged mode.

As for the compute backend, Brane is designed to connect to different types. An overview:
{{#include ./backends/overview.md}}

More information on each backend and how to set it up is discussed in the [backends](./backends/introduction.md) chapter(s).


## Next
To start setting up your own worker node, we recommend checking out the [installation chapters](./installation/introduction.md). These will walk you through everything you need to setup a node, both control nodes and worker nodes.

For information on setting up different backends, check the [backend chapters](./backends/introduction.md).

Alternatively, if you are looking for extensive documentation on the Brane configuration file relevant to a worker node, checkout the [documentation chapters](./docs/overview.md).

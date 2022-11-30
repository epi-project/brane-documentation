# Introduction
In this series of chapters, we will discuss the role of system engineers and how they may prepare their system for Brane. The chapters will talk about what the requirements are on their system and what kind of information they are expected to share with the Brane instance administrators.

To know more about the functionality of the part of Brane that will run locally on your system, we recommend you checkout the [Brane: A Specification](https://wiki.enablingpersonalizedinterventions.nl/specification) book. That details the framework's inner workings.


## Background & Terminology
The Brane instance defines a _control plane_, which is where the orchestrator itself and associated services run, which is managed by the _Brane administrators_. Then, as a counterpart to this control plane, there is the _compute plane_, which is composed of all the different compute sites that Brane orchestrates over. Each such compute site is referred to as an _infrastructure_, which is meant as a colloqial term for whatever system may actually implement the compute infrastructure.

Within the framework, a _system engineer_ is someone who acts as the 'technical owner' of a certain infrastructure. They are the ones who can make sure their system is prepared and meets the Brane requirements, and who defines the security requirements of any operation of the framework on their system.

In the current state of the framework, system engineers will have little actual operation with the framework itself. Instead, they are mostly expected to manage their system so Brane may run on it.


## Possible infrastructures
Currently, Brane supports the following types of infrastructure:
- _Local infrastructures_ schedules new jobs on the same Docker engine where the control plane of Brane runs. This is the simplest infrastructure of them all, and requires no other preparation than required when installing the control plane.
- _Vm infrastructures_ are a single virtual machine or node that will be used to schedule jobs on. Brane will connect to them with SSH (via the [Xenon](https://github.com/xenon-middleware/xenon) middleware), and then use standard [Docker](https://docker.com) commands to schedule jobs.
- _Kubernetes infrastructures_ are [Kubernetes](https://kubernetes.io) clusters that will accepts incoming container jobs from Brane. The recommended way of operation is to define a separate namespace for Brane, as it will do little more than to launch individual jobs.
- _Slurm infrastructures_ are [Slurm](https://www.schedmd.com/)-managed systems that will run containers as well. This infrastructure type may be hard to setup, as Slurm does not have any builtin Docker support. Otherwise, Brane can work well with Slurm to schedule jobs as if they were normal jobs.


## Next
In the [next chapter](./vm.md), we will start discussing the preparation and requirements of the VM infrastructures. We purposefully skip the local infrastructures, because these usually have a trivial setup and are managed by Brane administrators anyway.

If you are in charge of another type of infrastructure, choose another type in the sidebar.

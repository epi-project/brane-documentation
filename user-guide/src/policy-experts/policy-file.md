# The Policy File

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> This page is for the temporary method of entering policies into the system. A better method (involving eFLINT) will be implemented soon, making this chapter irrelevant.

Currently, Brane reads its policies from a so-called _policy file_ (also known as `policies.yml`) which defines a very simplistic set of access-control policies.

Typically, there is one such policy file per domain, which instructs the "reasoner" for that domain what is should allow and what not.

In this chapter, we discuss how one might write such a policy file. In particular, we will discuss the [general layout](#overview) of the file, and then the two kinds of policies currently supported: [user policies](#user-policies) and [container policies](#container-policies).


## Overview
The `policies.yml` file is written in [YAML](https://yaml.org/) for the time being.

It has two sections, each of them corresponding to a kind of policy (`users` and `containers`, respectively). Each section is then a simple list of rules. At runtime, the framework will consider the rules top-to-bottom, in order, to find the first rule that says something about the user/dataset pair or the container in question. To 


## User policies
User policies concern themselves what a user may _access_. These policies thus always describe some kind of rule on a pair of a user (known by their ID) and a dataset (also known by its ID).

As a policy expert, you may assume that by the time your policy file is consulted, the framework has already verified the user's ID. As for datasets, your policies are only consulted when data is accessed on your own domain, and so you can also assume that dataset IDs used correspond to the desired dataset.

Note that _which_ user IDs and dataset IDs to use should be done in cooperation with the system administrator of your domain. Currently, the framework doesn't provide a safe way of communicating which IDs are available to the policy file, so you will have to retrieve the up-to-date list of IDs the old-fashioned way.


## Container policies

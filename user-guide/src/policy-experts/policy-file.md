# The Policy File

> <img src="../assets/img/warning.png" alt="warning" width="16" style="margin-top: 3px; margin-bottom: -3px"/> This page is for the temporary method of entering policies into the system. A better method (involving eFLINT) will be implemented soon, making this chapter irrelevant.

Currently, Brane reads its policies from a so-called _policy file_ (also known as `policies.yml`) which defines a very simplistic set of access-control policies.

Typically, there is one such policy file per domain, which instructs the "reasoner" for that domain what is should allow and what not.

In this chapter, we discuss how one might write such a policy file. In particular, we will discuss the [general layout](#overview) of the file, and then the two kinds of policies currently supported: [user policies](#user-policies) and [container policies](#container-policies).


## Overview
The `policies.yml` file is written in [YAML](https://yaml.org/) for the time being.

It has two sections, each of them corresponding to a kind of policy (`users` and `containers`, respectively). Each section is then a simple list of rules. At runtime, the framework will consider the rules top-to-bottom, in order, to find the first rule that says something about the user/dataset pair or the container in question. A full list of available policies can be found [below](#policies).

Before that, we will first describe the kinds of policies in some more detail in the following sections.


### User policies
User policies concern themselves what a user may _access_, and then specifically, which _dataset_ they may access. These policies thus always describe some kind of rule on a pair of a user (known by their ID) and a dataset (also known by its ID).

As a policy expert, you may assume that by the time your policy file is consulted, the framework has already verified the user's ID. As for datasets, your policies are only consulted when data is accessed on your own domain, and so you can also assume that dataset IDs used correspond to the desired dataset.

Note that _which_ user IDs and dataset IDs to use should be done in cooperation with the system administrator of your domain. Currently, the framework doesn't provide a safe way of communicating which IDs are available to the policy file, so you will have to retrieve the up-to-date list of IDs the old-fashioned way.


### Container policies
Container policies concern themselves with which container is allowed to be run at a certain domain. Right now, it would have seemed obvious that they are triplets of users, datasets and containers - but due to time constraints, they currently only feature a container hash (e.g., its ID) that says if they are allowed to be implemented or not.

Because the ID of a container is a SHA256-hash, you can safely assume that whatever container your referencing will actually reference that container with the properties you know of it. However, similarly to [user policies](#user-policies), there is no list available in the framework itself of known container hashes; thus, this list must be obtained by asking the system's administrator or, maybe more relevant, a scientist who wants to run their container.


## Policies
In this section, we describe the concrete policies and their syntax. Remember that policies are checked in-order for a matching rule, and that the framework will throw an error if no matching rule is found.

In general, there are two possible actions to be taken for a given request: _allow_ it, in which case the framework proceeds, or _deny_ it, in which case the framework aborts the request. For each of those action, though, there are multiple ways of matching a user/dataset pair or a container hash, which results in the different policies described below.

Syntax-wise, the policies are given as a vector of dictionaries, where each dictionary is a policy. Then, every such dictionary must always have the `policy` key, which denotes its type (see the two sections below). Any other key is policy-dependent.


### User policies
The following policies are available for user/dataset pairs:
- `allow`: Matches a specific user/dataset pair and **allows** it.
  - `user`: The identifier of the user to match.
  - `data`: The identifier of the dataset to match.
- `deny`: Matches a specific user/dataset pair and **denies** it.
  - `user`: The identifier of the user to match.
  - `data`: The identifier of the dataset to match.
- `allow_user_all`: Matches _all_ datasets for the given user and **allows** them.
  - `user`: The identifier of the user to match.
- `deny_user_all`: Matches _all_ datasets for the given user and **denies** them.
  - `user`: The identifier of the user to match.
- `allow_all`: Matches _all_ user/dataset pairs and **allows** them.
- `deny_all`: Matches _all_ user/dataset pairs and **denies** them.


### Container policies
The following policies are available for containers:
- `allow`: Matches a specific container hash and **allows** it.
  - `hash`: The hash of the container to match.
  - `name` (optional): A human-friendly name for the container (no effect on policy, but for debugging purposes).
- `deny`: Matches a specific container hash and **denies** it.
  - `hash`: The hash of the container to match.
  - `name` (optional): A human-friendly name for the container (no effect on policy, but for debugging purposes).
- `allow_all`: Matches _all_ container hashes and **allows** them.
- `deny_all`: Matches _all_ container hashes and **denies** them.


## Example
The following snippet is an example policy file:
```yaml
# The user policies
users:
# Allow the user 'Amy' to access the datasets 'A', 'B', but not 'C'
- policy: allow
  user: Amy
  data: A
- policy: allow
  user: Amy
  data: B
- policy: deny
  user: Amy
  data: C

# Specifically deny access to `Dan` to do anything
- policy: deny_user_all
  user: Dan

# For any other case, we deny access
- policy: deny_all



# The container policies
containers:
# We allow the `hello_world` container to be run
- policy: allow
  hash: "GViifYnz2586qk4n7fdyaJB7ykASVuptvZyOpRW3E7o="
  name: hello_world

# But not the `cat` container
- policy: deny
  hash: "W5WS23jAAtjatN6C5PQRb0JY3yktDpFHnzZBykx7fKg="
  name: cat

# Any container not matched is allowed (bad practice, but to illustrate)
- policy: allow_all
```

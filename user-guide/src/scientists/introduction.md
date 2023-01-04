# Introduction
In these few chapters, we will explain the role of scientists within the framework. Specifically, we will talk about _BraneScript_ and _Bakery_, two domain-specific languages (DSLs) for Brane that are used to write workflows. Concretely, this chapters will thus focus on writing the high-level workflows that may implement a specific use-case.

To start, we recommend that you first read the [next section](#background) to get a little background and read about some terminology that we will be using. After that, you can go the [next chapter](./installation.md), where we will discuss preparing your machine for interacting with Brane.


## Background
Typically, workflows revolve around _packages_ that contain _external functions_ (also known as _package functions_). These are treated extensively in the [chapters for software engineers](../software-engineers/introduction.md), but all a scientist needs to know is that each function is an algorithm that maybe be executed on a remote backend, managed by Brane.

Another important concept is that of _datasets_, which are (typically large) files or other sources that contain the data that package functions may operate on. For example, a dataset may be a CSV file with tabular data; or in another instance, it's a compressed archive of CT-scan images.

Workflows are typically in the business of using a combination of package functions acting on certain datasets to achieve certain goals. In short, they are high-level descriptions and implementation of a use-case. And that's exactly the role that a Scientist has in the Brane framework: writing these high-level workflows using low-level packages provided by software engineers as implementation.


## Next
In the [next chapter](./installation.md), we will walk you through setting up your machine to start writing workflows. If you have already done so previously, you can also [skip ahead](./packages.md) and learn how to manage packages for your workflows.

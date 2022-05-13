# Introduction
In this chapter, we will provide a brief overview of the different packages that Brane supports.


## Overview
To provide an as versatile and easy-to-use interface as possible, Brane has different ways of defining packages. Apart from just being able to execute arbitrary code, it also supports perform requests according to the [OpenAPI](https://www.openapis.org/) standard and (in the future) supports publishing [Common Workflow Language](https://www.commonwl.org/) workflows as packages as well.

Concretely, the different types that are supported are:
- Executable Code Unit (`ecu`) packages are containers containing arbitrary code that is run via the `branelet` wrapper.
- OpenAPI Standard (`oas`) packages are packages that make API requests defined in the OpenAPI format. It is, once again, the `branelet` executable that performs these calls.

> <img src="../assets/img/info.png" alt="drawing" width="16" style="margin-top: 3px; margin-bottom: -3px"/> We are working on adding other package formats, which will be added to this list in the future. One promiment technology that we would like to add is support for the Common Workflow Language, and another one is publishing Brane's DSLs (BraneScript and Bakery) as packages as well.

In the subsequent chapters, we will document the exact workings of each supported package kind. The [next chapter](./ecu.md) starts with a documentation of the Executable Code Unit packages, but you can skip to others by using the sidebar to the left.

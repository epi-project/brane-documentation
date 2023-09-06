# Appendix A: BraneScript specification
Brane is designed to be loosely-coupled between how scientists interact with it and how the framework learns its input (see [Design requirements](../../../requirements/introduction.md)). As such, the framework specification itself only specifies the [Workflow Internal Representation](TODO) (WIR), which unifies all frontends into one language.

That said, the framework does feature its own workflow language, BraneScript. These chapters are dedicated to documenting the language. To learn how to use the language, refer to [The User Guide](https://wiki.enablingpersonalizedinterventions.nl/user-guide/branescript/introduction.html) instead.


## Layout
The chapters are structured as follows. First, in the [Structure](./structure.md)-chapter, we discuss the overall design of the language and introduce the main language concepts. Then, in the [Abstract syntax](./syntax.md)-chapter, we give a formal specification of the syntax of BraneScript. The subsequent chapter, the [Semantics](./semantics.md)-chapter, then defines how the parsed structures can be interpreted by a virtual machine.

Finally, in the [Future work](./future.md)-chapter, we elaborate on ideas and improvements not yet implemented.

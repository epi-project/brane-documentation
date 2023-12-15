# Appendix A: BraneScript specification
Brane is designed to be loosely-coupled between how scientists interact with it and how the framework receives its input (see [Design requirements](../../../requirements/introduction.md)). As such, the framework specification itself only specifies the [Workflow Internal Representation](../../../spec/wir/introduction.md) (WIR), which unifies all frontends into one language.

That said, the framework does feature its own workflow language, BraneScript. These chapters are dedicated to documenting the language. To learn how to use the language, refer to [The User Guide](https://wiki.enablingpersonalizedinterventions.nl/user-guide/branescript/introduction.html) instead.


## Layout
The chapters are structured as follows. First, in the [Features](./features.md)-chapter, we discuss the concepts of the language and which statements exist. Then, we discuss how BraneScript is compiled to the WIR, which will define specifics of the language: the [grammar](./syntax.md), [scoping rules](TODO), [typing rules](TODO) andsoforth.

Finally, in the [Future work](./future.md)-chapter, we elaborate on ideas and improvements not yet implemented.

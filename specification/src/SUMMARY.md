# Summary

[Welcome](./welcome.md)
[Overview](./overview.md)

# Design requirements
- [Introduction](./requirements/introduction.md)
- [Background](./requirements/background.md)
- [Context & Use-case](./requirements/use_case.md)
- [Requirements](./requirements/requirements.md)

# Implementation
- [Introduction](./implementation/introduction.md)
- [Bird's-eye view](./implementation/bird_eye.md)
- [Virtual Machine (VM) for the WIR](./implementation/vm/introduction.md)
    - [Overview](./implementation/vm/overview.md)
    - [Expression stack](./implementation/vm/stack.md)
    - [Variable register](./implementation/vm/var_reg.md)
    - [Frame stack](./implementation/vm/frame_stack.md)
    - [Bringing it together](./implementation/vm/showcase.md)
        - [Workflow example](./implementation/vm/showcase_appendix.md)
- [Services](./implementation/services/overview.md)
    - [`brane-drv`](./implementation/services/brane-drv.md)
    - [`brane-plr`](./implementation/services/brane-plr.md)
    - [`brane-api`](./implementation/services/brane-api.md)
    - [`brane-job`](./implementation/services/brane-job.md)
    - [`brane-reg`](./implementation/services/brane-reg.md)
    - [`brane-prx`](./implementation/services/brane-prx.md)

# Framework specification
- [Introduction](./spec/introduction.md)
- [Workflow Internal Representation (WIR)](./spec/wir/introduction.md)
    - [Toplevel schema](./spec/wir/schema.md)
    - [Layer 1: The graph](./spec/wir/graph.md)
    - [Layer 2: Instructions](./spec/wir/instructions.md)

# Future work
- [Introduction](./future/introduction.md)


-----
# Appendix
- [Overview](./appendix/overview.md)
- [Appendix A: BraneScript specification](./appendix/languages/bscript/introduction.md)
    - [Introduction](./appendix/languages/bscript/introduction.md)
    - [Features](./appendix/languages/bscript/features.md)
    - [Formal grammar](./appendix/languages/bscript/syntax.md)
    - [Scoping rules](./appendix/languages/bscript/scoping.md)
    - [Typing rules](./appendix/languages/bscript/typing.md)
    - [Workflow analysis](./appendix/languages/bscript/workflow.md)
    - [Compilation steps](./appendix/languages/bscript/compilation.md)
    - [Future work](./appendix/languages/bscript/future.md)

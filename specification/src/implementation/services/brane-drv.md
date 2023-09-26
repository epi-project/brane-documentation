# `brane-drv`: The driver
Arguably the most central to the framework is the `brane-drv` service. It implements the _driver_, the entrypoint and main engine behind the other services in the framework.

In a nutshell, the `brane-drv`-service waits for a user to submit a workflow (given in the [Workflow Internal Representation](../../spec/wir/introduction.md) (WIR)), prepares it for execution by sending it to [`brane-plr`](./brane-plr.md) and subsequently executes it.

This chapter will focus on the latter function mostly, which is executing the workflow in WIR-format. For the part of the driver that does user interaction, see the [specification](TODO); and for the interaction with `brane-plr`, see [that service's chapter](./brane-plr.md).


## The driver as a VM
> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 2px; margin-bottom: -2px"/> The rest of this chapter will be written soon.

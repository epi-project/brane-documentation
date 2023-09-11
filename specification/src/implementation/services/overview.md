# Services
Brane is implemented as a collection of services, and in the next few chapters we will introduce and discuss every of them. As we do so, we also discuss algorithms and representation used in order to make sense of the services.


## Central services
The services found in the central orchestrator are:
- [brane-drv](./brane-drv.md) implements the _driver_ and acts as both the entrypoint and execution engine to the rest of the framework.
- [brane-plr](./brane-plr.md) implements the _planner_ and is responsible for deducing missing information in the submitted workflow.
- [brane-api](./brane-api.md) implements the _global audit log_ and provides global information to other services in the framework.
- [brane-prx](./brane-prx.md) implements the _proxy_ and fascilitates and polices inter-node communication.

The following services are placed on each domain:
- [brane-job](./brane-job.md) implements the _worker_ and processes the incoming events from the driver.
- [brane-reg](./brane-reg.md) implements the _local audit log_ and provides local information to its `brane-job` and the central registry `brane-api`. It also implements partial _worker_ functionality by fascilitating data transfers.
- [brane-prx](./brane-prx.md) implements the _proxy_ and fascilitates and polices inter-node communication.

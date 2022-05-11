# Specifications
This page lists a couple of properties and useful-to-know specifications from an admin perspective about a default Brane instance.


## Ports
By default, a Brane control plane uses the following ports:

| Port  | Service          | Description |
|-------|------------------|-------------|
| 6379  | Redis filesystem | The Redis filesystem that is used to provide an inter-package shared file system. |
| 8081  | `brane-log`      | The port of the logging service of Brane. |
| 9000  | Minio database   | The backend, 'persistent' database for the JuiceFS shared filesystem. |
| 50050 | Docker registry  | The Docker Image registry that contains the package images (and, in the case of a Kubernetes setup, the Brane instance images too). |
| 50051 | `brane-api`      | The Brane API backend that is used to interact with the package registry. |
| 50052 | `brane-clb`      | The interface for any job callbacks to the Kafka event handler. |
| 50053 | `brane-drv`      | This is the port where any clients (for packages or workflows) will connect to. Can be thought of as the entrypoint to the framework. |
| 50054 | `brane-xenon`    | The Xenon service that can be used as middleware when connecting to local orchestrators. Only needs to be exposed if used. |
| 50055 | `brane-log`      | The logging service, which logs Kafka events and may receive specific log messages from other services. |

Any other services not mentioned here are only accessed from the shielded Docker network, never the outside.

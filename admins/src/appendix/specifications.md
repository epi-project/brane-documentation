# Specifications
This page lists a couple of properties and useful-to-know specifications from an admin perspective about a default Brane instance.


## Ports
By default, a Brane control plane uses the following ports:

| Port  | Service          | Exposed? | Description |
|-------|------------------|----------|-------------|
| 5000  | Docker registry  | yes      | The Docker Image registry that contains the package images (and, in the case of a Kubernetes setup, the Brane instance images too). |
| 6379  | Redis filesystem | yes      | The Redis filesystem that is used to provide an inter-package shared file system. |
| 8080  | `brane-api`      | yes      | The Brane API backend that is used to interact with the package registry. |
| 8081  | `brane-log`      | yes      | The port of the logging service of Brane. |
| 9000  | Minio database   | yes      | The backend, 'persistent' database for the JuiceFS shared filesystem. |
| 9042  | Scylla database  | no       | The database behind the `brane-api` service. |
| 9092  | Kafka            | no       | The Kafka service that handles inter-service events. Only used internally in the control plane, though. |
| 50051 | `brane-xenon`    | yes*     | The Xenon service that can be used as middleware when connecting to local orchestrators. Only needs to be exposed if used. |
| 50052 | `brane-clb`      | yes      | The interface for any job callbacks to the Kafka event handler. |
| 50053 | `brane-drv`      | yes      | This is the port where any clients (for packages or workflows) will connect to. Can be thought of as the entrypoint to the framework. |

Any other services not mentioned here are only accessed from the shielded Docker network, never the outside.

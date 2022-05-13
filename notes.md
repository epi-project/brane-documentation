# Notes
Here, I note notes about the documentation as I'm writing it.


## Structure
Currently, I've divided the doc into three books:
- Brane: Guide For Administrators (`./admins`) documents how to install the framework and add domains to it.
- Brane: The User Guide (`./user-guide`) documents how to use the framework (write packages, write workflows, submit workflows, etc).
- Brane: A Specification (`./specification`) documents the framework itself and its inner workings. This is thus the most 'documentation' of the three books (the others are more tutorials).

As for the framework itself, right now, it seems like the system engineers will probably be developing / altering their own `brane-job`, so their part will have overlap with the specification?

Idk - gotta think about that one.

In any case, for the students, it's not yet relevant. There, we will focus on the following:
- `admins` will contain how they can 'setup' the framework, i.e., install it on their Kubernetes cluster and then add a domain to it (the Kubernetes cluster again).
- `user-guide` will contain how they can write packages and then run them.

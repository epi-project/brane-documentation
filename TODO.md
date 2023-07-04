# TODO
An unofficial overview of the pages that absolutely have to be updated, in the order of updating.


## [User guide](https://wiki.enablingpersonalizedinterventions.nl/user-guide)
### Created
- [ ] [5.5 Proxy node](./user-guide/src/system-admins/installation/proxy-node.md)
- [ ] [6. Brane compute backends](./user-guide/src/system-admins/backends/introduction.md)
- [ ] [6.1. Local backend](./user-guide/src/system-admins/backends/local.md)
- [ ] [7. Introduction](./user-guide/src/policy-experts/introduction.md)
- [ ] [8. Installation](./user-guide/src/policy-experts/installation.md)
- [ ] [20. BraneScript Workflows](./user-guide/src/scientists/bscript/)
- [ ] [6.2. SSH backend](./user-guide/src/system-admins/backends/ssh.md) _Note: this backend support isn't working in the code either, so wait until done with that before fixing_
- [ ] [6.3. Kubernetes backend](./user-guide/src/system-admins/backends/k8s.md) _Note: this backend support isn't working in the code either, so wait until done with that before fixing_
- [ ] [22. Using the Brane-IDE](./user-guide/src/scientists/jupyter.md) _Note: Must wait until I fixed implementation_

### Updated
- [ ] [10-14. Software engineers](./user-guide/src/software-engineers/) _Note: Have to check if it has to be updated, been a while since I wrote this_
- [ ] [28-33. BraneScript](./user-guide/src/branescript/)

### To be removed?
- [ ] [6.4. Slurm backend](./user-guide/src/system-admins/backends/slurm.md) _Note: this backend support isn't working in the code either, so very subject to change_ _Note: do we even_ want _to support this backend? I don't know of a Slurm backend that supports containers..._
- [ ] [15. Alternatve packages: OpenAPI Standard](./user-guide/src/software-engineers/github.md) _Note: supporting this doesn't make a lot of sense anymore, will be represented as a dataset_
- [ ] [21. Bakery Workflows](./user-guide/src/scientists/bakery/) _Note: are we ever going to have time to rediscover and re-implement Bakery..._
- [ ] [26. 27. Packages](./user-guide/src/packages/) _Note: obsolete with the `Configuration files` section_
- [ ] [34. Bakery](./user-guide/src/bakery/) _Note: are we ever going to have time to rediscover and re-implement Bakery..._


## [Specification](https://wiki.enablingpersonalizedinterventions.nl/specification)
The whole book in general. This book should explain the inner workings of BRANE, so it's very important if we are to transfer the project in the future.

Essentially, everything in there is old and outdated, so I'll have to sit down and properly think about what it needs. This includes things like API/network specs, as well as explanations for the compiler, language definitions, the lot - this will be a lot more work, but extremely valuable.

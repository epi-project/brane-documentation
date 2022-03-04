# The Brane Instance
In the [previous chapter](./overview.md), we discussed how the toplevel abstraction of the Brane framework looks like. There, we identified that the framework follows a **client/server model**, where the server is implemented by a **Brane instance**.

In this chapter, we will move an abstraction layer deeper and discuss how the Brane instance is designed.

## Extending the requirements
Because the Brane instance is essentially what implements the Brane framework, it automatically inherits the design requirements for the Brane framework. These design requirements can be found in the [previous chapter](./overview.md).

However, now that we know that the instance is play the server role in a client/server model, we can add further requirements to make the instance adhere to this model:

 1. The client is the one that **drives** the instance, and not the instance itself; in other words, everything that is being done can be traced back to the client issueing some command to do it.
 2. The instance has to have some kind of **centralized design** that allows the user to treat the instance as a single server.
 3. The instance should also be able to host concurrent client sessions in parallel. While not strictly necessary, it is a very convenient feature that is often paired with the client/server model.
    - As a subrequirement, this also means the instance should scale well to handle the extra load extra connections bring.

With these requirements in mind, we can now look at how the Brane instance is designed to meet them.

## Control and compute planes
The Brane instance implements its requirements by making a clear distinction between a **control plane** and one or more **compute plane**. This is visualized in figure 2, which extends the diagram from the [previous chapter](./overview.md) to show this.

![Shows the second abstraction of the framework: a User, a CLI, a control plane and multiple compute planes](../img/brane_2.svg)
_Figure 2: The client/server model expanded with the control and compute plane(s). It also shows that each compute plane can perfectly match each of the compute sites._

The approach solves multiple design requirements. The first it solves is the issue of needed some kind of central access point for the user: by explicitly having a control plane, we immediately have a natural point for the client to connect to and interact with. Another that it solves is that the introduction of multiple data planes can perfectly facilitate our desire to schedule work on different compute sites. Each data plane can correspond to one of the sites, and they are all orchestrated by the single control plane that has the overview. That means that the Brane instance directly provides the abstraction we want over multiple compute sites.

One disadvantage of this approach is that it complicates the third design requirement of the Brane framework. As stated in the generic [Overview](../overview.md), Brane is expected to police and safely handle sensitive data such as health data. However, in the current system, every hospital is responsible for its own data (i.e., very decentralized), and can't just trust other hospitals with their own data. This means that with the introduction of a centralized control plane, we suddenly have the issue of making sure that the control plane itself doesn't see 

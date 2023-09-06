# Bird's-eye view
In this chapter, we provide a bird's-eye view of the framework. We introduce its centralised part (the orchestrator), decentralised part (a domain) and the components that each of them make up.

The components are introduced in more detail in [their respective chapters](./components/overview.md) (see the sidebar to the left). Here, we just globally specify what they do to understand the overarching picture.

Finally, note that the discussion in this chapter is on the _current_ implementation, as given in the framework [repository](https://github.com/epi-project/brane). Future work is discussed in [its own series of chapters](../future/introduction.md), which is a recommended read for anyone trying to do things like bringing Brane in production.


## The task at hand
As described in the [Design requirements](../requirements/introduction.md), Brane is primarily designed for processing data pipelines in an HPC setting. In Brane, these data pipelines are expressed as _workflows_, which can be thought of as high-level descriptions of a program or process where individual _tasks_ are composed into a certain control flow, linking inputs and outputs together. Specific details, such as where a task is executed or exploiting parallelism, is then (optionally) left to the runtime (Brane, in this case) to deduce automatically.

A workflow is typically represented as a graph, where nodes indicate tasks and edges indicate some kind of dependency. For Brane, this dependency is data dependencies. An example of such a graph can be found in **Figure 1**.

![An example workflow graph](../assets/diagrams/Workflow.png)  
_**Figure 1**: An example workflow graph. The node indicate a particular function, where the arrows indicate how data flows through them (i.e., it specifies data dependencies). Some nodes (`i` in this example), may influence the control flow dynamically to introduce branches or loops._

At runtime, Brane will first _plan_ the workflow to resolve missing runtime information (e.g., which task is executed where). Then, it starts to traverse the workflow, executing each task as it encounters them until the end of the workflow is reached.

The tasks, in turn, can be defined separately as some kind of executable unit. For example, these may be executable files or containers that can be send to a domain and executed on their compute infrastructure. This split in being able to define workflows separately from tasks aligns well with Brane's objective of separating the concerns ([Assumption B3](../requirements/requirements.md#assumption-b3)) between the scientists and software engineers.


## A federated framework
![An overview of the orchestrator managing multiple domains](../assets/diagrams/Spider.png)  
_**Figure 2**: An overview of the framework services and how information flows between them. The Brane orchestrator communicates with domains to have them execute jobs or transfer data. Every domain can be thought of as one organisation, but not necessarily distinct (e.g., Hospital C has multiple domains)._

Brane is a federated framework, with a centralised orchestrator that manages the work that decentralised domains perform (see **Figure 2**). This orchestrator does so by sending _control messages_ to various domains, which encodes requests to perform a task on a certain data or exchange certain data with other domains. Importantly, these control messages only contain _data metadata_, which is assumed to be non-sensitive ([Assumption B5](../requirements/requirements.md#assumption-b5)); the actually sensitive contents of the data is only exchanged between domains when the domains decide to do so.

In this design, in accordance with [Requirement B1](../requirements/requirements.md#requirement-b1), Brane does not attempt to control the domains themselves. Instead, it defines the orchestrator and what kind of behaviour the domain should display if it's well-behaved. However, because of the autonomy of the domains, no guarantees can be made about whether the domains are _actually_ well-behaved; and as such, Brane is designed to allow well-behaving domains to deal with misbehaving domains.


## The components of Brane
To realise the structure explained above, Brane defines a number of conceptual _components_ which implement the services required for proper functionality. However, note that they are conceptual; multiple components may be implemented by a single physical service, or one component may be implemented by multiple physical services. The components merely highlight the aspects needed from every _node_, i.e., orchestrator and domains, in the system.

An overview of the components can be found in **Figure 3**.

![An overview of the components in Brane and how they interrelate](../assets/diagrams/Components.png)  
_**Figure 3**: An overview of Brane's components, separated in the central plane (the orchestrator) and the local plane (the domains). Each node represents a component, and each arrow some high-level interaction between them, where the direction indicates the main information flow. The annotation of the arrows give a hint as to what is exchanged and in what order. Finally, the colours of the nodes indicate a flexible notion of similarity._

### Central components
First, we introduce the components found in Brane's orchestrator. More details about each component can be found in their respective chapters.
{{#include ./snippets/central_services.md}}

In a nutshell, these components work together to translate a workflow into a series of events that can be executed by the domains. Crucially, the orchestrator never sees any data, but does make decisions about which domain gets assigned which tasks if the user does not specify this.

### Local components
Next, we introduce the components found on every Brane domain. Two types of components exist: Brane components and third-party components. For both of these, more details can be found in their respective chapters.

First, we list the Brane components:
{{#include ./snippets/worker_services_brane.md}}

The third-party components:
{{#include ./snippets/worker_services_tp.md}}

In a nutshell, the local components work together to execute or process events emitted by the central components. Crucially, these components _may_ see the data (especially the third-party components), and are managed fully by the owning domain. As such, they are also trusted to represent that domain's policies.


## Next
With the global picture in mind, you can now inspect more concrete design on the rest of the framework. You can start by learning more about each component and how they operate by selecting their respective chapter from the [Components](./components/overview.md)-chapters in the sidebar on the left.

Alternatively, you can also learn more about the [context of Brane](../requirements/introduction.md) or find out [details for implementing](../spec/introduction.md) (parts of) it yourself.

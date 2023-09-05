# Bird's-eye view
In this chapter, we provide a bird's-eye view of the framework. We introduce its centralised part (the orchestrator), decentralised part (a domain) and the components that each of them make up.

The components are introduced in more detail in [their respective chapters](./components/overview.md) (see the sidebar to the left). Here, we just globally specify what they do to understand the overarching picture.

Finally, note that the discussion in this chapter is on the _current_ implementation, as given in the framework [repository](https://github.com/epi-project/brane). Future work is discussed in [its own series of chapters](../future/introduction.md), which is a recommended read for anyone trying to do things like bringing Brane in production.


## A federated framework
![An overview of the orchestrator managing multiple domains](../assets/diagrams/Spider.png)
_**Figure 1**: An overview of the framework services and how information flows between them. The Brane orchestrator communicates with domains to have them execute jobs or transfer data. Every domain can be thought of as one organisation, but not necessarily distinct (e.g., Hospital C has multiple domains)._

Brane is a federated framework, with a centralised orchestrator that manages the work that decentralised domains perform (see **Figure 1**). Importantly, (potentially) sensitive data is never seen by the orchestrator itself; it only deals in metadata such that it can request the domains to perform the necessary transfers _if_ their policy allows.

A futher important part of this design is that Brane assumes the domains to be black boxes (up to a sense). Their implementation can be completely customised, because domains are need to have maximum autonomy ([Requirement B1](../requirements/requirements.md#requirement-b1)), 

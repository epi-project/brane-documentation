# Requirements
In this chapter, we will discuss what kind of requirements, goals and restrictions are expected from and imposed on the framework. Its goal is to explain why the framework is build up the way it is, and (for developers) get a feeling of what can be changeable about the framework and what not.

We will first very briefly talk about Brane's history, after which we will give a list of the requirements that are at the core of Brane's design. Then, we will move to smaller restrictions and constraints that add to the base list.


## Brane history
Originally, the Brane framework was just designed as an application orchestrator over multiple sites[1]. At this stage, the healthcare application was not yet in the picture, meaning that most of the work and design done in the framework is not yet done with strict policing of data in mind. This was only added as a strict requirement when Brane was re-used in the [EPI project](https://enablingpersonalizedinterventions.nl). While this does not mean that handling of sensitive data is compromised, it does help to understand the design decisions with this timeline in mind.


## Base requirements
We will now simply list the five base requirements of the Brane framework. An astute reader may note that these are a summary of the description of Brane on the [overview](../overview.md) page, so if you prefer a more textual approach, read that again.

The requirements:
1. The framework should be an abstraction on top of multiple compute sites, which are all different in capabilities and interface, to allow the user to use them as one site
2. The framework should be able to be used by three different roles: system engineers, who manage and implement the different compute sites; software engineers, who build the software used in research; and finally scientist, who design a workflow that will be used for research
3. The framework should be able to handle multiple workflows in parallel
4. The framework should be able to police user access and user handling of sensitive healthcare data according to set data-level policies
5. The framework should be able to handle sensistive healthcare data according to set network-level or system-level policies

These last two requirements require a little elaboration. The Brane framework is aimed at the Dutch healthcare system, which is really strict in protecting their patient's privacy. The idea of the Brane framework is that these policies are programmable, and so most of the policies are out-of-scope for this document. However, it is good to keep in mind what kind of policies might be implemented. The development of Brane is done with these kinds of policies in mind:
- Restrictions on where data may be processed (not on all compute sites)
- Restrictions on who may access or process data and who may see the processed results
- Restrictions may change over time, even while the framework is running a workflow


## Detailled requirements
With a list of possible challenges in mind, we can then add more detailled requirements that allow the framework to deal with the reality of the chosen base requirements:
<ol start="6">
    <li>The framework needs to support as many different sites as possible to truly function as proper middleware</li>
    <li>The framework needs to support three different ways to interact with it, where each way corresponds with one of the roles in the separation of concerns</li>
    <li>The framework needs to be scaleable to properly handle multiple workflows simultaneously</li>
    <li>The framework has to be able to properly authorize users</li>
    <li>The framework has to be able to perform its work in such a way that it will always adhere to the set policies (in other words, extra consideration is required to make sure it stays up-to-date of policies and checks for policy changes)</li>
    <li>The framework will have to understand the workflows in detail to understand what is happening to sensitive data</li>
    <li>The framework has to assume that different compute sites (which are probably hosted on different hospitals) don't automatically trust each other and have different policies</li>
    <li>The framework has to be able to establish safe connections between sites to transfer data or results securely</li>
</ol>


In the [next chapter](./framework-capabilities.md), we will discuss what kind of concrete features the framework should have to implement these requirements.

-------------------
#### References
[1] O. Valkering, R. Cushing and A. Belloum, "Brane: A Framework for Programmable Orchestration of Multi-Site Applications," 2021 IEEE 17th International Conference on eScience (eScience), 2021, pp. 277-282, doi: 10.1109/eScience51609.2021.00056.

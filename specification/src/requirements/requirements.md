# Requirements
In the [first](./background.md)- and [second](./use_case.md) chapters in this series, we defined the context and use cases for which Brane was designed. With this in mind, we can now enumerate a set of requirements and assumptions that Brane has to satisfy.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 2px; margin-bottom: -2px"/> The assumptions defined in this chapter may be referred to later by their number; for example, you may see
> ```plaintext
> This is because ... (Assumption A2)
> ```
> or
> ```plaintext
> This is a consequence of ... (Requirement B1)
> ```
> 
> used in other chapters in this book to refer to assumptions and requirements defined here, respectively.


## Usage in High-Performance Computing (HPC)
Brane's original intended purpose was to homogenise access to various compute clusters and pool their resources. Moreover, the original project focused on acknowledging the wide range of knowledge required to do HPC and streamline this process for all parties involved. As such, it is a framework that is intended to do heavy-duty work on large datasets with a clean separation of concerns.

First, we specify more concretely what kind of work Brane is intended to perform:
> #### Assumption A1
> HPC nowadays mostly deals with data processing pipelines, and as such Brane must be able to process these kind of pipelines (described by _workflows_).

However, as the data pipelines increase in complexity and required capacity, it becomes more and more complex to design and execute the workflows representing these pipelines. It is assumed that this work can be divided into the following concerns:
> #### Assumption A2
> To design and execute a data pipeline, expertise is needed from a _(system) administrator_, to manage the compute resources; a _(software) engineer_, to implement the required algorithms; and a _(domain) scientist_, to design the high-level workflow and analyse the results.

Tied to this, we state the following requirement on Brane:
> #### Requirement A1
> Brane must be easy-to-use and familiar to each of the roles representing the various concerns.

This leads to the natural follow-up requirement:
> #### Requirement A2
> To fascilitate a clear separation of concerns, the roles must be able to focus on their own aspects of the workflow; Brane has the burden to bring everything together.

[Requirement A2](#requirement-A2) reveals the main objective of the Brane framework as HPC middleware: provide intuitive interfaces for all the various roles (the frontend) and combine their efforts into the execution of a workflow on various compute clusters (the backend).

Further, due to the nature of HPC, we can require that:
> #### Requirement A3
> Brane must be able to handle high-capacity workflows that require large amounts of compute power and/or process large amounts of data.

Finally, we can realise that:
> #### Assumption A3
> HPC covers a wide variety of topics and therefore use-cases.

Thus, to make Brane general, it must be very flexible:
> #### Requirement A4
> Brane must be flexible: it must support many different, possibly use-case dependent frontends and as many different backends as possible.

To realise the last requirement, we design Brane as a loosely-coupled framework, where we can define frontends and backends in isolation as long as they adhere to the common specification.


## Usage in healthcare
In addition to the general HPC requirements presented in the [previous section](#usage-in-high-performance-computing-hpc), Brane is adapted for usage in the medical domain (see [background](./background.md)). This introduces new assumptions and requirements that influence the main design of Brane, which we discuss in this section.

Most importantly, the shift to the medical domain introduces a heterogeneity in data access. Specifically, we assume that:
> #### Assumption B1
> Organisations often maximise control over their data and minimize their peers' access to their data.

This is motivated by the often highly-sensitive nature of medical data, combined with the responsibilities of the organisations owning that data to keep it private. Thus, the organisations will want to stay in control and are typically conservative in sharing it with other domains.

From this, we can formulate the following requirement for Brane:
> #### Requirement B1
> Domains must be as autonomous as possible; concretely, they cannot be forced by the orchestrator or other domains (not) to act.

To this end, the role of the Brane orchestrator is weakened from _instructing_ what domains do to instead _requesting_ what domains do. Put differently, the orchestrator now merely acts as an intermediary trying to get everyone to work together and share data; but the final decision should remain with the domains themselves.

In addition to maximising autonomy, recent laws such as GDPR [\[1\]](#references) open the possibility that rules governing data (e.g., institutional policies) may be privacy-sensitive themselves. For example, Article 17.2 of the GDPR states that "personal data shall, with the exception of storage, only be processed with the data subject's consent". However, if this consent is given for data with a public yet sensitive topic (e.g., data about the treatment of a disease), then it can easily be deduced that the data subject's consent means that the patient suffers from that disease.

This leads to the following assumption:
> #### Assumption B2
> Rules governing data access may be privacy-sensitive, or may require privacy-sensitive information to be resolved.

This prompts the following design requirement:
> #### Requirement B2
> The decision process to give another domain access to a particular domain's data must be kept as private as possible.

Note, however, that by nature of these rules it is impossible to keep them fully private. After all, there is exist attacks to reconstruct the state of a state machine by observing its behaviour [\[2\]](#references); which means that enforcing the decision process necessarily offers opportunity for any attacker to discover them. However, Brane can give _opportunity_ for domains to hide their access control rules by implementing an indirection between the internal behaviour of the decision process and an outward interface (see [\[3\]](#references) for more information).

Because it becomes important to specify the rules governing data access properly and correctly, we can extend [Assumption A2](#assumption-a2) to include a fourth role (the extension is emphasised):
> #### Assumption B3
> To design and execute a data pipeline, expertise is needed from a _(system) administrator_, to manage the compute resources; **a _policy expert_, to design and implement the data access restrictions;** a _(software) engineer_, to implement the required algorithms; and a _(domain) scientist_, to design the high-level workflow and analyse the results.

Finally, for practical purposes, though, the following two assumptions are made that allow us a bit more freedom in the implementation:
> #### Assumption B4
> A domain always adheres to its own data access rules.

(i.e., domains will act rationally and to their own intentions); and

> #### Assumption B5
> Whether data is present on a domain, as well as data metadata, is non-sensitive information.

(i.e., the fact that someone has a particular dataset is non-sensitive; we only consider the access control rules to that data and its contents as potentially sensitive information).


## Next
In this chapter, we presented the assumptions and requirements that motivate and explain Brane. This builds upon the general [context](./background.md) and [use-cases](./use_case.md) of Brane, and serves as a background for understanding the framework.

Next, you can start examining the design in the [Brane design](../design/introduction.md) chapter series. Alternatively, you can also skip ahead to the [Framework specifiction](../spec/introduction.md) if you are more implementation-oriented.

Alternatively, you can also visit the [Appendix](../appendix/overview.md) to learn more about the tools surrounding Brane.


## References
[1] European Commission, _Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016 on the protection of natural persons with regard to the processing of personal data and on the free movement of such data, and repealing Directive 95/46/EC (General Data Protection Regulation) (Text with EEA relevance)_ (2016).

[2] F. W. Vaandrager, B. Garhewal, J. Rot, T. Wiẞmann, _A new approach for active automata learning based on apartness_, in: D. Fisman, G. Rosu (Eds.), Tools and Algorithms for the Construction and Analysis of Systems - 28th International Conference, TACAS 2022, Held as Part of the European Joint Conferences on Theory and Practice of Software, ETAPS 2022, Munich, Germany, April 2-7, 2022, Proceedings, Part I, Vol. 13243 of Lecture Notes in Computer Science, Springer, 2022, pp. 223–243. doi:[10.1007/978-3-030-99524-9_12](http://dx.doi.org/10.1007/978-3-030-99524-9_12). URL <http://dx.doi.org/10.1007/978-3-030-99524-9_12>

[3] C. A. Esterhuyse, T. Müller, L. T. van Binsbergen and A. S. Z. Belloum, _Exploring the enforcement of private, dynamic policies on medical workflow execution_, in: 18th IEEE International Conference on e-Science, e-Science 2022, Salt Lake City, UT, USA, October 11-14, 2022, IEEE, 2022, pp. 481-486

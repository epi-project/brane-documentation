# Requirements
In the [first](./background.md)- and [second](./use_case.md) chapters in this series, we defined the context and use cases for which Brane was designed. With this in mind, we can now enumerate a set of requirements and assumptions that Brane has to satisfy.

> <img src="../assets/img/info.png" alt="info" width="16" style="margin-top: 2px; margin-bottom: -2px"/> The assumptions defined in this chapter may be referred to later by their number; for example, you may see
> ```
> This is because ... (Assumption 1)
> ```
> or
> ```
> This is a consequence of ... (Requirement 1)
> ```
> 
> used in other chapters in this book to refer to assumptions and requirements defined here, respectively.


## Usage in High-Performance Computing (HPC)
Brane's original intended purpose was to homogenise access to various compute clusters and pool their resources. Moreover, the original project focused on acknowledging the wide range of knowledge required to do HPC and streamline this process for all parties involved. As such, it is a framework that is intended to do heavy-duty work on large datasets with a clean separation of concerns.



Due to this legacy, we can define a few requirements on the framework:
> #### Requirement 1
> 


## Usage in healthcare
As discussed in the [background](./background.md) chapter, Brane is adapted for usage in the medical domain. Immediately, this reveals a design constraint that is inherent to the fact that healthcare deals with a lot of sensitive data, and that the organisations working with that data are responsible for keeping that data secure; as such, we can define that;

> #### Assumption 1
> Organisations often maximise control over their data and minimize their peers' access to their data.

As such, a strong requirement of the Brane framework is:

> #### Requirement 1
> Domains must be as autonomous as possible; concretely, they cannot be forced by the orchestrator or other domains (not) to act.

Further, in light of recent laws such as GDPR [\[2\]](#references), it may be that rules governing data (e.g., institutional policies) may be privacy-sensitive themselves; for example, Article 17.2 of the GDPR states that "personal data shall, with the exception of storage, only be processed with the data subject's consent"; so the fact that a particular patient has given consent to the processing of a particular dataset may already indicate that patient has the disease recorded in that data. Or, framed as an assumption:

> #### Assumption 2
> Rules governing data access may be privacy-sensitive, or may require privacy-sensitive information to be resolved.

This prompts the following design requirement:

> #### Requirement 2
> The access control rules specified in Brane must be kept private to maximum extend.

Note, however, that by nature of these rules it is impossible to keep them fully private. After all, there is exist attacks to reconstruct the state of a state machine by observing its behaviour [\[3\]](#references); which means that enforcing the access control rules necessarily offers opportunity for any attacker to discover them. However, Brane can give _opportunity_ for domains to hide their access control rules.

Finally, for practical purposes, though, the following two assumptions are made that allow us a bit more freedom in the implementation:
> #### Assumption 3
> A domain always adheres to its own data access rules.

(i.e., domains will act rationally and to their own intentions)

> #### Assumption 4
> Whether data is present on a domain, as well as data metadata, is non-sensitive information.

(i.e., the fact that someone has a particular dataset is non-sensitive; we only consider the access control rules to that data and its contents as potentially sensitive information)


## References
[2] European Commission, _Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016 on the protection of natural persons with regard to the processing of personal data and on the free movement of such data, and repealing Directive 95/46/EC (General Data Protection Regulation) (Text with EEA relevance)_ (2016).

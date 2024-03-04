# Introduction
Welcome to the series of chapters detailing the policy expert role!

These chapters will discuss everything needed to successfully play this role, including technical knowledge, setup, and considerations when writing policy for Brane.

This chapter will first briefly outline the role as a whole. Then, the [next](#next)-section gives pointers on where to start.


## Policy experts
The role of a policy expert within Brane is to understand the restrictions and regulations that apply to compute infrastructure and datasets managed by a domain, and then to translate those into _computable policy_. By this we mean some kind of representation -e.g., declarative rules- that represent these regulations and that can be used by the system to automatically give access to users or not.

Policy experts walk the line between management and technology. They both need to understand the legal- and business side of sharing data and the technology in order to map from the first to the second successfully. Moreover, they need to be careful in how they design their reasoner in what information it divulges, as any policy information may be sensitive one way or another (e.g., private domain internal regulations, patient consent, etc).

In order to make this process as easy as possible, Brane allows domains to choose their own policy language, as long as this translates to either an allow/deny at the end of evaluation[^except]. Currently, Brane uses [eFLINT](https://gitlab.com/eflint) as the default language, but see the [custom reasoning backend](./backend/introduction.md) chapters for more information on how to implement custom languages.


[^except]: Eventually, Brane will support a system where (parts of) policy are shared with other domains to drastically increase efficiency. For now, though, this is future work.


## Next
To start learning about how to be a policy expert for Brane, start by [installing the required tooling](./installation.md). Then, depending on whether your administrator asks you to use eFLINT or another language, either check the [eFLINT introduction chapters](./eflint/introduction.md), or documentation for the language implemented by your administrator. Additionally, you can check the docs for [implementing a custom reasoning backend](./backend/introduction.md) if more customization is needed.

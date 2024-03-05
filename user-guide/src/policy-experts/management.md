# Managing policies
This chapter discusses how you can manage the policies in a running policy reasoner.

The first section focusses on obtaining access keys from your adminsitrator. Then, we discuss either managing the checker using the [visual interface](#visual-management-policy-reasoner-gui) or using the [terminal interface](#terminal-management-branectl).


## Acquiring keys
Before you begin, you need to have access to the reasoner in question. This is currently implemented as two JSON Web Tokens (JWTs): one is used to access the _deliberation API_ of the checker, which is where Brane connects to check workflows; and the other is used to access the _policy expert API_ of the checker, which is used to manage which policies are active. For full convenience, you should try to acquire both so you can test the checker yourself.

If your adminstrator is unsure how to do this (or you are the administrator), consult the [relevant section](../system-admins/installation/worker-node.md#writing-policies) of their part of the wiki.


## Visual management (Policy Reasoner GUI)


## Terminal management (`branectl`)


## Next

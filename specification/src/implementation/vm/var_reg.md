# Variable register
In the [previous chapter](./stack.md), we introduced the expression stack as a scratchpad memory for computing expressions as a thread of the VM executes a workflow. However, this isn't always suitable for all purposes. Most notably, the stack only allows operations on the top values; this means that if we want to re-use arbitrary values from before, this cannot be represented by the stack alone.

To this end, a _variable register_ is implemented in the VM that can be used to temporarily store values on another location outside of the stack altogether. Then, the values in these variables can be pushed to the stack whenever they're required.


## Implementation
The variable register is implemented as an unordered map of variable identifiers (not names, but indices in the [definition table](../../spec/wir/schema.md#the-symtable)) to [values](./stack.md#values-and-fullvalues). As such, values in variables are statically typed, i.e., every variable can only ever have one type.




## Next
> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 2px; margin-bottom: -2px"/> This section will be written soon.

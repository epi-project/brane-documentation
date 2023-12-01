# Bringing it together
In the previous few chapters, various components of the VM have been discussed that together make up the VM's state. To showcase how this state is used, this section emulates the run of a VM to see how a particular program is processed and changes the state.

The workflow that we will execute can be examined [here](./showcase_appendix.md). A recommended way to read this chapter is to familiarize yourself with the workflow first (in any of the three representations), and then read the example below. You can open the workflow in a separate tab to refer to it, if you wish.


## Example
The execution of the workflow is described in three parts: first, we will examine the [initial state](#initial-state) of the VM; then, we emulate one of the [function calls](#function-call) in the workflow; after which we do the remainder of the workflow in more high-level and examine the [result](#result).

### Initial state
The state of the VM is expressed in four parts:
1. The program counter, which points to the next edge/instruction to execute;
2. The [expression stack](./stack.md);
3. The [variable register](./var_reg.md); and
4. The [frame stack](./frame_stack.md).

Throughout the example, we will display the state of these components as they get updated. For example, this is the VM's state at start:
> **Program counter**
> ```json
> // We give the program counter as a triplet of (<func>, <edge>, <instr_or_null>)
> // Remember that `MAX` typically refers to `<main>`
> // Points to the first instruction in the first Linear edge in `<main>`
> (MAX, 0, 0)
> ```
> **Expression stack**
> ```json
> // The expression stack is given as a list of values (empty for now)
> [
> ]
> ```
> **Variable register**
> ```json
> // The variable register is given as a map of variable names to the contents
> // for that variable (empty for now)
> {
> }
> ```
> **Frame stack**
> ```json
> // The frame stack is given as a list of frames
> [
>     // Every frame is: function, variables (as name, type), return address
>     {
>         // Remember that `MAX` typically refers to `<main>`
>         "func": MAX,          
>         // Lists all variables declared in this function's body
>         "vars": [
>              ("zeroes", "IntermediateResult"),
>              ("ones", "IntermediateResult"),
>         ],
>         // See 'Program counter', or null for when there is no return address
>         "pc": null
>     }
> ]
> ```

Most state is empty, except for the program counter, which points to the first edge in the first function; and the frame stack, which contains the root call made by the VM to initialize everything.


### Function call
If we examine the workflow, the first edge we encounter is a [Linear edge](../../spec/wir/graph.md#linear). This contains multiple instructions, and so the VM will execute these first.

1. The first instruction is to declare the `zeroes`-variable ([`.dec`](../../spec/wir/instructions.md#vardec)). As such, this creates an entry for it in the variable register:
   > **Variable register**
   > ```json
   > {
   >     // The entry for the `zeroes`-variable.
   >     4: {
   >         "name": "zeroes",
   >         "type": "IntermediateResult",
   >         "val": null
   >     }
   > }
   > ```
   (Refer to the workflow table in [Listing 2](./showcase_appendix.md) to map IDs to variables)
   
   The variable is declared (part of the register) but not initialized (`val` is `null`).
   
   After execution, the program counter is updated to:
   > **Program counter**
   > ```json
   > (MAX, 0, 1)    // Note the bump in the instruction!
   > ```
   and the next instruction is executed.

2. 


### Result


## Next
> <img src="../../assets/img/info.png" alt="info" width="16" style="margin-top: 2px; margin-bottom: -2px"/> This section will be written soon.

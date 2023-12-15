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

Note that every step has an implicit update to the program counter at the end. For example, step 1.1 ends with:
> **Program counter**
> ```json
> (MAX, 0, 1)    // Note the bump in the instruction!
> ```
and step 1 as a whole ends with:
> **Program counter**
> ```json
> (MAX, 1, 0)    // Note the bump in the edge!
> ```

We will only note it when changes to typical bumping happen (e.g., function call).

1. [`Linear`](../../spec/wir/graph.md#linear)-edge: To process a linear edge, the instructions within are executed.
    1. [`.dec zeroes`](../../spec/wir/instructions.md#vardec): The first instruction is to declare the `zeroes`-variable, as the start of the function (in this case, `<main>`). As such, this creates an entry for it in the variable register:
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
    
    2. [`.int 3`](../../spec/wir/instructions.md#integer): Next, we begin by computing the argument to the first function calls, which is `3 + 3`. As such, the next instruction pushes a `3` integer constant to the expression stack. The stack looks as follows after executing it:
       > **Expression stack**
       > ```json
       > [
       >     {
       >         // The data type of this entry on the stack.
       >         "dtype": "int",
       >         // The integer value stored.
       >         "value": 3,
       >     }
       > ]
       > ```

    3. [`.int 3`](../../spec/wir/instructions.md#integer): Another integer constant is pushed (`3` again). The stack looks as follows after executing it:
       > **Expression stack**
       > ```json
       > [
       >     // The new entry (so we reversed the order of the list)
       >     {
       >         "dtype": "int",
       >         "value": 3,
       >     },
       >     {
       >         "dtype": "int",
       >         "value": 3,
       >     }
       > ]
       > ```

    4. [`.add`](../../spec/wir/instructions.md#add): We perform the addition to complete the expression `3 + 3` in the workflow. This pops the top two values, adds them, and pushes the result to the stack. Therefore, this is the expression stack after the addition has been performed:
       > **Expression stack**
       > ```json
       > [
       >     // We've just done `3 + 3` :)
       >     {
       >         "dtype": "int",
       >         "value": 6,
       >     }
       > ]
       > ```

    5. [`.func generate_dataset`](../../spec/wir/instructions.md#function): With the arguments to the function call prepared on the stack, the next step is to push what we will be calling. As such, the top of the stack will be a pointer to the function that will be executed.
       > **Expression stack**
       > ```json
       > [
       >     {
       >         "dtype": "function",
       >         // Note that the function is represented by its identifier
       >         "def": 4,
       >     },
       >     {
       >         "dtype": "int",
       >         "value": 6,
       >     }
       > ]
       > ```
       Now, we are ready for a function call. However, since this control flow deviation must be visible to checkers who want to validate the workflow, this is represented at the Edge-level. The next thing to execute is thus a next edge.

2. [`Call`](../../spec/wir/graph.md#call)-edge: The Call will first pop the function pointer from the stack and resolves it to a function definition in the workflow's [definition table](../../spec/wir/schema.md#the-symtable). In this case, it will check function `4` and see that it's `generate_dataset`. Based on its signature, it knows that the top of the stack must contains a value of `Any` type; and as such, it will assert this is the case. This means that the expression stack looks like:
   > **Expression stack**
   > ```json
   > [
   >     // Only the pointer is popped; the arguments are for the function to figure out
   >     {
   >         "dtype": "int",
   >         "value": 6,
   >     }
   > ]
   > ```
   Next, a new frame is pushed to the frame stack that allows us to handle any [`Return`](../../spec/wir/graph.md#return)-edges appropriately:
   > **Frame stack**
   > ```json
   > [
   >     {
   >         // We're calling function 4 (generate_dataset)...
   >         "func": 4,
   >         // ...which will declare the variables `n`
   >         "vars": [
   >              ("n", "Any"),
   >         ],
   >         // ...and return to the next Edge after the call (the second Linear in `<main>`)
   >         "pc": (MAX, 2, 0)
   >     },
   >     {
   >         "func": MAX,
   >         "vars": [
   >              ("zeroes", "IntermediateResult"),
   >              ("ones", "IntermediateResult"),
   >         ],
   >         "pc": null
   >     }
   > ]
   > ```
   Once the expression stack and frame stack check out, the call is performed; this is done by changing the program counter to point to the called function:
   > **Program counter**
   > ```json
   > (4, 0, 0)    // First Edge, first instruction in function 4 (generate_dataset)
   > ```
   This means that the next edge executed is no longer the next one in the main function body, but rather the first one in the called function's body.


### Function body
Next, the function body of the `generate_dataset` function (i.e., function 4) is executed by the VM.

3. [`Linear`](../../spec/wir/graph.md#linear)-edge:
   1. [`.dec n`](../../spec/wir/instructions.md#vardec): The first step when the function body is entered is to map the arguments on the stack to named variables. To do that, the variable has to be declared first; and that's what happens here.  
   The variable register after declaration:
      > **Variable register**
      > ```json
      > {
      >     // The entry for the `n`-variable.
      >     0: {
      >         "name": "n",
      >         "type": "Any",
      >         // Still uninitialized
      >         "val": null
      >     },
      >     4: {
      >         "name": "zeroes",
      >         "type": "IntermediateResult",
      >         "val": null
      >     }
      > }
      > ```

   2. [`.set n`](../../spec/wir/instructions.md#varset): With the variable declared, we can pop the top value off the expression stack and move it to the variable's slot in the variable register.  
   The expression stack is empty after performing the `.set`:
      > **Expression stack**
      > ```json
      > [
      > ]
      > ```
      and instead, the value is now assigned to `n`:
      > **Variable register**
      > ```json
      > {
      >     // The entry for the `n`-variable.
      >     0: {
      >         "name": "n",
      >         // Because it was `Any`, the type of `n` has been set in stone now
      >         "type": "int",
      >         "val": 6
      >     },
      >     4: {
      >         "name": "zeroes",
      >         "type": "IntermediateResult",
      >         "val": null
      >     }
      > }
      > ```

   3. [`.get n`](../../spec/wir/instructions.md#varget): After storing the arguments, the function call needs to be prepared now (which is a call to `zeroes`, using a number and a string). A disadvantage of the push/pop model is that, even if the value was just on top of the stack, we removed it to move it to the variable register. Therefore, we need to add it again to use in the next function call:
      > **Expression stack**
      > ```json
      > [
      >     {
      >         "dtype": "int",
      >         "value": 6,
      >     }
      > ]
      > ```
      Note that the variable register is actually not edited, as `.get`s perform copies.

   4. [`.cast Integer`](../../spec/wir/instructions.md#cast): Before moving to the next argument of the call, a cast is used by the compiler to have the VM assert the current value on the stack is convertible to the required integer. In addition, if the user uses a type trivially convertible to integers (e.g., booleans), then this cast steps is where this conversion happens.  
   However, as the value was already an integer, nothing changes and the VM continues.

   5. [`.str "vector"`](../../spec/wir/instructions.md#string): For the second argument to the function call, a string constant is used. This is pushed with this instruction.
      > **Expression stack**
      > ```json
      > [
      >     {
      >         "dtype": "string",
      >         "value": "vector",
      >     },
      >     {
      >         "dtype": "int",
      >         "value": 6,
      >     }
      > ]
      > ```

4. [`Node`](../../spec/wir/graph.md#node)-edge: Now it's time to perform the call to `zeroes`. However, since `zeroes` is actually an external function instead of a BraneScript function, the VM cannot simply change program counters and continue execution. Instead, it will use its [plugins](./introduction.md#vm-with-plugins) to execute the node on whatever backend necessary.  
   To do so, first the arguments to the external function are popped from the expression stack:
   > **Expression stack**
   > ```json
   > [
   >     // They're being processed now
   > ]
   The VM will then perform the call using the information supplied in the `Node` and the values supplied by the function arguments. This process is described in [TODO](TODO).  
   When the execution completes, the result is pushed onto the stack:
   > **Expression stack**
   > ```json
   > [
   >     // The result is a reference to a created dataset
   >     {
   >         "dtype": "IntermediateResult",
   >         // This ID is randomly generated by the compiler
   >         "value": "result_foo",
   >     }
   > ]
   Then, execution of the graph continues as normal, as if the call returned immediately.

5. [`Return`](../../spec/wir/graph.md#return)-edge: After the task has been processed, the `generate_dataset` function completes.  
   When a Return-edge is executed, it first pops the current frame from the frame stack to examine what to do next:
   > **Frame stack**
   > ```json
   > [
   >     // Only the main frame remains
   >     {
   >         "func": MAX,
   >         "vars": [
   >              ("zeroes", "IntermediateResult"),
   >              ("ones", "IntermediateResult"),
   >         ],
   >         "pc": null
   >     }
   > ]
   > ```
   Based on this, the VM now first removes the variables from the variable register that were local to this function:
   > **Variable register**
   > ```json
   > {
   >     // Variable `n` is gone now...
   >     4: {
   >         "name": "zeroes",
   >         "type": "IntermediateResult",
   >         "val": null
   >     }
   > }
   > ```
   Then, based on the definition of the called function, the VM examines if a value needs to be returned. If so, the expression stack is verified to see if this is indeed what is on top of the stack; and in this case, it will see that this is so.  
   The VM is now ready to jump back to the next edge in `<main>`, and thus updates the program counter accordingly:
   > **Program counter**
   > ```json
   > (MAX, 2, 0)    // Points back into `<main>`, to the second `Linear`
   > ```
   and then it executes the program from there onwards.


### More calls
6. [`Linear`](../../spec/wir/graph.md#return)-edge: In the next edge in `<main>`, the embedded instructions make two things happen:
   1. The result of the call to `generate_dataset` is stored in `zeroes` ([`.set zeroes`](../../spec/wir/instructions.md#varset)); and
   2. The arguments to the next call (`add_const_to(2, zeroes)`) are being prepared. This is done by first pushing the constant `2`, and then extending that with the value currently in `zeroes`.

   After everything is processed, the variable register and expression stack look like:
   > **Variable register**
   > ```json
   > {
   >     // Zeroes has been given a value
   >     4: {
   >         "name": "zeroes",
   >         "type": "IntermediateResult",
   >         "val": "result_foo"
   >     },
   >     // `ones` has been declared but uninitialized
   >     5: {
   >         "name": "ones",
   >         "type": "IntermediateResult",
   >         "val": null
   >     }
   > }
   > ```
   > **Expression stack**
   > ```json
   > [
   >     // The stack now contains the arguments (first at the bottom), then the function pointer to call
   >     {
   >         "dtype": "function",
   >         "value": 5
   >     },
   >     {
   >         "dtype": "IntermediateResult",
   >         "value": "result_foo"
   >     },
   >     {
   >         "dtype": "int",
   >         "value": 2
   >     },
   > ]

7. [`Call`](../../spec/wir/graph.md#call)-edge: The `add_const_to` function is called, exactly like the previous function. We won't repeat the full call here, but instead just continue after the call returned.
   > **Expression stack**
   > ```json
   > [
   >     // The reference to the next result is on the stack, produced by `add_const`.
   >     {
   >         "dtype": "IntermediateResult",
   >         "value": "result_bar"
   >     }
   > ]

8. [`Linear`](../../spec/wir/graph.md#return)-edge: The final call is being prepared in this Edge. This simply relates to storing the result of the previous call, and then calling `cat_data` on it.
   > **Variable register**
   > ```json
   > {
   >     4: {
   >         "name": "zeroes",
   >         "type": "IntermediateResult",
   >         "val": "result_foo"
   >     },
   >     // `ones` has been updated with the result of the `add_const_to` call
   >     5: {
   >         "name": "ones",
   >         "type": "IntermediateResult",
   >         "val": "result_bar"
   >     }
   > }
   > ```
   > **Expression stack**
   > ```json
   > [
   >     // The function to call and then the argument to call it with
   >     {
   >         "dtype": "function",
   >         "value": 6
   >     },
   >     {
   >         "dtype": "IntermediateResult",
   >         "value": "result_bar"
   >     }
   > ]

9. [`Call`](../../spec/wir/graph.md#call)-edge: The call to `cat_data` is processed as normal, except that a special call happens inside of it; after the `cat`-task has been processed, its result is `println`ed, which is a builtin function. This function makes the VM pop a value, and then print that to the stdout (or something similar) appropriate to the environment the VM is being executed in using one of its [plugins](./introduction.md#vm-with-plugins). This means that it's not a full call using program counter jumps, but instead processing that happens in the Call itself.  
   Since `cat_data` itself does not return, the final state change of the program is that the expression stack is now empty:
   > **Expression stack**
   > ```json
   > [
   >     // All values have been popped
   > ]


### Result
10. [`Stop`](../../spec/wir/graph.md#stop)-edge: When this edge is reached, the VM quits and cleans up. This latter part is done implicitly by unallocating all of its resources.

This concludes the execution of our workflow, which has produced the output of the dataset on stdout. Any intermediate results will now be destroyed, and the entity managing the VM can do other stuff again.


## Next
That concludes the chapters on the VM!

The next step could be examining how tasks are being executed on the rest of the Brane system (see the [TODO](todo)-chapter). Alternatively, you can also learn more about [BraneScript](../../appendix/languages/bscript/introduction.md) by going to the Appendix. Or you can select any other topic in the sidebar on the left.

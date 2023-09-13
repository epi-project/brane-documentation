# Toplevel schema
In this chapter, we will discuss specification for the toplevel part of the WIR. Its sub-parts, the [graph representation](./graph.md) and [edge instructions](./instructions.md), are discussed in subsequent chapters.

Regardless of which you read, we will start by stating a few [conventions](#conventions) for how to read the specification. Then, this chapter will continue with the toplevel schema.


## Conventions
For clarity, we specify the WIR as [JSON](https://json.org). To refer to JSON types, we will use the terminology from the [JSON Schema](https://json-schema.org/draft/2020-12/json-schema-core.html) specification.

Note that the JSON representation of the WIR is implemented directly as Rust structs in the [reference implementation](https://github.com/epi-project/brane). You can refer to the `brane_ast`-crate and then `ast`-module in the [code documentation](https://wiki.enablingpersonalizedinterventions.nl/docs/src/brane_ast/ast.rs.html) to find the full representation.

Finally, the use of the name `Edge` throughout this document is indeed unfortunately chosen, as it represents more than edges. However, it is chosen to keep in sync with the implementation itself.


## The Workflow
The toplevel structure in the WIR is the `Workflow`, which contains everything about the workflow it defines.

The workflow is a JSON Object, and contains the following fields:
- `table` ([`SymTable`](#the-symtable)): States the definitions of all toplevel functions, tasks, classes and variables. These definitions mostly contain information for type resolving; it does not contain function bodies. All definitions are mapped by identifier referred to in the graph.
- `graph` (Array\<[`Edge`](TODO)\>): A list of [`Edge`](TODO)s that defines the toplevel workflow. This is comparable to the `main`-function in C, and contains the edges executed first. The indices of the elements in this array are used as identifiers for the instructions.
- `funcs` (Object\<number, Array\<[`Edge`](TODO)\>\>): A map of function identifiers to nested arrays of [`Edge`](TODO)s. These can be called by the edges in the main `graph` -or function bodies- to execute a particular snippet. The indices of the elements in the arrays are used as identifiers for the instructions.

Example `Workflow`:
```json
TODO
```


## The SymTable
The `SymTable` defines one of the fields of the toplevel `Workflow`, and contains information about the definitions used in the workflow. In particular, it gives type information for functions, classes and variables, and states what we need to know to perform an external task call for tasks. Finally, it also defines on which location particular intermediate results of a workflow may find themselves.

The following fields are present in a JSON Object representing a `SymTable`:
- `funcs` ([`TableList`](#the-tablelist)\<[`FunctionDef`](#the-functiondef)\>): A list of [`FunctionDef`](#the-functiondef)s that provide type information for a particular function. The indices of the elements in this array are used as identifiers for the definitions.
- `tasks` ([`TableList`](#the-tablelist)\<[`TaskDef`](#the-taskdef)\>): A list of [`TaskDef`](#the-taskdef)s that provide information of tasks that we might execute. The indices of the elements in this array are used as identifiers for the definitions.
- `classes` ([`TableList`](#the-tablelist)\<[`ClassDef`](#the-classdef)\>): A list of [`ClassDef`](#the-classdef)s that provide information of tasks that we might execute. The indices of the elements in this array are used as identifiers for the definitions.
- `vars` ([`TableList`](#the-tablelist)\<[`VarDef`](#the-vardef)\>): A list of [`VarDef`](#the-vardef)s that provide information of tasks that we might execute. The indices of the elements in this array are used as identifiers for the definitions.
- `results` (Object\<string, string\>): A map of identifiers of intermediate results to location names. This can be used by the planner or by checkers as a shortcut to find where the input of a particular task is coming from.

Example `SymTable`:
```json
// An empty symbol table
{
    "funcs": { "d": [], "o": 0 },
    "tasks": { "d": [], "o": 0 },
    "classes": { "d": [], "o": 0 },
    "vars": { "d": [], "o": 0 },
    "results": {},
}
```
```json
// A table with some definitions
{
    "funcs": { "d": [], "o": 0 },
    "tasks": {
        "d": [{
            "kind": "cmp",
            "p": "foo_package",
            "v": "1.0.0",
            "d": {
                "n": "foo",
                "a": [],
                "r": { "kind": "void" },
                "t": {
                    "funcs": { "d": [], "o": 0 },
                    "tasks": { "d": [], "o": 0 },
                    "classes": { "d": [], "o": 0 },
                    "vars": { "d": [], "o": 0 },
                    "results": {},
                }
            },
            "a": [],
            "r": { "kind": "void" }
        }],
        "o": 0
    },
    "classes": { "d": [], "o": 0 },
    "vars": {
        "d": [
            { "n": "foo", "t": { "kind": "str" } },
            { "n": "bar", "t": { "kind": "int" } }
        ],
        "o": 0
    },
    "results": {},
}
```
```json
// A table with some result locations
{
    "funcs": { "d": [], "o": 0 },
    "tasks": { "d": [], "o": 0 },
    "classes": { "d": [], "o": 0 },
    "vars": { "d": [], "o": 0 },
    "results": {
        "result_123": "hospital_a",
        "result_456": "clinic_b",
    },
}
```

### The TableList
_Generic parameter `T`_

The `TableList` is a special kind of schema that defines a list with a particular offset. This is used to create a consistent scope of definitions, since one `TableList` can simply extend, or overlay parts of, another.

These fields are part of a `TableList`:
- `d` (Array<`T`>): An array of `T`s, which are the definitions contained within this TableList.
- `o` (number): The offset of this TableList in the parent list. This determines if this list simply extends or shadows part of the parent list. `0` implies it's the toplevel list.

For example, this defines a `TableList` over one `FunctionDef` without any offset:
```json
{
    "d": [{
        "n": "foo",
        "a": [],
        "r": "void",
        "t": {
            "funcs": { "d": [], "o": 0 },
            "tasks": { "d": [], "o": 0 },
            "classes": { "d": [], "o": 0 },
            "vars": { "d": [], "o": 0 },
            "results": {},
        }
    }],
    "o": 0
}
```
Or a `TableList` with multiple `VarDef`s and an offset:
```json
{
    "d": [
        {
            "n": "foo",
            "t": { "kind": "str" }
        },
        {
            "n": "bar",
            "t": { "kind": "real" }
        },
        {
            "n": "baz",
            "t": { "kind": "arr", "t": { "kind": "int" } }
        }
    ],
    "o": 4
}
```

### The FunctionDef
The `FunctionDef` defines the metadata of a particular function, like name and type information. In addition, it also contains definition present only in this function (e.g., local variables).

The following fields are part of the `FunctionDef`'s specification:
- `n` (string): The name of function.
- `a` (Array\<[`DataType`](#datatype)\>): Defines the types of each of the arguments of the function, and also the function's arity as the length of this array. Further information, such as their names, can be found in the parameter's definition in the `table`.
- `r` ([`DataType`](#datatype)): States the return type of the function. If the function does not return anything, then this is a `Void`-datatype.
- `t` ([`SymTable`](#the-symtable)): The nested [`SymTable`](#the-symtable) that states the definitions of all functions, tasks, classes and variables defined in this function.

Example `FunctionDef`:
```json
// A minimum function `foo()`
{
    "n": "foo",
    "a": [],
    "r": { "kind": "void" },
    "t": {
        "funcs": { "d": [], "o": 0 },
        "tasks": { "d": [], "o": 0 },
        "classes": { "d": [], "o": 0 },
        "vars": { "d": [], "o": 0 },
        "results": {},
    }
}
```
```json
// A function `bar(int, string) -> bool` with some type stuff
{
    "n": "bar",
    "a": [ { "kind": "int" }, { "kind": "str" } ],
    "r": { "kind": "bool" },
    "t": {
        "funcs": { "d": [], "o": 0 },
        "tasks": { "d": [], "o": 0 },
        "classes": { "d": [], "o": 0 },
        // This declares the arguments first
        "vars": {
            "d": [
                {
                    "n": "some_arg",
                    "t": { "kind": "int" }
                },
                {
                    "n": "another_arg",
                    "t": { "kind": "str" }
                },
            ],
            "o": 0
        },
        "results": {},
    }
}
```
```json
// A function `baz() -> string` that defines a separate nested variable
{
    "n": "baz",
    "a": [],
    "r": { "kind": "str" },
    "t": {
        "funcs": { "d": [], "o": 0 },
        "tasks": { "d": [], "o": 0 },
        "classes": { "d": [], "o": 0 },
        "vars": {
            "d": [{
                "n": "var1",
                "t": { "kind": "arr", "t": { "kind": "real" } }
            }],
            "o": 0
        },
        "results": {},
    }
}
```

### The TaskDef
The `TaskDef` describes all metadata of a task such that we can call it successfully.

There are two kinds of tasks:
- `Compute`-tasks, which represent the execution of a container job; and
- `Transfer`-tasks, which represent a data transfer.

> <img src="../../assets/img/warning.png" alt="warning" width="16" style="margin-top: 2px; margin-bottom: -2px"/> `Transfer` tasks are actually not used by the reference implementation. They are here for legacy reasons and not removed because, at some point in the future, it may be nice if the planner may make transfers explicit.

The following fields are present regardless of the type of task:
- `kind` (string): Determines the kind of the `TaskDef`. This can either be `"cmp"` for `Compute`, or `"trf"` for `Transfer`.

Then, for compute tasks, the following fields are added to this definition:
- `p` (string): The name of the package in which the task is defined.
- `v` ([`Version`](#the-version)): A [`Version`](#the-version) indicating the targeted version of the package in which the task is defined.
- `d` ([`FunctionDef`](#the-functiondef)): Defines the signature and name of the function such that we can execute it with type safety. It is guaranteed that the `t`able of the definition is empty, since the function does not have a body.
- `a` (Array\<string\>): Defines the names of every argument, since task arguments are named (present for better error experience). This array should be exactly as long as the array of arguments in `d`.
- `r` (Array\<[`Capability`](#the-capability)\>): A list of capabilities that any site executing this task needs to have. This is mostly used by the planner to restrict the sites it is considering.

Transfer tasks have no additional fields.

Examples of `TaskDef`s are:
```json
// TaskDef without any arguments
{
    "kind": "cmp",
    "p": "foo_package",
    "v": "1.0.0",
    "d": {
        "n": "foo",
        "a": [],
        "r": { "kind": "void" },
        "t": {
            "funcs": { "d": [], "o": 0 },
            "tasks": { "d": [], "o": 0 },
            "classes": { "d": [], "o": 0 },
            "vars": { "d": [], "o": 0 },
            "results": {},
        }
    },
    "a": [],
    "r": { "kind": "void" }
}
```
```json
// TaskDef with some arguments
{
    "kind": "cmp",
    "p": "bar_package",
    "v": "1.0.0",
    "d": {
        "n": "bar",
        "a": [ { "kind": "bool" } ],
        "r": { "kind": "void" },
        // Always empty, regardless of arguments
        "t": {
            "funcs": { "d": [], "o": 0 },
            "tasks": { "d": [], "o": 0 },
            "classes": { "d": [], "o": 0 },
            "vars": { "d": [], "o": 0 },
            "results": {},
        }
    },
    "a": [ "is_cool" ],
    "r": { "kind": "void" }
}
```

### The ClassDef
`ClassDef`s describe all metadata of a class such that we can create it, access its element and call its methods.

The following fields are found in a `ClassDef`:
- `n` (string): The name of the class. This name is also used to resolve `clss` [`DataType`](#the-datatype)s.
- `i` (string?): The name of the package where this class was imported from _or_ null if it was defined in BraneScript.
- `v` (`Version`?): The version of the package where this class was imported from _or_ null if it was defined in BraneScript.
- `p` (Array\<[`VarDef`](#the-vardef)\>): A list of properties of this class, given as variable definitions (since properties have a name and a data type too).
- `m` (Array\<number\>): A list of functions that are methods of this `ClassDef`. The functions are referred to by identifier, meaning their definition is given as a separate `FunctionDef`.

The following snippets showcase examples of `ClassDef`s:
```json
// Represents class `Foo` that only has a few properties
{
    "n": "Foo",
    "i": null,
    "v": null,
    "p": [
        {
            "n": "prop1",
            "t": { "kind": "str" }
        },
        {
            "n": "prop2",
            "t": { "kind": "int" }
        },
    ],
    "m": []
}
```
```json
// Represents class `Bar` that has methods
{
    "n": "Bar",
    "i": null,
    "v": null,
    "p": [],
    "m": [
        {
            "n": "method1",
            // This argument essentially represents 'self'
            "a": [ { "kind": "clss", "n": "Bar" } ],
            "r": { "kind": "void" },
            "t": {
                "funcs": { "d": [], "o": 0 },
                "tasks": { "d": [], "o": 0 },
                "classes": { "d": [], "o": 0 },
                "vars": { "d": [], "o": 0 },
                "results": {},
            }
        }
    ]
}
```
```json
// Represents class `Baz` that is imported but has otherwise nothing
{
    "n": "Bar",
    "i": "baz_package",
    "v": "1.0.0",
    "p": [],
    "m": []
}
```

### The VarDef
A variable's name and data type are described by a `VarDef`.

Accordingly, the following fields are found in the `VarDef` object:
- `n` (string): The name of the variable.
- `t` ([`DataType`](#the-datatype)): The data type of the variable.

The following are a few examples of valid `VarDef`s:
```json
// A variable definition for `foo: string`
{
    "n": "foo",
    "t": { "kind": "str" }
}
```
```json
// A variable definition for `bar: int[]`
{
    "n": "bar",
    "t": { "kind": "arr", "t": { "kind": "int" } }
}
```
```json
// A variable definition for `baz: ExampleClass`
{
    "n": "baz",
    "t": { "kind": "clss", "n": "ExampleClass" }
}
```

## Miscellaneous
### The DataType
The `DataType` describes the kind of a value. This is typically used to propagate type information across a workflow.

A `DataType` can be of many variants. However, it always has at least the following fields:
- `kind` (string): A string identifier differentiating between the possible variants. Possibilities are:
    - `"bool"`: Maps to a boolean type (i.e., a value that is either `true` or `false`).
    - `"int"`: Maps to an integer type (i.e., a number without fraction).
    - `"real"`: Maps to a real type (i.e., a number with fraction).
    - `"str"`: Maps to a string type (i.e., a sequence of characters).
    - `"ver"`: Maps to a version number (i.e., a triplet of non-negative integers representing major, minor and patch version numbers).
    - `"arr"`: Maps to an array of some nested type (see below).
    - `"func"`: Maps to a function with a particular call signature (see below).
    - `"clss"`: Maps to a class (i.e., custom type) with a particular name (see below).
    - `"data`": Maps to a `Data` object.
    - `"res"`: Maps to an `IntermediateResult` object.
    - `"any"`: Maps to any possible type. Used as a placeholder for types which the compiler cannot deduce at compile time.
    - `"num"`: Maps to any numeric type (i.e., integers or reals).
    - `"add"`: Maps to any addable type (i.e., numerical types or strings)
    - `"call"`: Maps to any callable type (i.e., functions)
    - `"nvd"`: Maps to any type that is not void.
    - `"void"`: Maps to no type (i.e., no value).

Then some fields are added depending on the variant:
- For `"arr"`-datatypes:
    - `t` (`DataType`): The nested datatype of the elements of the array.
- For `"func"`-datatypes:
    - `a` (Array\<`DataType`\>): The datatypes of each of the arguments of the function. The length of the array simultaneously defines the function's arity.
    - `t` (`DataType`): The return type of the function.
- For `"clss"`-datatypes:
    - `n` (string): The name of the class to which this data type is referring.

A few examples of `DataType`s are:
```json
// Strings
{
    "kind": "str"
}
```
```json
// Any type
{
    "kind": "any"
}
```
```json
// An array of numbers
{
    "kind": "arr",
    "t": {
        "kind": "num"
    },
}
```
```json
// An array of arrays of strings
{
    "kind": "arr",
    "t": {
        "kind": "arr",
        "t": {
            "kind": "str"
        },
    },
}
```
```json
// A function call with two arguments, one return value
{
    "kind": "func",
    "a": [ { "kind": "int" }, { "kind": "str" } ],
    "t": { "kind": "bool" }
}
```
```json
// A class by the name of `Foo`
{
    "kind": "clss",
    "n": "Foo"
}
```


### The Version
The `Version` is a string describing a version number. This is always a triplet of three numbers separated by commas. The first number represents the major version number; the second number represents the minor version number and the third number is the patch number.

The following regular expression may parse `Version`s:
```
[0-9]+\.[0-9]+\.[0-9]+
```

### The Capability
A `Capability` is a string listing some kind of requirement on a compute site. This is used to sort them based on available hardware, compute power, etc.

Currently, the supported capabilities are:
- `"cuda_gpu"`: The compute site has a CUDA GPU available.

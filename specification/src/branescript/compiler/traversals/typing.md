# Type Analysis Traversal
In this traversal, the compiler will resolve the type information in the AST as much as possible.

> TODO: Rework AST to integrate the `IdentifierExpression`, which essentially abstracts over direct variable reference, projection, index or any mix of the three.

This traversal essentially runs three checks in parallel:
1. It deduces per-variable type information;
2. It deduces whether any statement returns or evaluates to a value; and
3. It checks whether it deduces any new information

The latter point, while relatively trivial, is necessary to dedect convergence. This means that the algorithm is guaranteed to terminate, since every rule it applies can only reduce the work it has to do, and it stops if there is no more rule to apply.

Representation-wise, the `DataType::Any` is used to represent a non-resolved type. It may be that, after convergence, there still exist any `DataType::Any`'s; in this case, this information is has to be resolved at linking or, worst-case, runtime.

Note that this traversal respects annotations, so they should be pushed/popped for every new node visited.

The first kind of deduction, type deduction, is done by traversing the AST depth-first. The following explains the deduction taken per type of node (and their subtypes):
1. _Program_:
    - Traverse into the statements
2. _Statement_:
    1. _Import_:
        - Nothing to do
    2. _FunctionDef_:
        - Propagate any property type hints to the property definitions
        - **\[if a method\]** Assert that the first argument is called `self` and its type is the parent class.
        - Recurse into the function's statements.
    3. _ClassDef_:
        - For every definition within the _ClassDef_:
            1. _Property_: Propagate the property's type hints to the property definition
            2. _Method_: See _FunctionDef_
            3. _Annotation_ or _ParentAnnotation_: Ignored, should be removed in earlier traversal.
    4. _VarDef_:
        - Propagate any type hints to the variable definition
        - Recurse into the expression (see _Expression_). Compare its evaluated type to the type of the variable definition, and either override it (if the latter is `DataType::Any`), or assert they are the same.
    5. _For_:
        - Propagate `DataType::Integer` to the loop variable
        - Recurse into the `start`, `stop` and `step` expressions of the loop to evaluate their type (see _Expression_). For each of them, assert they evaluate to a `DataType::Integer` (or `DataType::Any`).
        - Then recurse into any statements within the _For_.
    6. _While_:
        - Recurse into the `cond` expression (see _Expression_), and assert it evaluates to a `DataType::Boolean` (or `DataType::Any`).
        - Then recurse into any statements within the _While_.
    7. _Return_:
        - Traverse into the expression of the return to evaluate any nested types (see _Expression_). However, return type analysis is done in a separate pass.
    8. _Expression_:
        - Recurse into the expression (see _Expression_).
    9. _Annotation_ or _ParentAnnotation_:
        - Ignored, should be removed in earlier traversal.
3. _Expression_:
    1. _Block_:
        - Recurse into each of the expressions. If they are not the last one, assert they evaluate to `DataType::Void`; otherwise, for the last one, propagate its evaluated type as the evaluated type for the entire _Block_.
    2. _If_:
        - Recurse into the `cond` expression, and assert it evaluates to a `DataType::Boolean`.
        - Recurse into the true-block, and note down its evaluated type.
        - If present, recurse into the false-block, and note down its evaluated type.
            - Assert that the false-block evaluates to the same type as the true-block.
        - Finally, propagate the evaluated type of the true-block as the evaluated type of the _If_.
    3. _Parallel_:
        - Iterate over the branches and recurse into them to obtain their evaluated type.
        - For the first branch:
            - If there is an explicit merge strategy, then assert its type is compatible with it
            - If there is no explicit merge strategy, attempt to deduce it according to the first branch's evaluated type (which is: `MergeStrategy::Discard` for `DataType::Void`, `MergeStrategy::All` for the rest).
        - For the remaining branches:
            - Assert their evaluated type is the same as for the first branch.
        - After all branches have been evaluated, compute the evaluated type of the _Parallel_ as a function of the merge strategy and the evaluated type of the first branch.
    4. _Cast_:
        - Recurse into the expression to find its evaluated type
        - Assert that the evaluated type of the expression is compatible with the target cast type
        - Return the evaluated type of the _Cast_ as the cast type.
    5. _Discard_:
        - Recurse into the expression to handle any deduction there.
        - Return the `DataType::Void` type as evaluated type for the _Discard_.
    6. _Index_:
        - Recurse into the index expression and then the value expression.
        - Assert that the index' evaluated type is `DataType::Integer` (or `DataType::Any`).
        - Assert that the value's evaluated type matches the type of the referred variable.
        - Return the evaluated type of the _Index_ as the type of the referred variable.
    7. _Proj_:
        - TODO
    8. _Call_:
        - TODO
    9. _Unary_:
        - TODO
    10. _Binary_:
        - TODO
    11. _Array_:
        - TODO
    12. _LocalInstance_:
        - TODO
    13. _RemoteInstance_:
        - TODO
    14. _VarRef_:
        - TODO
    15. _LocalFunctionRef_:
        - TODO
    16. _RemoteFunctionRef_:
        - TODO
    17. _Literal_:
        - TODO

Note that the type-deduction algorithm will be run repeatedly, until it converges (i.e., no new information is deduced).

# Grammar
In this chapter, we will provide a specification for the grammar of the BraneScript language.

We will use codeblocks with a mix of [Backus-Naur form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) for specifying the grammer, and JavaScript Regex Expressions for specifying specific syntax. To disambiguate, any token not wrapped in triangular brackets (`<>`) is a regex-expression, or else the triangular brackets will be escaped (i.e., `\< \>`).

Also note that symbol names (i.e., identifiers wrapped in non-escaped `<>`) are given with a capital letter to match the name they have in the Rust source code. This is done for convenience.

This is arguably one of the most formal parts of the specification. If you are not interested in such detail, consider skipping to a [future chapter](TODO) or to visit the [BraneScript tutorial](/user-guide/branescript/introduction.html) in the [Brane: The User Guide](/user-guide) book.


## Statements
Like most languages, BraneScript is at the toplevel composed of a series of statements. These each compose the smallest piece of valid BraneScript code; put differently, a REPL will probably want to scan input until it has successfully parsed a statement.


### Program
The toplevel grammar looks like this:
```
<Program> := <Statements>
          := 

<Statements> := <Statements> <Statement>
             |  <Statement>
```

### Statement
Subsequently, a statement, and its various forms, looks like this:
```
<Statement> := <Annotation>
            |  <ParentAnnotation>
            |  <Import>
            |  <FunctionDef>
            |  <ClassDef>
            |  <VarDef>
            |  <For>
            |  <While>
            |  <Return>
            |  <Expression>
```

#### Annotations
Annotations are used to provide compiler-relevant information to some other statement. Semantically, `<Annotation>`s annotate the statement which succeeds them; `<ParenAnnotation>`s, in contrast, annotate the `<Program>` or `<Block>` in which they are nested.

They are heavily inspired by [Rust's attributes](https://doc.rust-lang.org/reference/attributes.html).
```
<Annotation> := #\[\]
             |  #\[ <RawAnnotations> \]

<ParentAnnotation> := #!\[\]
                   |  #!\[ <RawAnnotations> \]

<RawAnnotations> := <RawAnnotations> , <RawAnnotation>
                 |  <RawAnnotation>

<RawAnnotation> := <Identifier> = <Expression>
                |  <Identifier> \( <RawAnnotations> \)
                |  <Identifier>
```

#### Import-statement
The import-statement is used to bring some package into scope of a workflow. It can either specify only the name of a package, in which case the latest known version is assumed, or defined a `<major>.<minor>.<patch>` version specifier in addition. For this reason, the only literals that are semantically allowed are (unsigned) integer literals.
```
<Import> := import <Identifier>;
         := import <Identifier> \[ <Literal>\.<Literal>\.<Literal> \];
```

#### Function definition
```
<FunctionDef> := func <Identifier> \(\) \{ \}
              |  func <Identifier> \( <ArgDefs> \) \{ \}
              |  func <Identifier> \(\) -> <DataType> \{ \}
              |  func <Identifier> \( <ArgDefs> \) -> <DataType> \{ \}
              |  func <Identifier> \(\) \{ <Statements> \}
              |  func <Identifier> \( <ArgDefs> \) \{ <Statements> \}
              |  func <Identifier> \(\) -> <DataType> \{ <Statements> \}
              |  func <Identifier> \( <ArgDefs> \) -> <DataType> \{ <Statements> \}

<ArgDefs> := <ArgDefs> , <ArgDef>
          |  <ArgDef>

<ArgDef> := <Identifier> : <DataType>
         |  <Identifier>
```

# Formal grammar
In this chapter, we present the formal grammar of Brane in [Backus-Naur form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) (or something very much like it). This will show you what's possible to write in BraneScript and how the language is structured.

This chapter is very technical, and mostly suited for implementing a BraneScript parser. To find out more details about compiling BraneScript to the [Workflow Intermediate Representation](TODO) (WIR), consult the [next chapters](TODO).


## Conventions
As already stated, we will be using something like the Backus-Naur form in order to express the grammar (using the syntax as given on [Wikipedia](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form)). However, we use certain conventions to structure the discussion.

First, BraneScript parsing is done in two-steps: first, a scanning or tokenization step, and then a parsing step of those tokens. We do the same here, where we will indicate tokens (i.e., terminals) in ALL CAPS. Non-terminals, which are parsed from the tokens, are indicated by CamelCaps.

Note that the order of tokens matters in that, in the case of ambiguity of parsing tokens, then tokens appearing first should be attempted first.

Then, we define an additional type of expression: regular expressions. These are given like literals (`"..."`), except that they are prefixed by an `r` (e.g., `r"..."`). If so, then the contents of the string should be understood as [TextMate regular expressions](https://macromates.com/manual/en/regular_expressions).

Note that the grammar does not encode operator precedence and associativity. Instead, this is defined separately [below](#operator-precedence--associativity).

Finally, we also use our own notion of comments, prefixed by a double slash (`//`). Anything from (and including) the double slash until the end of the line (or file) can be ignored for the official grammar.


## Grammar
Now follows the grammar of BraneScript.

```
///// NON-TERMINALS /////

// Statements
Stmts ::= Stmts Stmt
        | Stmt
 Stmt ::= Attribute | AttributeInner | Assign | Block | ClassDecl | ExprStmt | For | FuncDecl
        | If | Import | LetAssign | Parallel | Return | While

     Attribute ::= POUND LBRACKET AttrKeyPair RBRACKET
                 | POUND LBRACKET AttrList RBRACKET
AttributeInner ::= POUND NOT LBRACKET AttrKeyPair RBRACKET
                 | POUND NOT LBRACKET AttrList RBRACKET
   AttrKeyPair ::= IDENT EQUAL Literal
      AttrList ::= IDENT LPAREN Literals RPAREN
      Literals ::= Literals Literal
                 | Literal

Assign ::= IDENT ASSIGN Expr SEMICOLON

Block ::= LBRACE Stmts RBRACE
        | LBRACE RBRACE

 ClassDecl ::= CLASS IDENT LBRACE ClassStmts RBRACE
ClassStmts ::= ClassStmts Prop
             | ClassStmts FuncDecl
             | Prop
             | FuncDecl
      Prop ::= IDENT COLON IDENT SEMICOLON

ExprStmt ::= Expr SEMICOLON

For ::= FOR LPAREN LetAssign Expr SEMICOLON IDENT ASSIGN Expr RPAREN Block

FuncDecl ::= FUNCTION IDENT LPAREN Args RPAREN Block
           | FUNCTION IDENT LPAREN RPAREN Block
    Args ::= Args COMMA IDENT
           | IDENT

If ::= IF LPAREN Expr RPAREN Block
     | IF LPAREN Expr RPAREN Block ELSE Block

Import ::= IMPORT IDENT SEMICOLON
         | IMPORT IDENT LBRACKET SEMVER RBRACKET SEMICOLON

LetAssign ::= LET IDENT ASSIGN Expr SEMICOLON

Parallel ::= PARALLEL LBRACKET PBlocks RBRACKET SEMICOLON
           | PARALLEL LBRACKET IDENT RBRACKET LBRACKET PBlocks RBRACKET SEMICOLON
           | LET IDENT ASSIGN PARALLEL LBRACKET PBlocks RBRACKET SEMICOLON
           | LET IDENT ASSIGN PARALLEL LBRACKET IDENT RBRACKET LBRACKET PBlocks RBRACKET SEMICOLON
 PBlocks ::= PBlocks COMMA Block
           | Block

Return ::= RETURN Expr SEMICOLON
         | RETURN SEMICOLON

While ::= WHILE LPAREN Expr RPAREN Block



// Expressions
Exprs ::= Exprs COMMA Expr
        | Expr
 Expr ::= LPAREN Expr RPAREN
        | Expr BinOp Expr
        | UnaOp Expr
        | Array | ArrayIndex | Call | IDENT | Instance | Literal
        | Projection
BinOp ::= AND AND | EQUAL | GREATER | GREATEREQ | LESS | LESSEQ | MINUS | NOTEQ
        | OR OR | PERCENTAGE | PLUS | SLASH | STAR
UnaOp ::= NOT | MINUS

Array ::= LBRACKET Exprs RBRACKET
        | LBRACKET RBRACKET

ArrayIndex ::= Array LBRACKET Expr RBRACKET

Call ::= IDENT LPAREN Exprs RPAREN
       | Projection LPAREN Exprs RPAREN
       | IDENT LPAREN RPAREN
       | Projection LPAREN RPAREN

     Instance ::= NEW IDENT LBRACE InstanceProps RBRACE
                | NEW IDENT LBRACE RBRACE
InstanceProps ::= InstanceProps COMMA InstanceProp
                | InstanceProp
 InstanceProp ::= IDENT ASSIGN Expr

Literal ::= BOOLEAN | INTEGER | NULL | REAL | STRING

Projection ::= Projection DOT IDENT
             | IDENT DOT IDENT
```
```
///// TERMINALS /////

// Keywords (and other tokens needing to be parsed first)
   ASSIGN ::= ":="
    BREAK ::= "break"
    CLASS ::= "class"
 CONTINUE ::= "continue"
     ELSE ::= "else"
      FOR ::= "for"
 FUNCTION ::= "func"
GREATEREQ ::= ">="
       IF ::= "if"
   IMPORT ::= "import"
   LESSEQ ::= "<="
      LET ::= "let"
      NEW ::= "new"
    NOTEQ ::= "!="
     NULL ::= "null"
       ON ::= "on"
 PARALLEL ::= "parallel"
   RETURN ::= "return"
    WHILE ::= "while"



// Punctuation
       AND ::= "&"
        AT ::= "@"
    LBRACE ::= "{"
    RBRACE ::= "}"
  LBRACKET ::= "["
  RBRACKET ::= "}"
     COLON ::= ":"
     COMMA ::= ","
       DOT ::= "."
     EQUAL ::= "="
   GREATER ::= ">"
      LESS ::= "<"
     MINUS ::= "-"
       NOT ::= "!"
        OR ::= "|"
    LPAREN ::= "("
    RPAREN ::= ")"
PERCENTAGE ::= "%"
      PLUS ::= "+"
     POUND ::= "#"
 SEMICOLON ::= ";"
     SLASH ::= "/"
      STAR ::= "*"



// Tokens with values
 SEMVER ::= r"[0-9]+\.[0-9]+\.[0-9]+"                       // 1
   REAL ::= r"([0-9_])*\.([0-9_])+([eE][+\-]?([0-9_])+)?"   // 2
BOOLEAN ::= r"(true|false)"
  IDENT ::= r"[a-zA-Z_][a-zA-Z_0-9]*"                       // 3
INTEGER ::= r"([0-9_])+"
 STRING ::= r"\"([^\"\\]|\\[\"'ntr\\])*\""
```
```
///// REMARKS /////
// 1: Has to be before REAL & INTEGER
// 2: Has to be before INTEGER
// 3: Has to be below BOOLEAN & keywords
```


## Operator precedence & associativity
The grammar above does not encode precedence and associativity for brevity purposes. Instead, they are given here in **Table 1**.

| Operator | Precedence | Associativity |
|----------|------------|---------------|
| &&       | 0          | Left          |
| \|\|     | 0          | Left          |
| ==       | 1          | Left          |
| !=       | 1          | Left          |
| <        | 2          | Left          |
| >        | 2          | Left          |
| <=       | 2          | Left          |
| >=       | 2          | Left          |
| +        | 3          | Left          |
| -        | 3          | Left          |
| *        | 4          | Left          |
| /        | 4          | Left          |
| %        | 4          | Left          |
| !        | 5          | Unary         |
| -        | 5          | Unary         |

_**Table 1**: Operator precedence and associativity for BraneScript. An operator with a higher precedence will bind stronger, and an operator with left-associativity will create parenthesis on the left._


## Next
The compilation of BraneScript to the WIR, and thus details about how to interpret the AST obtained by parsing BraneScript, are discussed in the [next chapter](./scoping.md).

Alternatively, if you want to know what BraneScript can be instead of what it is, refer to the [Future work](./future.md)-chapter.

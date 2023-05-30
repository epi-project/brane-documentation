# BraneScript Compiler
These chapters describe the inner workings of the BraneScript compiler.

Note that these chapters are about the new syntax compiler. The biggest difference between this and the old syntax compiler -in addition to language improvements- is the explicit detachment between compilation and linking. This allows us to reason about the delay in information in a REPL setting more clearly and formally.

In particular, the compiler has a notion of _resolved entries_, which are symbol table entries that are known at compile time, and _phantom entries_, which are essentially external references. Because BraneScript is a scripting language, it does not require any header information about phantom entries; instead, it deduces what it can based on the phantom entry's usage, and then attempts to merge that with the entry's actual type at link time.



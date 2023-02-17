# Conventions
In this chapter, we will go through the conventions used in the BraneScript specification.

These are only series-wide conventions. Some chapters may have additional conventions that are only used within that chapter itself.


## Versioning
The first, important thing to note is how the specification deals with versioning.

Every piece of information is typically tied to a specific _range_ of BraneScript versions for which it holds. By default, it holds for all documented versions ([1.0.0](https://github.com/epi-project/brane/releases/v1.0.0) and upwards).

Sometimes, however, a feature is discussed that is only valid from a certain version onwards. In this case, you will see the following:

> [Version $\geq$ A.B.C](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

This header status that the following text is only valid from version `A.B.C` onwards. If it is given in isolation, then it follow for the remainder of the section; but if it is only a small snippet of text, you may also see the following:

> [Version $\geq$ A.B.C](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
> 
> Did you ever hear the tragedy of Darth Plagueis The Wise? I thought not. It’s not a story the Jedi would tell you. It’s a Sith legend. Darth Plagueis was a Dark Lord of the Sith, so powerful and so wise he could use the Force to influence the midichlorians to create life… He had such a knowledge of the dark side that he could even keep the ones he cared about from dying. The dark side of the Force is a pathway to many abilities some consider to be unnatural. He became so powerful… the only thing he was afraid of was losing his power, which eventually, of course, he did. Unfortunately, he taught his apprentice everything he knew, then his apprentice killed him in his sleep. Ironic. He could save others from death, but not himself.

In this case, the version scope only applies to that specific snippet.

Naturally, some features may also be only valid up to some specific version of BraneScript. The same syntax is used, then, except that it is prefixed by a $\lt$ (or sometimes $\leq$ if it includes that version) to indicate its an upper bound:

> [Version $\lt$ A.B.C](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

It can also be combined with a lower bound to specify a range of versions:

> [Version $\geq$ A.B.C, $\lt$ X.Y.Z](https://www.youtube.com/watch?v=dQw4w9WgXcQ)


## Next
Now that you have the conventions used in the BraneScript specification in mind, you can proceed to any chapter in the sidebalk to the left. For a full overview, you should begin by considering BraneScript's grammar, which is treated in the [next chapter](./grammar.md).

# Annotations
BraneScript has a notion of so-called _annotations_, which is a line in the source text that can be used to 'annotate' some statement so the behaviour of the compiler or the framework itself changes.


## General syntax
There are multiple annotations, but they all follow the form:
```branescript
#[<name>]
<statement>
// or
#[<name>=<value>]
<statement>
// or
#[<name1>,<name2>=<value>]
<statement>
// ...
```
They must be given before a (non-comment) statement, and are applied to that whole statement.

For example, like On-structs, one can use the `location` annotation to limit the locations where an external call may be performed. So, we could write the following:
```branescript
#[location="site1"]
hello_world();
```
which is equivalent to:
```branescript
on "site1" {
    hello_world();
}
```
We can also use this to show that statements only work on one statement. To emulate the following on-statement:
```branescript
on "site1" {
    func_one();
    func_two();
}
```
we would have to write
```branescript
#[location="site1"]
func_one();
#[location="site1"]
func_two();
```
or
```branescript
#[location="site1"]
{
    func_one();
    func_two();
}
```
to get the same effect.


## Annotations
Annotations currently supported by the framework are:
- `location`: Same as an on-statement (see example above), and secretly syntactic sugar for a `locations`-annotation with only one location (see below). It must always be given with a single value, which must be a string literal. For example:
  ```branescript
  func_run_anywhere();

  #[location="specific_site"]
  func_run_on_specific_site();
  ```
  Note that giving multiple `location`-annotations to the same statement only confuses the compiler, as it sees them as mutually exclusive (resulting in no actual locations where it may be run). Instead, check the `locations`-annotation.
- `locations`: Same as an on-statement, except that it accepts multiple locations. Instead of fixing the locations, this instead narrows the planner's options down to only these. Consequently, instead of accepting a single string literal, it accepts an array of string literals.
  ```branescript
  func_run_anywhere();

  #[locations=["specific_site"]]
  func_run_on_specific_site();

  #[locations=["site1", "site2]]
  func_run_on_one_of_two_sites();

  #[locations=[]]
  func_run_nowhere();
  ```
  Specifying multiple `locations`-annotations results in only the intersection of those lists to be used. For example:
  ```branescript
  #[locations=["site1, "site2"]]
  {
      #[locations=["site2", "site3"]]
      func_run_only_on_site2();
  }
  ```
- `allow`: Allows the following statement to trigger a warning without reporting it. Basically suppresses that warning. Takes a single string identifier with the warning to suppress.
  ```branescript
  #[allow(trivial_if)]
  if (true) {
      print("Hello there!");
  } else {
      print("General Kenobi, you are a bold one!");
  }
  // Will NOT trigger a warning
  ```

# Builtins
Like any good language, BraneScript defines a few builtin functions and classes that provide some special, otherwise impossible functionality. In this chapter, we list all of the builtins.

In the next section, we will first define all builtin functions. Then, in the section after that, we will list all builtin classes.


## Builtin functions
### `print`-function
The `print`-function is used to write some BraneScript-local output to the stdout of the calling environment.

It accepts one argument of `string` type. Whatever this string is is printed to stdout during runtime, _not_ followed by a newline (check `println` for that).

Formally, we can write the `print`-function to have the following signature:
```branescript
func print(value: string) -> void;
```
but remember that almost any type works due to the magic of implicit conversion.

### `println`-function
The `println`-function does the same as the `print`-function, except that it adds a newline afterwards.

It accepts one argument of `string` type. Whatever this string is is printed to stdout during runtime, followed by a newline.

Formally, we can write the `println`-function to have the following signature:
```branescript
func println(value: string) -> void;
```
but remember that almost any type works due to the magic of implicit conversion.


## Builtin classes
### `Data`-class
The `Data`-class is used to refer to external assets which are otherwise not accessible from within BraneScript. It wraps around an identifier (of `string` type), which is resolved at runtime to an actual dataset provided by one of the domains.

Based on the datasets that a function accepts, the planner can deduce which sites are in charge of the dataset (and have to be asked permission) and if the dataset has to be transferred around or not.

This is the only way to get access to external datasets. If you use normal strings to reference datasets or paths to datasets, they will not be mounted to the package container.

Formally, we can write the `Data`-class to have the following signature:
```branescript
class Data {
    name : string,
}
```
So, for instance, one can create one using:
```branescript
let data := new Data {
    name := "test_dataset",
};
```

To obtain a list of dataset names that are used in your instance, run `brane data list`.

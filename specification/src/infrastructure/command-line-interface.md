# Command-line interface
The command-line interface of the framework (introduced in the previous chapter) is really the driver behind the framework, and for most users it's also its ultimate point of interaction. For Brane, this is a single executable (canonically called `brane`) that is subdivided into several **subcommands**, each of which act as a separate tool to do some interaction with Brane.

In this chapter, we will discuss what the CLI can do and what we expect from it. As mentioned in the previous chapter, this is not the most interesting 

Before  this section, we will use a slightly different convention 

> We won't give a full overview of the subcommands of the command-line tool here; refer to the [Brane: The User Guide](https://server.timinc/nl/brane/TODO) book instead. Instead, this book discusses the general role the CLI has in the design of Brane.

## Roles
The main role of the CLI is to be the point of interaction for most users of the framework. However, for Brane this can mean many things, and so we divide this interaction into several actions the CLI takes to interact with a Brane instance:
 - Building packages
 - Testing packages locally
 - Testing workflows locally
 - Submitting packages 
 - Submitting workflows
 - Returning workflow output

Especially the testing part means that the CLI (or actually)

# Part 2: A workflow for Disaster Tweets
In this document, we detail the steps that can be taken during the second part of the tutorial. In this part, participants will write a larger workflow file for an already existing package and submit it to a running EPI Framework instance. The package implements a data pipeline for doing Natural Language Processing (NLP) on the [Disaster Tweets dataset](https://www.openml.org/search?type=data&status=active&id=43395&sort=runs), created for the matching [Kaggle challenge](https://www.kaggle.com/competitions/nlp-getting-started).


## Background
In the [first part](./p1_hello_world.md) of the tutorial, you've created your own Hello, world!-package. In this tutorial, we will assume a more complex package has already been created, and you will take on the role as a Domain-Specific Scientist who wants to use it in the framework.

The pipeline implements a classifier that aims to predict is a tweet is indicating a natural disaster is happening, or not. To do so, a naive bayes classifier has been implemented that takes preprocessed tweets as input, and outputs a `1` if it references a disaster, or a `0` if it does not. In addition, various visualisations have been implemented that can be used to analyse the model and the dataset.

The package has been implemented by Andrea Marino and Jingye Wang for the course [Web Services and Cloud-Based Systems](https://studiegids.uva.nl/xmlpages/page/2021-2022/zoek-vak/vak/89328). Their original code can be found [here](https://github.com/marinoandrea/disaster-tweets-brane), but we will be working with a version compatible with the most recent version of the framework which can be found [here](https://github.com/epi-project/brane-disaster-tweets-example).


## Objective
As already mentioned, this part focusses on implementing a workflow that can do classification on the disaster tweets dataset. To do so, the dataset has to be downloaded and the two packages have to be built. Then, a workflow should be written that does the following:
1. Clean the training and test datasets (`clean()`)
2. Tokenize the training and test datasets (`tokenize()`)
3. Remove stopwords from the tweets in both datasets (`remove_stopwords()`)
4. Vectorize the datasets (`create_vectors()`)
5. Train the model (`train_model()`)

All of these functions can be found in the `compute` package.

Then, optionally, any number of visualizations can be implemented as well to obtain results from the dataset and the model. Conveniently, you can generate all of them in a convenient HTML file by calling the `visualization_action()` function from the `visualization` package, but you can also generate the plots separately.

> <img src="../../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> Tip: If you use `brane inspect <package>`, you can see the tasks defined in a package together with which input and output the tasks define. For example:
> 
> <img src="./img/inspect.png" alt="Successfully built version 1.0.0 of container (ECU) package hello_world." width=500/>


## Installation
Before you can begin writing your workflow, you should first built the packages and download the required datasets. We will treat both of these separately in this section.

We assume that you have already completed part 1. If not, [install the `brane` executable](./p1_hello_world.md#installation) and [install Docker](./p1_hello_world.md#building-a-package) as specified in the previous document before you continue.

### Building packages
Because the package is in a [GitHub](https://github.com) repository, this step is actually fairly easy by using the `brane import` command.

Open a terminal that has access to the `brane`-command, and then run:
```bash
brane import epi-project/brane-disaster-tweets-example -c packages/compute/container.yml
brane import epi-project/brane-disaster-tweets-example -c packages/visualization/container.yml
```

This will allow you to build a package's source from a repository of the user `epi-project` and that goes by the name of `brane-disaster-tweets-example`. An eagle-eyed person may notice that this is exactly the URL of a repository, except that `https://github.com/` is omitted. The second part of the command, `-c ...`, specifies which `container.yml` to use in that repository. We need to specify this because the repository defines two different packages, but this does allow us to build both of them.

After the command completes, you can verify that you have them installed by running `brane list` again.

### Obtaining data
In the EPI Framework, datasets are considered assets, much like packages. That means that similarly, we will have to get the data file(s), defined some metadata, and then use the `brane` tool to build the assets and make them available for local execution.

To save some time, we have already pre-packaged the training dataset [here](./data/train.zip), and the test dataset [here](./data/test.zip). These are both ZIP-archives containing a directory with a metadata file (`data.yml`) and another directory with the data in it (`data/dataset.csv`). Once downloaded, you should unpack them, and then open a terminal.

Navigate to the folder of the training dataset first, and then run this command:
```bash
brane data build ./data.yml
```
Once it completes, navigate to the directory of the second dataset and repeat the command. You can then use `brane data list` to assert they have been added successfully.

The `data.yml` file itself is relatively straightforward, and so we encourage you to take a look at it yourself. Similarly, also take a look at the dataset itself to see what the pipeline will be working on.

> <img src="../../../assets/img/info.png" alt="info" width="16" style="margin-top: 3px; margin-bottom: -3px"/> By default, the above command does not copy the dataset file referenced in `data.yml`, but instead just links it. This is usually fine, but if you intend to delete the downloaded files immediately afterwards, use the `--no-links` flag to copy the dataset instead.


## Writing the workflow - Compute
Once you have prepared your local machine for the package and the data, it is time to write a proper workflow!

To do so, open a new file (called, for example, `workflow.bs`) in which we will write the workflow. Then, let's start by including the packages we need:
```bscript
import compute;
import visualization;
```
The first package implements everything up to training the classifier, and the visualization package implements functions that generate graphs to inspect the dataset and the model, so we'll need both of them to see anything useful.

Next up, we'll do something new:
```bscript
// ... imports

// We refer to the datasets we want to use
let train := new Data{ name := "nlp_train" };
let test  := new Data{ name := "nlp_test" };
```
The first step is to decide which data we want to use in this pipeline. This is done by creating an instance of the builtin `Data` class, which we can give a name to refer to a dataset in the instance. If you check `brane data list`, you'll see that `nlp_train` is the identifier of the training set, and `nlp_test` is the identifier of the test set.

Note, however, that this is merely a data _reference_. The variable does not represent the data itself, and cannot be inspected from within BraneScript (you may not that the `Data` class has no functions, for example). Instead, its only job is so that the framework knows which dataset to attach to which task at which moment. You can verify that the framework attaches it by [inspecting the package code](https://github.com/epi-project/brane-disaster-tweets-example/blob/main/packages/compute/run.py) and observing that it will pass the task a path where it can find the dataset in question.

Next, we will do the first step: cleanup the dataset.
```bscript
// ... datasets

// Preprocess the datasets
let train_clean := clean(train);
let test_clean  := clean(test);
```
You can see that this is the same function that takes different datasets as input, and then returns a _new_ dataset that contains the same data, but cleaned. Note, however, that this dataset won't be externally reachable; instead, we call it an _intermediate result_, which is a dataset which will be deleted after the workflow completes.

Let's continue, and tokenize and then remove stopwords from the two datasets:
```bscript
// ... cleaning

let train_final := tokenize(train_clean);
let test_final  := tokenize(test_clean);
train_final := remove_stopwords(train_final);
test_final  := remove_stopwords(test_final);
```
As you can see, we don't need a new variable for every new result; we can just override old ones if we don't need them anymore.

Now that we have preprocessed datasets, we will vectorize them so that it becomes quicker for a subsequent call to load them. However, by design of the package, these datasets are vectorized together; so we have to give them both as input, and only get a single result containing both output files:
```bscript
// ... preprocessing

let vectors := create_vectors(train_final, test_final);
```

And with that, we have a fully preprocessed dataset. That means we can now train the classifier, which is done conveniently by calling a single function:
```bscript
// ... vectorization

let model := train_model(train, vectors);
commit_result("nlp_model", model);
```

The second line is the most interesting here, because we are using the builtin `commit_result`-function to "promote" the result of the function to a publicly available dataset. Specifically, we tell the framework to make the intermediate result in the `model`-variable public under the identifier `nlp_model`. By doing this, we can later write a workflow that simply references that model in the first place, and pickup where we left off.

> You might notice that the model is returned as a dataset as well. While the function could have returned a class or array in BraneScript to represent it, this has two disadvantages:
> - Most Python libraries write models to files anyway, so converting them to BraneScript values needs additional work; and
> - By making something a dataset, it becomes subject to _policy_. This means that participating domains will be able to say something about where the result may go. For this reason, in practice, a package will likely not be approved by a hospital if it does not return important values like these as a dataset so that they can stay in control of it.
> 
> This is useful to remember if you ever find yourself writing BraneScript packages again.

And with that, we have a workflow that can train a binary classifier on the Disaster Tweets dataset! However, we are not doing anything with the classifier yet; that will be done in the next section.


## Writing a workflow - Visualization
We will continue writing the same workflow which we wrote in the previous section.



Underneath the training of the model, add the following:
```bscript

```

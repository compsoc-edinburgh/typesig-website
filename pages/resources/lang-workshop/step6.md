---
layout: page
title: "Step 6: Types | Language Workshop"
permalink: "/resources/lang-workshop/step6"
latex: true
---

Complexity: Medium

## Table of Contents
{:.no_toc}

* toc dummy
{:toc}

## Motivation

By now, we have a fully Turing complete programming language.
But not every program that we can express in our language is meaningful.

For example, consider the following program:

```scheme
(+ 1 (lambda (x) x))
```

Try evaluating it in your interpreter and see what happens.
You'll probably either hit an error, or you'll get a nonsense result.
That's because it doesn't really make sense to have addition defined between an integer and a lambda expression.

Let's look at another example.

```scheme
(1 2)
```

Here, we're trying to use an integer as a function!

Perhaps there are models of programming where this would be a sensible thing to do, but in general, it's good to be able to restrict the programs we're able to write in our language to only meaningful programs.
We can do this by adding a *type system* to our language, and a function to our interpreter that performs *type checking*.

The exact definition of "meaningful" above depends on the programs you want your language to be able to express, and changing the definition of meaningful changes the features your type system needs to have.
Over the next few steps, we'll explore a few common type system designs and features that many languages have.

## Notation
Before we start with types, we need to introduce some notation.

When describing type systems, it's common to make use of *inference rules*.
Inference rules are a flexible syntax that can be used to reason about a wide variety of logical systems.

Rules consist of a horizontal line, with some statements above the line, and exactly one statement beneath the line.
The statements above the line are called *premises*, and the statement beneath the line is called the *conclusion*.
In order for the conclusion to hold, all of the premises must hold also.
Validity here is determined by the logical system you're working with.

Let's look at a classic example of an inference rule.

\begin{prooftree}
  \AxiomC{\textrm{Socrates is a man}}
  \AxiomC{\textrm{All men are mortal}}
  \BinaryInfC{\textrm{Socrates is mortal}}
\end{prooftree}

This rule can be read in two ways:
- Top to bottom: If I know that Socrates is a man, and that all men are mortal, then I can infer that Socrates is mortal.
- Bottom to top: If I want to check that Socrates is mortal, then I must first check that Socrates is a man and that all men are mortal.

Which reading is more relevent depends on what you're trying to accomplish.
Often, with type systems, we usually read things from bottom to top.

### Axioms
We might want to express that some logical statement *always* holds.
We do this by producing an inference rule where there are zero premises, and the conclusion is our desired statement.
Such an inference rule is called an *axiom*.

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\textrm{Socrates is a man}}
\end{prooftree}

### Proof Trees
We can combine axioms and inference rules to produce *proof trees*, which show that a given logical statement follows from the assumed axioms and inference rules.

A proof tree is complete when there are no unproven statements at its leaves.
If we ever end up with a tree where with unproven statements, but there are no rules that can be applied, then it means the statement is unprovable from the assumed axioms and inference rules.

We'll step through an example proof tree so you can see how to do them.
Let's say we assume the following axioms:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\textrm{Socrates is a man}}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\textrm{All men are mortal}}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\textrm{All mortals can be killed}}
\end{prooftree}

And we assume the following inference rules:

\begin{prooftree}
  \AxiomC{\textrm{Socrates is a man}}
  \AxiomC{\textrm{All men are mortal}}
  \BinaryInfC{\textrm{Socrates is mortal}}
\end{prooftree}

\begin{prooftree}
  \AxiomC{\textrm{Socrates is mortal}}
  \AxiomC{\textrm{All mortals can be killed}}
  \BinaryInfC{\textrm{Socrates can be killed}}
\end{prooftree}

We can combine these together into a proof that Socrates can be killed.

When deriving proof trees, it's often easiest to work bottom to top, so let's start off with just our conclusion:

\begin{prooftree}
  \AxiomC{\textrm{Socrates can be killed}}
\end{prooftree}

Here, we can only use the $\frac{\textrm{Socrates is mortal}\quad\textrm{All mortals can be killed}}{\textrm{Socrates can be killed}}$ rule, as no other rule has a matching conclusion.
So, let's plug it in to our proof:

\begin{prooftree}
  \AxiomC{\textrm{Socrates is mortal}}
  \AxiomC{\textrm{All mortals can be killed}}
  \BinaryInfC{\textrm{Socrates can be killed}}
\end{prooftree}

We now have two more statements we need to prove; that Socrates is mortal, and that all mortals can be killed.
However, notice that the second statement is assumed as an axiom.
We can plug the axiom into our proof tree as follows:

\begin{prooftree}
  \AxiomC{\textrm{Socrates is mortal}}
  \AxiomC{}
  \UnaryInfC{\textrm{All mortals can be killed}}
  \BinaryInfC{\textrm{Socrates can be killed}}
\end{prooftree}

Since the axiom doesn't introduce any new unproven statements, we can move onto the remaining statement on the left.
Let's attack this statement with the original $\frac{\textrm{Socrates is a man}\quad\textrm{All men are mortal}}{\textrm{Socrates is mortal}}$ rule:

\begin{prooftree}
  \AxiomC{\textrm{Socrates is a man}}
  \AxiomC{\textrm{All men are mortal}}
  \BinaryInfC{\textrm{Socrates is mortal}}
  \AxiomC{}
  \UnaryInfC{\textrm{All mortals can be killed}}
  \BinaryInfC{\textrm{Socrates can be killed}}
\end{prooftree}

Now we have two holes.
Luckily, both of them correspond to axioms, so we can fill them in much like before:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\textrm{Socrates is a man}}
  \AxiomC{}
  \UnaryInfC{\textrm{All men are mortal}}
  \BinaryInfC{\textrm{Socrates is mortal}}
  \AxiomC{}
  \UnaryInfC{\textrm{All mortals can be killed}}
  \BinaryInfC{\textrm{Socrates can be killed}}
\end{prooftree}

We have no remaining statements to prove; therefore, we have a proof that Socrates can be killed!

## Types and Type Systems
The core concept behind a type system is to give every expression $e$ an associated type $t$ according to a pre-defined set of *typing rules*.

We'll call this association a *typing judgement*.
We'll write our typing judgement as $e : t$, and read it as "$e$ has type $t$", or "$e$ is a $t$".
Any expression that can be given a type, is then considered *valid*, or *well typed*.

As an example, let's consider a simple language, with just integer literals and the usual addition operator `+`.
Our only type will be $\texttt{Int}$, which represents the integers.

We'll have two typing rules:
1. Any integer literal has type $\texttt{Int}$.
\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\texttt{v : Int}}
\end{prooftree}

2. Given an expression $a + b$ (where $a$ and $b$ stand for sub-expressions, *not* variables), if both $a$ and $b$ have type $\texttt{int}$, then $a + b$ has type $\texttt{int}$.
   Here we're using Lisp syntax; we're ultimately trying to type Lisp programs, after all! 
\begin{prooftree}
  \AxiomC{\texttt{x : Int}}
  \AxiomC{\texttt{y : Int}}
  \BinaryInfC{\texttt{(+ x y) : Int}}
\end{prooftree}

Let's see some derivations for a few example expressions in this language.
First off, some plain literals.

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\texttt{1} : \texttt{Int}}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\texttt{42} : \texttt{Int}}
\end{prooftree}

Now let's apply addition to them:
\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\texttt{1} : \texttt{Int}}
  \AxiomC{}
  \UnaryInfC{\texttt{42} : \texttt{Int}}
  \BinaryInfC{\texttt{(+ 1 42)} : \texttt{Int}}
\end{prooftree}

Let's then add this to 100 in two different ways:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\texttt{1} : \texttt{Int}}
  \AxiomC{}
  \UnaryInfC{\texttt{42} : \texttt{Int}}
  \BinaryInfC{\texttt{(+ 1 42)} : \texttt{Int}}
  \AxiomC{}
  \UnaryInfC{\texttt{100} : \texttt{Int}}
  \BinaryInfC{\texttt{(+ (+ 1 42) 100)} : \texttt{Int}}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\texttt{100} : \texttt{Int}}
  \AxiomC{}
  \UnaryInfC{\texttt{1} : \texttt{Int}}
  \AxiomC{}
  \UnaryInfC{\texttt{42} : \texttt{Int}}
  \BinaryInfC{\texttt{(+ 1 42)} : \texttt{Int}}
  \BinaryInfC{\texttt{(+ 100 (+ 1 42))} : \texttt{Int}}
\end{prooftree}

{% include infobox.html
  align="start"
  header="Exercise 1"
  text="
  Write down a proof tree for the expression $\texttt{(+ (+ (+ 1 (+ 2 3)) (+ 4 5)) 6)}$.
  "
  color="success" align="center"
%}

Not all expressions can be given a type, however.

Let's extend our language to have booleans as well, given by the type $\texttt{Bool}$, and the terms $\texttt{true} : \texttt{Int}$ and $\texttt{false} : \texttt{Int}$.
We'll only consider addition to be meaningful when applied to two integers; trying to add two booleans, or a boolean and an integer will be considered an illegal operation.

Given the above system, what happens if we try to derive a type for the expression $1 + \texttt{true}$?

Pretty quickly, we'll reach the following state in our proof tree:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{\texttt{1} : \texttt{Int}}
  \AxiomC{\texttt{true} : \texttt{Int}}
  \BinaryInfC{\texttt{1 + true} : \texttt{Int}}
\end{prooftree}

We have no way of deriving $\texttt{true} : \texttt{Int}$, so we can't derive a type for the overall expression, and it's invalid according to our type system.
This is good news!
The fact that the system we've just come up with doesn't allow $1 + \texttt{true}$ means we've reached our goal of a type system that only allows meaningful programs.

## Lambda Types
So what types do we have available to us so far?

Naturally, we have all of the primitive types we've added; integers, floats, characters, strings, booleans, as well as any others you may have decided to add.
We'll refer to these as *ground* types, or *base* types.

But what type should lambdas have?

Lambdas as in this tutorial keep track of two types: the type of the argument, and the return type. We'll denote this as $\texttt{A -> B}$, where $\texttt{A}$ is the argument type and $\texttt{B}$ is the return type.
This is probably familiar to anyone with experience of a functional programming language like Haskell or OCaml.

Now that we have lambda types, we want to be able to introduce them, as we did before with base types.
Namely, we want to fill this hole:

\begin{prooftree}
  \AxiomC{???}
  \UnaryInfC{\texttt{(lambda (x) e)} : \texttt{A -> B}}
\end{prooftree}

To do this, we're going to use *type contexts*. 

### Type Contexts

Just as before where we used environments to store the *values* of variables, type contexts store the *types* of variables.

We'll also have a representation of type contexts in our inference system: 
1. $\cdot$ represents the empty type context, where there are no variables.
2. $\Gamma, \texttt{x} : t$ represents the environment $\Gamma$ being *extended* with the type mapping $\texttt{x} : t$ (given that $\texttt{x}$ isn't already in $\Gamma$). 
   Here you have available the variables of $\Gamma$, as well as the new variable $\texttt{x}$.
3. $\Gamma \vdash e : t$ means that you can produce the program expression $e$ under the type context $\Gamma$.

In general, we'll use $\Gamma$ to refer to a generic type context.

An example of point 3 is the rule for variables: if you have a variable $\texttt{x}$ of type $t$ in your type context, you can produce an expression $\texttt{x}$ of type $t$.
This allows you to use the mappings in your type context in derivations.

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\Gamma$, \texttt{x} : t $\vdash$ \texttt{x} : t}
\end{prooftree}

Adding a type context to our inference rules means that we also have to change the typing rules for integers. 
In particular, we need to say that we can introduce and add integers under any generic context $\Gamma$.

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\Gamma \vdash$ \texttt{v : Int}}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$\Gamma \vdash$ \texttt{x : Int}}
  \AxiomC{$\Gamma \vdash$ \texttt{y : Int}}
  \BinaryInfC{$\Gamma \vdash $ \texttt{(+ x y) : Int}}
\end{prooftree}

### Typing Lambdas

With all of this in place, we can now figure out how to introduce lambdas! In the body of a lambda, we can access all of the variables in the surrounding scope, as well as the parameter. 
As such, we can use context extension to represent the parameter of the lambda in our derivation, like so:

\begin{prooftree}
  \AxiomC{$\Gamma$, \texttt{x} : \texttt{A} $\vdash$ \texttt{e} : \texttt{B}}
  \UnaryInfC{$\Gamma \vdash$ \texttt{(lambda (x) e)} : \texttt{A -> B}}
\end{prooftree}

We also want to be able to beta-reduce these lambdas. This is more straightforward: we just need the lambda, the expression to apply it to, and the resulting expression will be of the return type.

\begin{prooftree}
  \AxiomC{$\Gamma \vdash$ \texttt{f} : \texttt{A -> B}}
  \AxiomC{$\Gamma \vdash$ \texttt{e} : \texttt{A}}
  \BinaryInfC{$\Gamma \vdash$ \texttt{(f e)} : \texttt{B}}
\end{prooftree}

Now we have everything we need to type functions! As an example, here's the derivation for $\texttt{(lambda (x) (+ x 1))}$.

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\cdot,$ \texttt{x} : \texttt{Int} $\vdash$ \texttt{x} : \texttt{Int}}
  \AxiomC{}
  \UnaryInfC{$\cdot,$ \texttt{x} : \texttt{Int} $\vdash$ \texttt{1} : \texttt{Int}}
  \BinaryInfC{$\cdot,$ \texttt{x} : \texttt{Int} $\vdash$ \texttt{(+ x 1)} : \texttt{Int}}
  \UnaryInfC{$\cdot \vdash$ \texttt{(lambda (x) (+ x 1))} : \texttt{Int -> Int}}
\end{prooftree}

{% include infobox.html
  align="start"
  header="Exercise 2"
  text="
  Write down a proof tree for the composition operator $\texttt{(lambda (f) (lambda (g) (lambda (x) (g (f x)))))}$.
  "
  color="success" align="center"
%}

{% include infobox.html
  align="start"
  header="Exercise 3"
  text="
  Try to figure out the typing rule for the $\texttt{def}$ keyword. If you're getting stuck, try to consider how $\texttt{def}$ and $\texttt{lambda}$ are similar. In particular, 
  $\texttt{(def x v) e == ((lambda (x) e) v)}$.
  "
  color="success" align="center"
%}

- TODO: quick note/ref to STLC

## Progress, Preservation and Type Safety
There's a well-known slogan for typed languages: "well-typed programs don't go wrong"! This notion is called *type safety*, and is an important property to prove to make sure that programs that start with no type errors stay with no type errors when they're evaluated.
It can come about from two properties of type systems: *progress* and *preservation*.

### Progress
Progress says that, for any well-typed expression $e : t$ in our language, either e is a value, or e evaluates *in one step* to some other expression $e^\prime$ in our language.

{% include infobox.html
  header="Aside on Proof Techniques"
  text="
  You can prove this statement using a technique called *structural induction*. 

  If you've done mathematical induction before, structural induction is a similar idea. 
  You can consider the natural numbers as a derivation tree like so:

  \begin{prooftree}
    \AxiomC{}
    \UnaryInfC{$0$ : $\mathbb{N}$}
  \end{prooftree}

  \begin{prooftree}
    \AxiomC{$n$ : $\mathbb{N}$}
    \UnaryInfC{$n + 1$ : $\mathbb{N}$}
  \end{prooftree}

  i.e. 0 is a natural number and, if $n$ is a natural number, $n + 1$ is also a natural number.

  To prove a property holds of the natural numbers, you prove the property holds in each case:
  1. Prove that it holds for 0.
  2. Assuming that it holds for a generic natural number $n$, prove that it holds for $n + 1$.

  Structural induction is just a generalisation of this for any kind of derivation tree. For each case, you assume the property holds for what's above the line, and prove the property holds for what's below the line.

  Since our typing rules are a derivation tree, you can prove things about them in this way.
  "
  color="info"
%}


- TODO: Do progress for one case.

### Preservation
Preservation says that, for any well-typed expression $e : t$ in our language, either e is a value, or e evaluates *in one step* to some other expression $e^\prime$ in our language.

Preservation is usually slightly more tricky than progress: you typically need some intermediate lemmas. 
In particular, *renaming* and *substitution* are lemmas you often need to prove.

Weakening is the idea that extending a context doesn't affect whether an expression produced by that context is well-typed. It can be formulated like this:

\begin{prooftree}
  \AxiomC{$\Gamma \vdash e : t_1$}
  \UnaryInfC{$\Gamma, x : t_2 \vdash e : t_1$}
\end{prooftree}

### Type Safety



## Convertibility
We'll need a notion for when two types are equivalent.
That is, if one type can be substituted for another, and still maintain soundness.
We'll call this notion *convertibility*, and say that two types are *convertible* if they satisfy convertibility.

Right now, for our current type system, convertibility is straightforward:
- Two ground types are convertible if they are directly equal. For example, `Int` is convertible only with `Int`.
- Two function types are convertible if and only if all of their arguments are pointwise convertible, and their return types are convertible. For example, `Int -> Bool -> String` is convertible only with `Int -> Bool -> String`.

You might notice that currently, our convertibility relation is just equality.
Once we add parametric polymorphism in the next step, convertibility will become a lot more complicated, so it's worth structuring our code this way from the beginning to minimise the amount of code restructuring we have to do.

## Checking and Inference
Given an expression `e` and a type `t`, can we check if `e` has type `t`?
Even better, given an expression, can we infer its type automatically?

It turns out for our type system, the answer to both of these questions is a definite yes!

We'll start with type inference first.
Let's call the inference function that we're implementing `infer`.
`infer` is structured similarly to `eval`; it works its way through the AST recursively, building up a context `gamma` associating names to types as it goes (instead of an environment `env` associating names to values).
You may notice that this is exactly the same thing we do when we work out proof trees for type derivations on paper!
<!-- TODO: should this be something a reader should notice, or should it be the explicit framing for why we're structuring the algorithm the way we do? -->

Let's see how it works on each different type of AST node we have.

For every literal `l` of some type `t`, `infer(l, gamma)` will return `t`.
This case is hardcoded for each type of literal.
For example:
- `infer(42, gamma)` returns `Int`.
- `infer("hello", gamma)` returns `String`.
- `infer(42.0, gamma)` returns `Float`.

Similarly, we'll need to hardcode types for each primitive operation.
For example, `infer(+, gamma)` returns `Int -> Int -> Int`.

For variables, `infer(v, gamma)` will look up the type of `v` in `gamma`.
If it finds a corresponding type for `v` in `gamma`, then it returns that; otherwise, it throws an error, claiming that `v` isn't in scope.

For function types, `infer` will take the arguments declared in the function, add them to the context, and then run `infer` on the body.
For example, `infer((lambda ((x Int) (y Int)) (+ x y)), gamma)` will call `infer((+ x y), gamma + (x, Int) + (y, Int))` to infer the type of the body. <!-- TODO: split into multiple ~~> lines like we did for eval -->
As far as type checking is concerned, there's no difference between a `rec` and a `lambda`, except for the fact that we have to make the type of

For function application, `infer` will infer the types of all of the arguments, and the type of the function in the head position.
If each of the argument types is convertible with the corresponding argument in the function's type, then `infer` will return the function's return type.
If any arguments aren't convertible with their corresponding argument type in the function, or if the expression in the head position isn't a function, `infer` will throw an error.

For example:
- `infer(((lambda ((x Int)) (+ x 1)) 1), gamma)` returns `Int`: the type of the lambda is `Int -> Int`, and the type of `1` is `Int`, so the arguments are convertible.
- `infer(((lambda ((x Int)) (+ x 1)) "hello"), gamma)` errors: `String` is not convertible with `Int`.
- `infer((1 2), gamma)` errors: `1` has type `Int`, which isn't a function type.

We've covered all types of AST node in our language, so we've fully described a type inference algorithm.
Now that we have inference, we can implement typechecking easily; just infer the type of `e`, and check if the inferred type is convertible with `t`.

## Task

Add a new data structure to represent types in your language.
It should support any primitives you've implemented (integers, boolean, strings etc.), as well as function types. 
If you've implemented multi-argument functions, think carefully about how you're going to type this.

You should also add a data structure for typing contexts, mapping names to types.

Update the syntax for `lambda` and `rec` to take the types of their arguments:

```scheme
(lambda ((x Int)) (+ x 1))
(lambda ((x Int) (y Int)) (+ x y))
```

Implement a function called `convertible`, which takes two types, and returns a boolean value indicating if the two types are convertible.

Using `convertible`, write another function called `infer`, which takes a typing context, and an expression, and attempts to infer the type of the expression within the context.

Update your REPL so that it uses `infer` to typecheck an expression before evaluating it.

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add a REPL command to infer the type of an expression:

  ```console
  MLTS> :t (lambda ((x Int)) (+ x 1))
  Int -> Int
  ```

- Add a REPL command that lets the user search for all available functions (i.e., those in the current environment) via their type, a la [Haskell's Hoogle](https://hoogle.haskell.org):

  ```console
  MLTS> :typesearch Int -> Int -> Int
  +
  -
  *
  /
  ```

- Add type level metavariables. These allow the user to specify an unknown type by using an underscore, which is then inferred by the typechecker:

  ```console
  MLTS> :t (lambda ((x _)) (+ x 1))
  Int -> Int
  ```

  NB: `_` is *not* an "any" type; it's simply a concrete type that should be inferred.
  You may need to restructure your type checker if you assume function arguments are always given a type annotation by the user.

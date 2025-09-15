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

When describing type systems, we make use of *inference rules*.
Inference rules are a way of expressing logical systems

$$
\frac{\textrm{Socrates is a man}\quad\textrm{All men are mortal}}{\textrm{Socrates is mortal}}
$$

This rule can be read in two ways:
- Top to bottom: If I know that Socrates is a man, and that all men are mortal, then I can infer that Socrates is mortal.
- Bottom to top: If I want to check that Socrates is mortal, then I must first check that Socrates is a man and that all men are mortal.

Which reading is more relevent depends on what you're trying to accomplish.
Often, with type systems, we usually read things from bottom to top.

<!-- TODO: explain proof trees -->

## Types and Type Systems
The core concept behind a type system is to give every expression an associated type, according to a pre-defined set of *typing rules*.
Any expression that can be given a type, is then considered *valid*, or *well typed*.

As an example, let's consider a simple language, with just integer literals and the usual addition operator `+`.
Our only type will be `Int`, which represents the integers.

We'll have two typing rules:
1. Any integer literal has type `Int`
2. Given an expression `a + b` (where `a` and `b` stand for sub-expressions, *not* variables), if both `a` and `b` have type `Int`, then `a + b` has type `Int`.
<!-- TODO: Give example derivations -->


Not all expressions can be given a type, however.
If we have an expression that, according to our pre-defined set of typing rules, cannot be given a type

- explain types in the abstract
- well-typed-ness
- progress
- preservation
- soundness

## MLTS Types
So what types do we have available to us so far?

Naturally, we have all of the primitive types we've added; integers, floats, characters, strings, booleans, as well as any other types you may have decided to add.
We'll refer to these as *ground* types, or *base* types.

But what type should lambdas have?

- introduce function types (rec and lambda)
- quiz on which terms are well typed
- quick note/ref to STLC

## Convertibility
We'll need a notion for when two types are equivalent.
That is, if one type can be substituted for another, and still maintain soundness.
We'll call this notion *convertibility*, and say that two types are *convertible* if they satisfy convertibility.

Right now, for our current type system, convertibility is straightforward:
- Two ground types are convertible if they are directly equal. For example, `Int` is convertible only with `Int`.
- Two function types are convertible if and only if all of their arguments are pointwise convertible, and their return types are convertible. For example, `Int -> Bool -> String` is convertible only with `Int -> Bool -> String`.

You might notice that currently, our convertibility relation is just equality.
Once we add parametric polymorphism, convertibility will become a lot more complicated, so it's worth structuring our code this way from the beginning to minimise the amount of code restructuring we have to do.

## Checking and Inference
Given an expression, can we check if it has a certain type?
Even better, given an expression, can we work out its type automatically?

It turns out the answer to these questions is a definite yes!
Or, at least it is for the simple type system we have currently.

- explain meanings of checking and inference.

- detailed inference algorithm walkthrough

Now that we have inference, we can implement checking if the expression `e` has type `t` easily; just infer the type of `e`, and check if it's the same type as `t`.

## Task

Add a new data structure to represent types in your language.
It should support any primitives you've implemented (integers, boolean, strings etc.), as well as function types.

You should also add a data structure for typing contexts, mapping names to types.

Update the syntax for `lambda` and `rec` to take the types of any arguments:

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

- Add a REPL command that lets the user search for all available functions via their type (a la [Haskell's Hoogle](https://hoogle.haskell.org)):

  ```console
  MLTS> :typesearch Int -> Int -> Int
  +
  -
  *
  /
  ```

- Allow the user to specify an unknown type by using an underscore:

  ```console
  MLTS> :t (lambda ((x _)) (+ x 1))
  Int -> Int
  ```

  NB: `_` is *not* an "any" type; it's simply a concrete type that should be inferred. You may need to restructure your type checker if you assume function arguments are always given a type annotation by the user.

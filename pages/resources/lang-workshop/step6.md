---
layout: page
title: "Step 6: Types | Language Workshop"
permalink: "/resources/lang-workshop/step6"
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

Currently, we handle these errors during evaluation.
By introducing a type system, we can instead catch such errors *before* evaluating an expression.
Crucially, this means we can reason about our programs without even running them, and we can use this to catch mistakes before they happen, to structure our code more clearly, and even to apply optimisations.

## Types and Type Systems
- explain types in the abstract, and progress/preservation

## MLTS Types
So what types do we have available to us so far?

Naturally, we have all of the primitive types we've added; integers, floats, characters, strings, booleans, as well as any other types you may have decided to add.
We'll refer to these as *ground* types, or *base* types.

But what type should lambdas have?

- introduce function types (rec and lambda)
- quiz on which terms are well typed

## Checking and Inference
- checking and inference

## Task

Add a new data structure to represent types in your language.
It should support any primitives you've implemented (integers, boolean, strings etc.), as well as function types.

You should also add a data structure for typing contexts, mapping names to types.

Update the syntax for `lambda` and `rec` to take the types of any arguments:

```scheme
(lambda ((x Int)) (+ x 1))
(lambda ((x Int) (y Int)) (+ x y))
```

Implement a new function, `infer`, which takes a typing context, and an expression, and attempts to infer the type of the expression within the context.

Update your REPL so that it uses `infer` to typecheck an expression before evaluating it.

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add a REPL command to inspect the type of an expression:

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

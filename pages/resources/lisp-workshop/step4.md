---
layout: page
title: "Lisp Workshop - Step 4: Enviroments"
permalink: "/resources/lisp-workshop/step4"
---

Complexity: Short

So, by now you've implemented an evaluator for simple arithmetic expressions (and maybe more, if you did the extra challenges).
But even as a calculator, our program is pretty limited! Consider the following program:
```scheme
42
(mod (pow 42 17) (* 61 53))
(mod (pow (mod (pow 42 17) (* 61 53)) (modmul-inv 17 (lcm (- 61 1) (- 53 1)))) (* 61 53))
```
Assuming correct definitions for `mod`, `pow`, `modmul-inv`, and `lcm`, the above is a demostration of encrypting and then decrypting the number 42 via [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)#Example). But you wouldn't know it!

Compare the above program to the one below. Both perform exactly the same computation. Which do you think is more readable?
```scheme
(define p 61)
(define q 53)
(define n (* p q))
(define ln (lcm (- p 1) (- q 1)))
(define e 17)
(define d (modmul-inv e ln))

(define m 42)
(define c (mod (pow m e) n))
(define m' (mod (pow c d) n))
m
c
m'
```

In this step, we're going to work towards extending our interpreter to allow the user to introduce their own definitions, much like in the above program.

## Top-Level Declarations
Based on the code example from the previous section, you probably have an intuitive understanding of how `define` should behave.
But we need to answer a few questions before our understanding is concrete enough to fully implement it.

First off: what does `define` evaluate to?

To answer this, we need to split S-Expressions in our language into two classes: *expressions*; and *declarations*.

An expression can be a literal or an S-Expression.
In particular, every expression gets evaluated to a particular *value*.
Critically, evaluating an expression does not change its surrounding context.

A declaration does not evaluate to a particular value. It doesn't evaluate to anything!
Instead, the effect of a declaration is that it introduces a new name for us to use during evaluation of other parts of the program.

For now, the only declaration we'll have is `define`, but the extra tasks in this chapter give a few more examples of declarations you might see in a functional language.

We'll also say that a declaration can only appear at the *top level* of a program, rather than as a sub-expression.
This means you can't do the following (whatever the definition of `foo` is):
```scheme
(foo (define two 2) two)
```
For clarity, we'll sometimes refer to declarations as *top-level declarations*.

## Environments
Our next question is: if each declaration introduces a new name, how do we keep track of them?

Simultaneously, we'll answer: how do we use these names when evaluating other parts of the program?

First, we'll need somewhere to keep track of all the things that the user defines.
We'll call such a structure the *environment*, or the *context*.
The environment is a map from names to values.

Notationally, we'll represent the context as a list, and an element as `name -> value`.
The order of elements in the list doesn't particularly matter for now.

Now, how do we use the names in the context?

Well, whenever we come across a symbol during evaluation, we can check to see if it's defined in our environment.
If it's in the environment, we can substitute the symbol with the corresponding value.

Let's walk through an example.
Say the user wants to run the following program:
```scheme
(define one 1)
(define two (+ one 1))
(+ one two)
```
We'll start off with an empty context, which we'll represent as the empty list: `[]`.

Next, we evaluate the top-level declaration `(define one 1)`.
We evaluate the expression `1` into the value `1`, and add `one -> 1` to our environment, which now looks like `[one -> 1]`.

Then, we evaluate the top-level declaration `(define two (+ one 1))`.
We need to evaluate `(+ one 1)`, which means evaluating `one`. To do so, we look up the name `one` in our context, and find that it maps to the value `1`, so we return `1`.
Our whole expression evaluates to `2`, so we add `two -> 2` to the environment, which now looks like `[one -> 1, two -> 2]`.

Finally, to evaluate `(+ one two)`, we look up the values of `one` and `two` in our context, resulting in `(+ 1 2)`, which evaluates to `3`.

## Shadowing
What should happen when we run the following program?
```scheme
(define one 1)
(define one 2)
one
```
Here, the second definition *overlaps* with the first.

There are three sensible options for output:
- Option 1: The interpreter throws an error when the user tries to redefine `one` on the second line;
- Option 2: The interpreter prints `1`, silently ignoring the second definition;
- Option 3: The interpreter prints `2`, updating the entry in the environment to `one -> 2`. Here, we say the newer definition *shadows* the older one.

What about this program?
```scheme
(define one 1)
(define number (+ one 1))
(define one 2)
one
number
```
Here, there are four possibilities:
- Option 1: The interpreter throws an error when the user tries to redefine `one` on the third line;
- Option 2: The interpreter prints `1` followed by `2`, silently ignoring the second definition;
- Option 3: The interpreter prints `2` followed by `2`. The new definition of `one` *shadows* the old one, and `number` still refers to the original definition of `one`.
- Option 4: The interpreter prints `2` followed by `3`. The new definition of `one` *replaces* the old one, and `number` now refers to the new definition of `one`.

All four make sense depending on the context, but option 2 might be quite confusing for the user if they expect the language to behave similarly to most common languages. We recommend you pick either option 1, option 3, or option 4. For the steps after this one, we'll assume that you're using option 3.

Also consider what behaviour your interpreter should exhibit on the following programs:
```scheme
(define plus +)
(define * plus)
```
(where `+` and `*` are primitives)
```scheme
(define rec 1)
(define rec rec)
rec
```

Your choice of behaviour for overlapping definitions may dictate which data structures you can use to represent your environment.

## Task
Define a new data type to represent the environment. This should look something like a map from symbols to values.

Update your `eval` function so that it takes an environment as an argument. When starting a new program, this environment should be empty.
If `eval` comes across a symbol, it should look up its value in the environment.
If it can't find it there, it should check if the symbol matches the name of a primitive.
If it doesn't, then it should throw an error.

You should also implement the function `define`.
`define` takes two arguments; a symbol `n`, acting as a name, and an expression, which is to be evaluated into a value `v`. Once evaluated, we should update our environment so that `n` maps to `v`.
`define` is a top-level declaration, meaning that it can only appear in the outer-most level of an expression tree, and doesn't return a value. The following lines are allowed:
```scheme
(define one 1)
(define secret (+ 8 (* 17 2)))
(define foo secret)
```
But these lines are not allowed:
```scheme
(id (define one 1))
(define program (define foo 123))
```
You may have to restructure your evaluator to support top-level declarations.

Finally, you should update your REPL to keep track of its environment, to allow the user to run top-level declarations in the REPL.

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add a basic import system: define another top-level declaration called `import`, which takes a filename; loads that file; evaluates all of the top level declarations stored in it; and extends the current environment with these declarations. For example, if `foo.lisp` contains the following:
```scheme
(define my-favourite-number 12)
```
  and `main.lisp` contains this program:
```scheme
(import "foo.lisp")
my-favourite-number
```
  then evaluating `main.lisp` should print `12`, assuming that `foo.lisp` is in the same directory as `main.lisp`.


- Allow top-level definitions to reference each other in any order. As an example, when running the following file:
```scheme
(define foo bar)
(define bar 1)
foo
```
  Your interpreter should output:
```scheme
1
```

- Add a namespace system. Namespaces allow you to keep different collections of definitions separate, ensuring that they don't interfere with each other if they happen to define the same name. You could implement namespaces by defining a new top-level declaration `namespace`, which takes a symbol `n` to use as a name for the namespace, and then an arbitrary number of other top-level declarations. Crucially, a namespace can contain other namespaces! When `namespace` is evaluated, it creates a new environment with all of the declarations in it, and stores this environment in our orginal environment, under the name `n`. You'll have to update your representation of environments (or values) to support namespaces.

  You should also add a way to access a name from a namespace. A decent way of doing so would be to define a function called `using`, which takes a symbol `n` representing the name of a namespace, and another symbol `d`, which refers to the name of a declaration within the namespace. The return value of this function is whatever value is assigned to `d` within the namespace. If `d` is not in the namespace, throw an error.

  For convenience's sake, you will also want to add `open`, which takes a symbol `n` and an expression `e`. To evaluate `(open n e)`, you should (temporarily) add all of the declarations in `n` to the current environment, and then evaluate `e` in this updated environment.

  For example, the following code:

  ```scheme
(namespace foo
  (define secret (+ 8 (* 17 2))))

(namespace int-monoid
  (namespace add
    (define unit 0)
    (defined op +))
  (namespace mul
    (define unit 1)
    (define op *)))

(using foo secret)
(using int-monoid (using add unit))
(open int-monoid ((using add op) 1 (using add unit)))
(open int-monoid (open mul (op unit 2)))
```

  should output:

  ```scheme
42
1
1
2
```

- Integrate your import system with your namespace system. Each file should be its own namespace. To improve user convenience, you could add a new keyword, `module`, which takes as its only argument a symbol `n`, representing the name of the namespace the rest of the file is under. The following two files should be exactly equivalent:
```scheme
(namespace foo
  (define secret (+ 8 (* 17 2)))
  (define x 1))
```
```scheme
(module foo)
(define secret (+ 8 (* 17 2)))
(define x 1)
```
  Now when a user `import`s the above file, it should add `foo` to the current environment. To use the definition, the user has to `open` the namespace provided. As another convenience aid, provide another keyword `load`, that combines `import` and `open`.

  You should also make the user specify exactly *which* definitions are to be exported. You could ask them to provide a list of names at the top of the namespace/module declaration, or make `define` take a "visibility" parameter (a symbol which can only take the value of `public` or `private`, for example).

  Finally, you should make it an error to `import` a file that doesn't declare exactly one namespace.

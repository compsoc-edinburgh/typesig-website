---
layout: page
title: "Step 6: Types | Language Workshop"
permalink: "/resources/lang-workshop/step6"
toc: true
---

Complexity: Medium

[Jump to task](#task)

In the previous step, you extended your language with functions.

Consider the following expression.

```scheme
(+ (lambda (x) x) 1)
```

What does it mean to perform addition between a lambda value and an integer literal?
This question doesn't even really make sense; lambas and integers are fundamentally different.
We'll capture this difference formally via a *type system*.

## Types and Type Systems

- motivate types more
- explain types in the abstract, and progress/preservation
- introduce ground/base types
- introduce function types (rec and lambda)
- checking and inference

I'm just testing website stuff here.

{% include question.html header="Types" text="Why are we adding types?" solution="Because they're pretty cool." %}
{% include question.html header="Question 2" text="Why are we adding types again?" solution="I said, because they're pretty cool." %}

{% include mcq.html
  header="Example Title"
  text="Which of the following are fruits?"
  options="Apple:Correct answer.;Carrot:Incorrect, it is a vegetable.;Banana:Correct answer.;Broccoli:Incorrect, it is a vegetable."
  correct_answers="Apple,Banana"
%}
  
{% include mcq.html
  header="No Correct Answers Specified"
  text="Which of the following are fruits?"
  options="Apple:Correct answer.;Carrot:Incorrect, it is a vegetable.;Banana:Correct answer.;Broccoli:Incorrect, it is a vegetable."
%}
## Task

Add a keyword to your interpreter, called `lambda`. It takes two arguments; an S-Expression containing a symbol `arg`, and an expression `body`.

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add a REPL command to inspect the type of an expression:

  ```console
  MLTS> :t (lambda ((x Int)) (+ x 1))
  Int -> Int
  ```

- Allow the user to specify an unknown type by using an underscore:

  ```console
  MLTS> :t (lambda ((x _)) (+ x 1))
  Int -> Int
  ```

  NB: `_` is *not* an "any" type; it's simply a concrete type that should be inferred. You may need to restructure your type checker if you assume function arguments are always given a type annotation by the user.

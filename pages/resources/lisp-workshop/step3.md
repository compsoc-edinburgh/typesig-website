---
layout: page
title: "Lisp Workshop - Step 3: Eval"
permalink: "/resources/lisp-workshop/step3"
---
# THIS PAGE IS A WORK IN PROGRESS!
The theory section isn't yet complete. If you're done with all of the extra tasks from the previous steps, and you're comfortable with a harder challenge, feel free to attempt the tasks here. If not, please be patient - we're working as hard as we can to get this finished!

## Evaluation
Complexity: Medium

*Evaluation* (or *eval* for short) can be viewed as a transformation acting on an AST. In particular, it transforms an *expression* into a *value*.


## Task
Define a data structure for an environment, that maps symbols to expressions.

Next, create an environment that defines some basic mathematical operators (like addition, multiplication, etc).

Now define a function called `eval`, which takes an environment and an AST as parameters, and reduces any redexes, returning the final AST.
Hook this into your REPL. You now have a fancy calculator!

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add some comparison operators, like equality and `<`. You'll have to come up with a representation for true and false! Common options are to have them as separate symbols, or to map false to 0 and true to any other value.

- Add some string manipulation functions, such as `concat`, `substring`, etc.

- Add some boolean functions, like `and` and `or`. For optimisation purposes, these should "short circuit"; if the first argument to `and` evaluates to false, the function should return false immediately, without evaluating the rest of its arguments.

- Implement `if`, which takes three arguments: a condition, which should evaluate to true or false, an expression to evaluate and return if the condition is true, and another expression for if the condition is false.

---
layout: page
title: "Lisp Workshop - Step 5: Lambda"
permalink: "/resources/lisp-workshop/step5"
---
# THIS PAGE IS A WORK IN PROGRESS!
The theory section isn't yet complete, and not all of the tasks have been added. If you're done with all of the extra tasks from the previous steps, and you're comfortable with a harder challenge, feel free to attempt the tasks here. If not, please be patient - we're working as hard as we can to get this finished!

## Lambdas
Complexity: Long

- capture avoiding substitution

## Task
If you haven't already, you should structure your interpreter so that the environment is passed as an argument to `eval`.

Add a special form to your interpreter, called `lambda`. It takes two arguments; a symbol `n`, and an expression `e`. When evaluating a lambda applied to an argument `v`, a lambda should add (`n`, `v`) to the environment when evaluating `e`.
```scheme
((lambda x (+ x 1)) 41)
--> (+ x 1)  [environment now contains (x, 42)]
--> (+ 41 1)
--> 42
```
Be sure to watch out for cases like `(lambda x (lambda x (+ x 1)))`! Make sure the inner `x` takes precedence over the outer `x`.

You should also implement top-level declarations: `(define name val)` should extend the global environment with (`name`, `value`). You should not allow this function to be called as part of a sub expression however!

Once this is done, you'll have implemented a fully Turing complete programming language! Congratulations!

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add support for let statements. In Lisp, these look like this:
```scheme
(let ((x 1)
        (y 2))
       (+ x y))
```
`let` takes two arguments: a list of pairs of symbols and expressions, and an expression. We're representing a list as an S-Expression with an arbitrary number of elements, and a pair as an S-Expression with exactly two elements. It's perfectly fine to hard-code this syntax into your evaluator.

Semantically, `(let ((x v)) e)` is equivalent to `((lambda x e) v)`, and `(let ((x1 v2) (x2 v2)) e)` is equivalent to `(let ((x1 v1)) (let ((x2 v2)) e)))`. We recommend that you directly desugar `let` expression in this way; it saves you from having to implement capture avoiding substitution again!

- Allow lambdas and top-level declarations to take multiple arguments.

Hint: desugar `(lambda (x y z) e)` into `(lambda x (lambda y (lambda z e)))`

- Support recursion in top-level definitions.

For example, when evaluating the following file:
```scheme
(define factorial (n)
    (if (equals? 0 n)
          1
          (+ n (factorial (- n 1)))))
(factorial 5)
```
you should see:
```scheme
120
```
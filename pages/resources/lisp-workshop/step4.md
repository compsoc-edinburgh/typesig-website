---
layout: page
title: "Lisp Workshop - Step 4: Lambad"
permalink: "/resources/lisp-workshop/step4"
---
# THIS PAGE IS A WORK IN PROGRESS!
The theory section isn't yet complete, and not all of the tasks have been added. If you're done with all of the extra tasks from the previous steps, and you're comfortable with a harder challenge, feel free to attempt the tasks here. If not, please be patient - we're working as hard as we can to get this finished!

## Lambda
Complexity: Medium


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

Once this is done, you'll have implemented a fully Turing complete programming language! Congratulations!

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add support for let statements. (Hint: `let x = v in e` is equivalent to `((lambda x e) v)`)

- Allow lambdas to take multiple arguments. (Hint: desugar `(lambda (x y z) e)` into `(lambda x (lambda y (lambda z e)))`)

- Add support for top-level declarations that take arguments.

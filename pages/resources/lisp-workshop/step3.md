---
layout: page
title: "Lisp Workshop - Step 3: Eval"
permalink: "/resources/lisp-workshop/step3"
---
# THIS PAGE IS A WORK IN PROGRESS! Things may change, so don't get too attached!
Complexity: Medium

*Evaluation* (or *eval* for short) can be viewed as a transformation acting on an AST. In particular, it transforms reducible expressions, or *redexes*, into some simpler form.
Changing the syntax and semantics of your language changes what you consider to be a redex.
For our language, we'll say that all redexes are S-Expressions, where the first expression is a symbol that corresponds to a function, or another redex that reduces to a function. The following expressions (if there are any) 
Here are a few examples of redexes in our language:
```scheme
(+ 1 2)
(* 3 4 5)
(list a b c)
(concat "hello, " (intToString 42) " world!)
((lambda x (+ x 1)) 41)
```
Some of these lines, namely the last two, contain multiple redexes. An individual expression within a redex may also be a redex itself!

Here are some things that *aren't* redexes:
```scheme
1
(2 3)
(4 + 5)
(3 (+ 1 2))
(some-undefined-symbol 1 2 3)
```
The last one is a little confusing; according to our definition above, it should count!

To explain why `(some-undefined-symbol 1 2 3)` isn't a redex, we need to talk about contexts.

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add some string manipulation functions.
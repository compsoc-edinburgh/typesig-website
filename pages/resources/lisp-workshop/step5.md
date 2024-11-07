---
layout: page
title: "Lisp Workshop - Step 5: Lambda"
permalink: "/resources/lisp-workshop/step5"
---
# THIS PAGE IS A WORK IN PROGRESS

The theory section isn't yet complete, and not all of the tasks have been added. If you're done with all of the extra tasks from the previous steps, and you're comfortable with a harder challenge, feel free to attempt the tasks here. If not, please be patient - we're working as hard as we can to get this finished!

Complexity: Long

[Jump to task](#task)

- motivation: simple arithmetical functions? reuse RSA from earlier?
- explain parameters/arguments
- explain application
- beta reduction
- closures
- rec

## Task

Add a keyword to your interpreter, called `lambda`. It takes two arguments; an S-Expression containing a symbol `arg`, and an expression `body`. When evaluating a lambda applied to a value `v`, a lambda should add `arg -> v` to the environment when evaluating `body`.

```scheme
((lambda (x) (+ x 1)) 41)
--> (+ x 1)  [add x -> 42 to env]
--> (+ 41 1)
--> 42  [drop x -> 42 from env]
```

Also add the keyword `rec`, which takes three arguments: a symbol `name`, an S-Expression containing a symbol `arg`, and an expression `body`. `rec` works similarly to lambda, but also adds `name -> rec name arg body` to the context when evaluating `body`.

```scheme
((rec fac (n) (if (= 0 n) 1 (* n (fac (- n 1))))) 3)
--> (if (= 0 n) 1 (* n (fac (- n 1))))  [add n -> 3, fac -> <[], rec fac (n) ...> to env]
--> (if (= 0 3) 1 (* n (fac (- n 1))))
--> (if false 1 (* n (fac (- n 1))))
--> (* 3 (fac 2))
--> (* 3 (if (= 0 n) 1 (* n (fac (- n 1)))))  [replace/shadow n -> 3 with n -> 2]
--> ...
--> (* 3 (* 2 (* 1 0)))
--> 6

Be sure to watch out for cases like `(lambda (x) (lambda (x) (+ x 1)))`! Make sure the inner `x` takes precedence over the outer `x`. As an example, `(((lambda (x) (lambda (x) (+ x 1))) 1) 2)` should evaluate to `3`, not `2`. Not convinced? Step through this problem on pen and paper by substituting the arguments one by one.

You should also extend your `define` function to accept the following form:

```scheme
(define func (arg) body)
```

which should be equivalent to:

```scheme
(define func (lambda (arg) body))
```

You can check the number of elements in a `define` expression to determine which form to use, or you couuld just offer the new form under a different name (`defun` is quite common). Both are perfectly sensible ways to implement this; think about which one you'd prefer to use when writing a program!

Once this is done, you'll have implemented a fully Turing complete programming language! Congratulations!

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add support for `let` expressions. `let` is convenient syntactic sugar for temporarily binding an expression to a name. In Lisp, these look like this:

  ```scheme
  (let ((x 1)
        (y 2))
      (+ x y))
  ```

  This expression should return:

  ```scheme
  3
  ```

  `let` takes two arguments: a list of pairs of symbols and expressions `((s1 e1) ... (sn en))`, and an expression `body`.

  To evaluate a `let` expression, you extend the current environment with `(s1 -> e1); ...; (sn -> en)`, and evaluate `body` in this new environment.

- Allow `lambda`s, `rec`s, and `define`s to take (and be applied to) more than one argument.

  For example:

  ```console
  lisp> ((lambda (x y) x) 1 2)
  1
  lisp> ((lambda (x y z) (+ x (+ y z))) 1 2 3)
  ```

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

- Write a self-hosting interpreter. This means re-implementing *everything* you've done so far as a program in your language.

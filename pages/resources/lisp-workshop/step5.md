---
layout: page
title: "Lisp Workshop - Step 5: Lambda"
permalink: "/resources/lisp-workshop/step5"
---
# THIS PAGE IS A WORK IN PROGRESS

The theory section isn't yet complete, and not all of the tasks have been added. If you're done with all of the extra tasks from the previous steps, and you're comfortable with a harder challenge, feel free to attempt the tasks here. If not, please be patient - we're working as hard as we can to get this finished!

Complexity: Long

[Jump to task](#task)

So far, we've implemented a basic evaluator that can compute arithmetical expressions and define new constants.
But to have a truly general purpose functional programming language, we need functions!

By the end of this step, you'll be able to run the following program:

```scheme
(define factorial (n)
  (if (= n 0)
      1
      (* n (factorial (- n 1)))))

(factorial 6)
```

## Parameterisation

What *is* a function?

You likely already have an intuitive understanding of what a function is.
You've almost certainly been using them to implement your interpreter, for example!
But we'll need a concrete understanding of functions if we ever wish to implement them correctly.

Functions allow us to minimise code duplication, by abstracting over common behaviour.
They do this by *parameterising* an expression by a value.
For example, consider the following toy program which checks some [Pythagorean triples](https://en.wikipedia.org/wiki/Pythagorean_triple):

```scheme
(= (* 5 5) (+ (* 3 3) (* 4 4)))
(= (* 13 13) (+ (* 5 5) (* 12 12)))
(= (* 97 97) (+ (* 65 65) (* 72 72)))
```

This program is very repetitive.
Each line is basically of the form `(= (* a a) (+ (* b b) (* c c)))`, where `a`, `b`, and `c` are the numbers in the Pythagorean triple we want to check.
We can retrieve the original program from this abstracted version simply by substituting values in for `a`, `b`, and `c`.
This combination of abstraction and substitution is known as *parameterisation*.
Functions as a language feature allow us to perform the parameterisation we just did above by hand inside of our programs mechanically.

For example, we could write the above example on Pythagorean triples as:
```scheme
(define square (n)
  (* n n))
(define check-pythagorean-triple (a b c)
  (= (square a) (+ (square b) (square c))))

(check-pythagorean-triple 5 3 4)
(check-pythagorean-triple 13 5 12)
(check-pythagorean-triple 97 65 72)
```

This version of the program has more lines of code, but I hope you'll agree that it's much easier to read!

## Lambdas

## Application and Beta Reduction

## Closures

## Recursion

### Aside on the Y Combinator

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
```

Be sure to watch out for cases like `(lambda (x) (lambda (x) (+ x 1)))`! Make sure the inner `x` takes precedence over the outer `x`. As an example, `(((lambda (x) (lambda (x) (+ x 1))) 1) 2)` should evaluate to `3`, not `2`. Not convinced? Step through this problem on pen and paper by substituting the arguments one by one.

You should also extend your `define` function to accept the following form:

```scheme
(define func (arg) body)
```

which should be equivalent to:

```scheme
(define func (lambda (arg) body))
```

This form should allow defining recursive functions.

You can check the number of elements in a `define` expression to determine which form to use, or you couuld just offer the new form under a different name (`defun` is quite common). Both are perfectly sensible ways to implement this; think about which one you'd prefer to use when writing a program!

Once this is done, you'll have implemented a fully Turing complete programming language! Congratulations!

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Allow `lambda`s, `rec`s, and `define`s to take (and be applied to) more than one argument.

  For example:

  ```console
  lisp> ((lambda (x y) x) 1 2)
  1
  lisp> ((lambda (x y z) (+ x (+ y z))) 1 2 3)
  ```

- Add support for `let` expressions. `let` is convenient syntactic sugar for temporarily binding an expression to a name. In Lisp, `let` expressions look as follows:

  ```scheme
  (let ((x 1))
      (+ x 2))
  ```

  This expression should return `3.
  It is equivalent to the Haskell code `let x = 1 in x + 2`.

  `let` expressions may give definitions to multiple symbols.

  ```scheme
  (let ((x 1)
        (y 2))
      (+ x y))
  ```

  In a Haskell-like syntax, you might write that as:
  
  ```haskell
  let x = 1 in
    let y = 2 in
      x + y
  ```

  Syntactically, `let` takes two arguments: a list of pairs of symbols and expressions `((s1 e1) ... (sn en))`; and an expression `body`.

  ```scheme
  (let ((s1 e1)
        ...
        (sn en))
      body)
  ```

  To evaluate a `let` expression, you extend the current environment with `s1 -> eval(e1), ..., sn -> eval(en)`, and evaluate `body` in this new environment.

- Add support for mutually-recursive functions. You will need to implement another language construct like `rec` which defines (at least) two functions at once, and extends the closure environment with `(f1 -> lambda args b1), ..., (fn -> lambda args bn)`.

- Write a self-hosting interpreter. This means re-implementing *everything* you've done so far as a program in your language. You may want to add some extra primitive datatypes to help you.

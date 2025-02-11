---
layout: page
title: "Step 5: Lambda | Language Workshop"
permalink: "/resources/lang-workshop/step5"
---

Complexity: Long

[Jump to task](#task)

So far, we've implemented a basic evaluator that can compute arithmetical expressions and define new constants.
But to have a truly general purpose functional programming language, we need functions!

In this step, we'll go over the theory of lambdas, and discuss how they can be implemented in an environment based interpreter.
By the end of this step, your interpreter will be able to run the following program:

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

Using this method to capture behaviour and abstract over values is known as *function abstraction*, and is a special form of a more general process known as *parameterisation*.
Parameterisation is one of the core tools of programming language theory, as it allows us to work with entire (infinite!) families of programs at a time, rather than just specific arbitrary programs.

Functions as a language feature allow us to perform the function abstraction we just did above by hand inside of our programs mechanically.
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

## The Lambda Calculus

So how can we represent function abstraction within our language?

Well, as mentioned above, functions are a language feature, which means we'll need to add new primitives and eval rules.

There are many different ways to represent functions, but one method that is common amongst functional languages is to base your system on the lambda calculus.
Lambda calculus was described in 1936 by Alonzo Church, and was shown to be a universal model of computation by the Church-Turing thesis.
In short, the Church-Turing thesis says that any function that can be computed by a Turing machine can be computed via the lambda calculus, and vice versa.

You can find a detailed explanation of the lambda calculus in several of the courses taught in Edinburgh, namely Introduction to Theoretical Computer Science, and Types and Semantics of Programming Languages.
We'll skip over a lot the theory, and focus on what's important for implementation.
But if you find this step interesting, you should definitely consider taking these courses; there are very rich connections between the lambda calculus and the fields of logic, mathematics, category theory, and computation.

Here's a minimal description of the (untyped) lambda calculus.

The syntax for terms is as follows:

```ebnf
t ::= x       Variables
      λx. t   Lambda Abstraction
      t₁ t₂   Function Application
```

And we have one important reduction rule, called beta:

```
(λx. b) a   ⊢β→   b [x := a]
```

The `b [x := a]` means "substitute `a` for `x` in the term `b`".
Substitution is notoriously quite conplicated to define, but the gist is that you replace all occurences of the variable name `x` in the term `b` with the term `a`.
This process is what we described above!
That's a fairly good hint that this method of function abstraction suits our purposes.

## Implementing Lambdas

So, we've decided lambdas are a good abstraction to use to represent functions.
How can we represent them in our interpreter?

If we check the syntax from the previous section, we notice that a lambda is a pair of a name and an expression.
Converting that into our S-Expression syntax, we might end up with the following:

```scheme
(lambda (x) b)
```

Here, `x` is a symbol that corresponds to the name bound by the lambda, and `b` is an expression that corresponds to the body of the lambda.
The extra brackets around `x` aren't strictly necessary, but they'll simplify your parsing rules if you allow lambdas to take multiple arguments (see the extra tasks).

Let's look at a few examples of lambda expressions in our syntax.

The expression `(lambda (x) x)` takes an argument named `x`, and returns it immediately.
This function is known as the identity function.

The expression `(lambda (x) 42)` takes an argument named `x`, ignores it, and returns 42.
Such functions are known as constant functions.

The expression `(lambda (x) (+ x 1))` takes an argument `x`, and adds 1 to it.

The expression `(lambda (f) (f 42))` takes an argument `f`, and evaluates it on 42.

The expression `(lambda (x) (lambda (y) (+ x y)))` takes one argument `x`, and returns a lambda expression that takes an argument `y` and adds it to `x`.
For intuition, this construction is the same as a function that takes two arguments, `x` and `y`, and adds them.

The expression `(lambda (x) (lambda (x) (+ x 1)))` takes an argument `x`, and returns a lambda which takes an argument `x` (shadowing the previous binding), and adds 1 to this inner argument `x`.

We'll also introduce a new value type to represent the result of evaluating a lambda by itself.
It will consist simply of a symbol paired with an expression, and for clarity, we'll denote it as `lambda x. b`.

Now, how should we interpret a lambda expression?

Above, we gave a way to interpret the expression `((lambda (x) b) a)` via substitution.
Effectively I said that to evaluate `((lambda (x) b) a)`, you evaluate `b`, but replace occurences of the symbol `x` with `a`.
This is something we can already do!
In the previous step, we implemented environments.
We can re-use our environments to interpret lambda expressions, by giving the following semantics: to evaluate `((lambda (x) b) a)` in the environment `env`, evaluate `b` in the environment `env + (x -> a)`.

Here's an example to illustrate how this works:

```scheme
((lambda (x) (+ x 1)) 41)
--> (+ x 1)  [x -> 41]
--> (+ 41 1)
--> 42
```

## Closures

Let's say we have the following program:

```scheme
(define addCurry (lambda (x) (lambda (y) (+ x y))))
(define add1 (addCurry 1))
(add1 41)
```

We need to keep track of the assignment $x -> 1$ when we define `add1`.
Otherwise, we'd return `(lambda (y) (+ x y))`, without having a binding for `x`; when we later try to look up `x`, we'll have to throw an error!

We can solve this problem by introducing *closures*.
A closure is a new value type, that consists of a function value paired with its surrounding environment.
We'll denote them using curly brackets: `{v, env}` represents the value `v` paired with the  environment `env`.

Take, for example, the expression `(lambda (x) (+ x 1))`.
At the top level, it consists of a single, unapplied lambda expression.
Evaluating this expression in the environment `env` would produce the closure `{lambda x. (+ x 1), env}`.
As a more concrete example, in the program from above, `add1` would be represented as `{lambda y. (+ x y), [x -> 1]}`.

Now, we'll update our logic for applications to use closures instead of function values directly.

Take the closure `{lambda x. (+ x 1), env}` from earlier.
If we're applying this closure to the value `41`, then we'd extend `env` with `x -> 41`, and evaluate `(+ x 1)` in this new environment.

## Recursion

We have anonymous functions now, and we can use `define` to give them names.
But we can't use this to do recursion yet!

Recall that our environment maps symbols to *values*.
That means, in order to add `n -> e` to our context, where `e` is an expression, we need to know what `e` evaluates to.
But if `e` references `n`, then `e` can't be evaluated without knowing what `n` refers to.
We have an infinite loop!

To avoid this cycle, we need to add a new language feature to represent recursive functions, separately from lambdas.
We'll call it `rec` (other texts may call it `letrec`).
The idea is that we'll give our anonymous function a name, and add that name to the environment as well as the argument when evaluating the body.≈

Syntactically, `rec` looks a lot like `lambda`, except it takes an extra name parameter `f`: `(rec f (x) (+ x 1))`. As with lambdas, we'll need a new value type for rec, which we'll denote as `rec f x. b`.

A `rec` expression evaluates to a closure much like `lambda`, except when applying the closure to a value `v`, we extend the closure's environment with both `f -> rec f x. (+ x 1)` and `x -> v`.

For example, evaluating `(rec f (x) (+ x 1))` in the environment `env` results in the closure `{rec f x. (+ x 1), env}`. Applying this closure value to the literal value `41`

```scheme
((rec f (x) (+ x 1)) 41)
--> ({rec f x. (+ x 1), env} 41)
--> (+ x 1)  [f -> rec f x. (+ x 1), x -> 41]
--> 42
```

We haven't actually used `f` in this definition, since we haven't defined any control flow operators like `if`.
As a result, it's difficult to write anything that isn't an infinite loop with this.

If you haven't done so already, we recommend doing some of the extra challenges from step 3 at this point; if you've already implemented lambdas, you should find them straightforward by this point, and while the extra operations technically don't add any computational power to the language, they certainly make things easier to write!

### Aside on the Y Combinator

Earlier, we stated that lambdas on their own can't be used to implement recursion.
This was a lie.
The Y combinator allows general recursion, and can be defined purely in terms of lambda expressions.

However, we can't use *direct* recursion with the Y combinator, since the name of our function isn't in scope.
Instead, any time we want to write a recursive function, we need to make it take an extra "self" parameter, which it calls whenever it would normally call itself.
The Y combinator, when applied to a function, passes the function to itself as the "self" parameter.

It works, but it's annoying to write, and pretty much every common language defines language features to enable direct style recursion.
For this reason, we decided to add `rec` as a language primitive.
If you want, you can skip it in your implementation, but it's your funeral.

## Task

Add a keyword to your interpreter, called `lambda`. It takes two arguments; an S-Expression containing a symbol `arg`, and an expression `body`.

Add value types for lambdas and closures.

Evaluating a lambda on its own should produce a closure with the surrounding environment.
When evaluating a closure `{lambda (arg) b, env}` applied to a value `v`, add `arg -> v` to `env`, then evaluate `body` in this new environment.

```scheme
((lambda (x) (+ x 1)) 41)
--> (+ x 1)  [add x -> 42 to env]
--> (+ 41 1)
--> 42  [drop x -> 42 from env]
```

Also add the keyword `rec`, which takes three arguments: a symbol `name`, an S-Expression containing a symbol `arg`, and an expression `body`.
`rec` works similarly to lambda, but also adds `name -> rec name arg body` to the context when evaluating `body`.

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

Be sure to watch out for cases like `(lambda (x) (lambda (x) (+ x 1)))`!
Make sure the inner `x` takes precedence over the outer `x`. As an example, `(((lambda (x) (lambda (x) (+ x 1))) 1) 2)` should evaluate to `3`, not `2`.
Not convinced? Step through this problem on pen and paper by substituting the arguments one by one.

You should also extend your `define` function to accept the following form:

```scheme
(define func (arg) body)
```

which should be equivalent to:

```scheme
(define func (lambda (arg) body))
```

This form should allow defining recursive functions.

When determining whether to use this `define` form or the one introduced in the previous step, you can either check the number of elements in a `define` expression to determine which form to use, or you couuld just offer the new form under a different name (`defun` is quite common).
Both are perfectly sensible ways to implement this; think about which one you'd prefer to use when writing a program!

Once this is done, you'll have implemented a fully Turing complete programming language! Congratulations!

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Allow `lambda`s, `rec`s, and `define`s to take (and be applied to) more than one argument.

  For example:

  ```console
  MLTS> ((lambda (x y) x) 1 2)
  1
  MLTS> ((lambda (x y z) (+ x (+ y z))) 1 2 3)
  6
  ```

- Add support for `let` expressions. `let` is convenient syntactic sugar for temporarily binding an expression to a name. In Lisp-like syntax, `let` expressions look as follows:

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

  Test this by implementing a recursive function that computes the nth Fibonacci number.

- Write a self-hosting interpreter. This means re-implementing *everything* you've done so far as a program in your language. You may want to add some extra primitive datatypes to help you.

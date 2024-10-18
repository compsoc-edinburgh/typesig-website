---
layout: page
title: "Lisp Workshop - Step 3: Eval"
permalink: "/resources/lisp-workshop/step3"
---

Complexity: Medium

So far, all we've worked on is *syntax*; surface-level properties of a language that define how it looks. But we've yet to define any *semantics* for our language, meaning that we can't yet do anything meaningful with our AST. We're about to change that by implementing *evaluation*.

Evaluation (or *eval* for short) can be viewed as a transformation acting on an AST. In particular, it *reduces* an *expression* into a *value*. An expression that can be transformed into a value is called a *reducible expression*, or *redex*.

## Values

So what is a value? The exact set of things that are considered to be values is specific to each language. For our language, we'll consider the following to be values:

- Literals (integers, floats, strings, etc);
- Primitive functions (functions that are implemented by in the evaluator, as opposed to defined by the user);
- Lambda expressions (you'll meet these in step 5).
That's it!

Here are some things that *aren't* values:

- A symbol literal
- Any expression that hasn't been evaluated yet (including expressions that are just literals, such as `5`!)

In your implementation, you will need to add a new data type for values, separate from expressions. For example, if you were using Haskell, you might define a type that looks like this:

```hs
data Prim = Plus | Minus | Mult | ...
data Value = VInt Integer
           | VPrim Prim
```

## Semantic Validity

Not every expression can be transformed into a value. Some programs are syntactically correct, but semantically meaningless! As an analogy, consider the English sentence "The sky walks a hamburger". This sentence is syntactically valid according to the rules of the English language, being a noun phrase followed by a verb and another noun phrase, but (in pretty much any context) it's meaningless!

The same principle applies in programming languages.
In Lisp languages, an S-Expression must start with a operator for it to be considered a redex.
Any S-Expression that doesn't is considered to be semantically invalid. This form of notation is commonly called [prefix (or Polish) notation](https://en.wikipedia.org/wiki/Polish_notation).
Additionally, if the type and number of the arguments don't match what the operator expects, the S-Expression isn't valid either.

For our language, by "operator" we mean any expression which evaluates to a *function value*. For now, this just means expressions that evaluate to primitives.

For example, the following lines of code are semantically valid under this definition:

```scheme
(+ 1 2)
(lambda x (+ x 1))
(foo)
((id +) 1 2)    
```

But the following are meaningless:

```scheme
(1 2)
(3 + 4)
()
(+ 1)
```

The above assumes that `+`, `lambda`, `foo`, and `id` are all defined as functions in our language, and that `id` just returns its argument.

Now we have five cases to deal with when evaluating an expression. Our expression could be one of:

- A literal, which can be converted directly to a literal value;
- A symbol which matches the name of a primitive, which can be replaced with the primitive as a value;
- Any other symbol, in which case we should throw an error;
- A semantically valid S-Expression, which we can keep evaluating;
- A semantically invalid S-Expression. In this case, we should throw an error.

Of these cases, two are invalid. The remaining three can be reduced, and thus are redexes.

## Reduction

So, we've given a definition for a redex in our language. But how do we actually reduce one?
Let's go through each case.

As mentioned above, if we have a literal expression, then this can be directly reduced to a literal value.
In other words: we take it as an axiom that a literal value evaluates to itself.

Now let's examine the case where we have a symbol which matches the name of a primitive.
For now, let's imagine that we have addition and multiplication as primitives. We'll say that the corresponding names are `+` and `*`.
Then, if our expression is the term `LSym "+"`, we can reduce it to the value `VPrim Plus`.

Finally, we're left with the case of the semantically valid S-Expr.
As a reminder, this means an S-Expr where the first element evaluates to a function value.
So far, our only function values are primitives.
We just need to evaluate the operator and its arguments, and check that the types line up.
If they do, then we can perform the operation that corresponds to our primitive in our host language.

For example, let's say that `+` corresponds to addition, and takes exactly two integers as its arguments.
To evaluate `(+ 1 2)`, we check that the types line up: they do!
All we need to do is compute `1 + 2` in our host language, and put the result into our value datatype.

## Evaluation Strategy

But wait!
Which do we evaluate first; the operator, or its arguments?

The order in which we evaluate an expression is known as our *evaluation strategy*.
Evaluating the function first and then the arguments is known as *normal order* or *non-strict* evaluation, and vice versa is known as *applicative order* or *strict* evaluation.
Both are fine choices, and thanks to the [Church-Rosser theorem](https://en.wikipedia.org/wiki/Church%E2%80%93Rosser_theorem), we'll end up with the same result, regardless of which evaluation strategy we choose.
That's not to say the choice doesn't matter!

### Applicative Order

Applicative order is likely what you are most familiar with, as it's used by most common languages, including the C family, Python, JavaScript, Rust, and many more.
You simply evaluate your arguments to values, and apply the function to the resulting values.

You also need to pick the order in which to evaluate the arguments.
This is completely up to you, as there's no difference if one argument gets evaluated before another.
In these worksheets, we'll stick to evaluating our arguments from left to right, to keep our examples clear.

Let's walk through some examples of evaluating
If we had the term `(+ 1 (* 2 3))`, it would reduce as follows:

```scheme
(+ 1 (* 2 3))
--> (+ 1 6)
--> 7
```

If we had the term `(+ (+ 1 2) (+ 3 4))`, it would reduce as follows:

```scheme
(+ (+ 1 2) (+ 3 4))
--> (+ 3 (+ 3 4))
--> (+ 3 7)
--> 10
```

And if we had `((+ 1 2) (* 3 4))`, our (attempted) reduction would look like this:

```scheme
((+ 1 2) (* 3 4))
--> ((+ 1 2) 7)
--> (3 7)
--> Error: 3 is not a function!
```

The primary advantage of applicative order over normal order is that it's easier to reason about the performance of applicative order code.

### Normal Order

Normal order is less frequently seen in commonly used languages. The main examples are Haskell, and, of all things, R.
Normal order gets its name from the lambda calculus, where normal order evaluation is guaranteed to result in the normal form of an expression, if one exists. The same is not guaranteed of applicative order.
To illustrate this, let's take the following two lambda calculus expressions (written in our Lisp syntax):

```scheme
(lambda x (lambda y x))
((lambda x (x x)) (lambda x (x x)))
```

The first expression returns takes two arguments, and returns the first one, ignoring the second.
The second expression is called the Omega combinator, and reduces to itself, looping forever.

Now consider the following expression:

```scheme
((lambda x (lambda y x)) 1 ((lambda x (x x)) (lambda x (x x))))
```

With applicative order, we evaluate the arguments first.
`1` of course evaluates to itself, but the Omega combinator will cause our evaluator to loop forever! We won't ever manage to return a result.

With normal order, we evaluate the operator first, and then substitute the arguments in directly as expressions.
This strategy never forces the Omega combinator to be evaluated in this expression, and will simply return 1 without looping forever.

### Which to pick?

As mentioned, both evaluation strategies are valid options. You can pick either of them, but the remainder of this course will assume you've chosen applicative order, and evaluate the arguments from left to right.

We've finally defined everything we need to implement an evaluator!

## Task

Choose a set of arithmetic operations to be your primitives, and define a data structure that represents values in your language (literals and primitives).
This should look something like the following Haskell type:

```hs
data Prim = Plus | Minus | Mult | ...
data Value = VInt Integer
           | VPrim Prim
```

Next, define a function called `eval`, which takes an AST as its only parameter, and reduces any redexes, returning the resultant value.

Update your REPL function, by running `eval` on the parsed input, and passing the resulting value into `print`. You now have a fancy calculator!

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add some comparison operators, like equality and `<`. You'll have to come up with a representation for true and false! Common options are to have them as separate symbols, or to map false to 0 and true to any other value.

- Add some string manipulation functions, such as `concat`, `substring`, etc.

- Implement `input` and `print`. `input` should return a line of input from the user, and `print` should print a value to the console.

  As a quick aside, implementing these transforms our language from a *pure* functional language into an *impure* functional language. This means we lose referential transparency: the property that evaluating a given expression always produces the same result! For our purposes, this isn't so bad. If you want a *real* challenge, try and implement these functions in a way that doesn't break referential transparency! You might want to take inspiration from languages like Haskell, which uses monads for side effects, or languages like Koka, which uses algebraic effects instead. (And don't get discouraged if you find this difficult; it's a large open research problem!)

- Add some boolean functions, like `and` and `or`. For optimisation purposes, these should "short circuit"; if the first argument to `and` evaluates to false, the function should return false immediately, without evaluating the rest of its arguments.

- Implement `if`, which takes three arguments: a condition, which should evaluate to true or false, an expression to evaluate and return if the condition is true, and another expression for if the condition is false.

- Add a step debugger; this should be a command-line flag that puts your interpreter into a mode which lets you step through evaluation one reduction at a time. Additionally add a command to your REPL, that lets the user run e.g. `:debug (+ 1 (* 2 3))` to step through the provided expression.

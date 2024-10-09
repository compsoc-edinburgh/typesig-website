---
layout: page
title: "Lisp Workshop - Step 3: Eval"
permalink: "/resources/lisp-workshop/step3"
---
# THIS PAGE IS A WORK IN PROGRESS!
The theory section isn't yet complete. If you're done with all of the extra tasks from the previous steps, and you're comfortable with a harder challenge, feel free to attempt the tasks here. If not, please be patient - we're working as hard as we can to get this finished!

## Evaluation
Complexity: Medium

So far, all we've worked on is *syntax*; surface-level properties of a language that define how it looks. But we've yet to define any *semantics* for our language, meaning that we can't yet do anything meaningful with our AST. We're about to change that by implementing *evaluation*.

Evaluation (or *eval* for short) can be viewed as a transformation acting on an AST. In particular, it *reduces* an *expression* into a *value*. An expression that can be transformed into a value is called a *reducible expression*, or *redex*.

## Values
So what is a value? The exact set of things that are considered to be values is specific to each language. For our language, we'll consider the following to be values:
- Literals (integers, flaots, strings, etc);
- Lambda expressions (you'll meet these in step 4).
That's it!

In your implementation, it's a good idea to add a new data type for values, separate from expressions. Your `eval` function should then convert an expression into a value.

## Semantic Validity
Not every expression can be transformed into a value. Some programs are syntactically correct, but semantically meaningless! As an analogy, consider the English sentence "The sky walks a hamburger". This sentence is syntactically valid according to the rules of the English language, being a noun phrase followed by a verb and another noun phrase, but (in pretty much any context) it's meaningless!

The same principle applies in programming languages. In Lisp languages, an S-Expression must start with a operator for it to be considered a redex. Any S-Expression that doesn't is considered to be semantically invalid. This form of notation is commonly called (prefix (or Polish) notation)[https://en.wikipedia.org/wiki/Polish_notation].

For our language, by "operator" we mean either a symbol that refers to a function defined in our program, standard library or as a keyword in our interpreter, *or* any expression that evaluates to a function. 
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
```
The above assumes that `+`, `lambda`, `foo`, and `id` are all defined as functions in our language.

Now we have three cases to deal with when evaluating an expression. Our expression could be one of:
- A literal value, which is already a value;
- A semantically valid S-Expression, which we can keep evaluating;
- A semantically invalid S-Expression. In this case, we should throw an error.

The above set of rules amounts to a property of a language called *progress*. If your language has progress as a property, then it means that all semantically valid expressions eventually evaluate to a value.

## Reduction
So, we've defined a redex to be an S-Expression that begins with an operator. But how do we actually reduce it?

Perhaps unsurprisingly, correctly defining reduction rules isn't the most straightforward thing in the world, even for simple languages.

Each operator will take a fixed number of arguments. This differs from some languages such as Python, which allow functions to take an arbitrary number of arguments. We'll work around this (in a more principled manner!) later on.

We'll need to hard-code a few operators into our evaluator. If we didn't have any hard-coded operators, then we wouldn't know how to reduce anything that isn't already a value! For now, we'll simply add some arithmetical functions.

For example, if we had the term `(+ 1 (* 2 3))`, it would reduce as follows:
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
--> (3 (* 3 4))
--> Error: 3 is not a function!
```


## Task
Define a data structure that represents values in your language (currently just literals).

Next, define a function called `eval`, which takes an AST as its only parameter, and reduces any redexes, returning the resultant values.

You should hard-code some arithmetic operators (addition, multiplication, etc) into this function. For example: if the first element in an S-Expression is a symbol, and that symbol is `+`, then you should add the two arguments together. Of course, if the arguments don't evaluate to integers, or there aren't exactly two arguments, you should throw an error.

Update your REPL function, by running `eval` on the parsed input, and . You now have a fancy calculator!

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add some comparison operators, like equality and `<`. You'll have to come up with a representation for true and false! Common options are to have them as separate symbols, or to map false to 0 and true to any other value.

- Add some string manipulation functions, such as `concat`, `substring`, etc.

- Implement `input` and `print`. `input` should return a line of input from the user, and `print` should print a value to the console.

- Add some boolean functions, like `and` and `or`. For optimisation purposes, these should "short circuit"; if the first argument to `and` evaluates to false, the function should return false immediately, without evaluating the rest of its arguments.

- Implement `if`, which takes three arguments: a condition, which should evaluate to true or false, an expression to evaluate and return if the condition is true, and another expression for if the condition is false.

- Add a step debugger; this should be a command-line flag that puts your interpreter into a mode which lets you step through evaluation one reduction at a time. Additionally add a command to your REPL, that lets the user run e.g. `:debug (+ 1 (* 2 3))` to step through the provided expression.

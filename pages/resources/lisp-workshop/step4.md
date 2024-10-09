---
layout: page
title: "Lisp Workshop - Step 4: Enviroments"
permalink: "/resources/lisp-workshop/step4"
---
# THIS PAGE IS A WORK IN PROGRESS!
The theory section isn't yet complete, and not all of the tasks have been added. If you're done with all of the extra tasks from the previous steps, and you're comfortable with a harder challenge, feel free to attempt the tasks here. If not, please be patient - we're working as hard as we can to get this finished!

## Enviroments
Complexity: Short

- introduce environment/context
- does the context have values or expressions?
- name shadowing

## Task
Define a new data type to represent the environment. This should look something like a map from symbols to values.

Update your `eval` function so that it takes an environment as an argument. When starting a new program, this environment should be empty.

You should also implement the function `define`.
`define` takes two arguments; a symbol `n`, acting as a name, and an expression, which is to be evaluated into a value `v`. Once evaluated, we should update our environment so that `n` maps to `v`.
`define` is a top-level declaration, meaning that it can only appear in the outer-most level of an expression tree, and doesn't return a value. The following lines are allowed:
```scheme
(define one 1)
(define secret (+ 8 (* 17 2)))
(define foo secret)
```
But these lines are not allowed:
```scheme
(id (define one 1))
(define program (define foo 123))
```
You may have to restructure your evaluator to support top-level declarations.

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Add a basic import system: define another top-level declaration called `import`, which takes a filename; loads that file; evaluates all of the top level declarations stored in it; and extends the current environment with these declarations. For example, if `foo.lisp` contains the following:
```scheme
(define my-favourite-number 12)
```
  and `main.lisp` contains this:
```
(import "foo.lisp")
my-favourite-number
```
  then evaluating `main.lisp` should print `12`, assuming that `foo.lisp` is in the same directory as `main.lisp`.


- Allow top-level definitions to reference each other in any order. As an example, when running the following file:
```scheme
(define foo bar)
(define bar 1)
foo
```
  Your interpreter should output:
```scheme
1
```

- Add a namespace system. Namespaces allow you to keep different collections of definitions separate, ensuring that they don't interfere with each other if they happen to define the same name. You could implement this by defining a new top-level declaration `namespace`, which takes a symbol `n` to use as a name for the namespace, and then an arbitrary number of other top-level declarations. Crucially, this can include other namespaces! When `namespace` is evaluated, it creates a new environment with all of the declarations in it, and stores this environment in our orginal environment, under the name `n`. You'll have to update your representation of environments to support this.

  You should also add a way to access a name from a namespace. A decent way of doing so would be to define a function called `using`, which takes a symbol `n` representing the name of a namespace, and another symbol `d`, which refers to the name of a declaration within the namespace. The return value of this function is whatever value is assigned to `d` within the namespace. If `d` is not in the namespace, throw an error.

  For convenience's sake, you will also want to add `open`, which takes a symbol `n` and an expression `e`. To evaluate `(open n e)`, you should (temporarily) add all of the declarations in `n` to the current environment, and then evaluate `e` in this updated environment.

  For example, the following code:
```scheme
(namespace foo
  (define secret (+ 8 (* 17 2))))

(namespace int-monoid
  (namespace add
    (define unit 0)
    (defined op +))
  (namespace mul
    (define unit 1)
    (define op *)))

(using foo secret)
(using int-monoid (using add unit))
(open int-monoid ((using add op) 1 (using add unit)))
(open int-monoid (open mul (op unit 2)))
```
  should output:
```scheme
42
1
1
2
```

- Integrate your import system with your namespace system. Each file should be its own namespace. To improve user convenience, you could add a new keyword, `module`, which takes as its only argument a symbol `n`, representing the name of the namespace the rest of the file is under. The following two files should be exactly equivalent:
```scheme
(namespace foo
  (define secret (+ 8 (* 17 2)))
  (define x 1))
```
```scheme
(module foo)
(define secret (+ 8 (* 17 2)))
(define x 1)
```
  Now when a user `import`s the above file, it should add `foo` to the current environment. To use the definition, the user has to `open` the namespace provided. As another convenience aid, provide another keyword `load`, that combines `import` and `open`.

  You should also make the user specify exactly *which* definitions are to be exported. You could do this by making them provide a list of names at the top of the namespace/module declaration, or by making `define` take a "visibility" parameter (this could be a symbol, which can only take the value of `public` or `private`, for example).

  Finally, you should make it an error to `import` a file that doesn't declare exactly one namespace.

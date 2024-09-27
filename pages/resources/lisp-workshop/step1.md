---
layout: page
title: "Lisp Workshop - Step 1: The Beginning"
permalink: "/resources/lisp-workshop/step1"
---
Complexity: Short

At each step of our journey, we want to end up with a usable program, so we can see how far we've come.
Our main way of interacting with our language interpreter is going to be via a REPL: a Read, Eval, Print Loop.
You might be familiar with this concept from other languages: the JavaScript console, Python interpreter and even the Bash command line are all REPLs!

We're going to start off small with a program that reads a line of input from the user, and responds by repeating the input back to the user.

Examples:
```
Hello, world!  // this line is user input
Hello, world!  // this line is program output
```

```
TypeSig <3 you!  // this line is user input
TypeSig <3 you!  // this line is program output
```

## Extra Challenges
These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete. None of them are required for a fully-functional interpreter. They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later. Depending on your language choice, they might be easier or harder than anticipated!

- Print a prompt to the console to indicate when the user should input text:
```console
lisp> 42
42
lisp>
```

- Add a command line flag to read a file as input, rather than a line from the user. When running in this mode, the program shouldn't loop after printing.
```console
sh$ echo "Hello, world!" > input.txt
sh$ ./step1 -f input.txt
Hello, world!
sh$
```

- Implement some commands that toggle useful features in the REPL. For example, the user could enter `:timing` as a command to have the REPL show how long each input took to run (currently, this example won't do much, but once the evaluator is implemented, it becomes very handy!)

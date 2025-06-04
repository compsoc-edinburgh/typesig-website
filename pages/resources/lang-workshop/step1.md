---
layout: page
title: "Step 1: The Beginning | Language Workshop"
permalink: "/resources/lang-workshop/step1"
---
Complexity: Short

[Jump to task](#task)

Welcome to step 1 of TypeSig's language workshop!

We'll walk you through designing your very own functional language, and implementing an interpreter for it.

At each step of our journey, we'll guide you through implementing a usable program, so you can see how far you've come.

## REPLs

In this step, we'll implement the basic code structure for a REPL.

A REPL is a program that does exactly four things in order: Read, Eval, Print, Loop.
- Read: The program asks the user to type in some input, which then (usually) gets parsed into a data structure that represents an expression of the language.
- Eval: Evaluation converts the expression the user gave into a value. For example, evaluating the expression `1 + 2` results in the value `3`.
- Print: The resulting value gets printed to the console, so the user can see it.
- Loop: The program loops back to the read step, asking the user for their next input. This process continues indefinitely, until the user asks the REPL to stop.

REPLs are a common way to interact with an interpreter; they let the user directly enter an expression, have the interpreter evaluate it, and the result printed back to them.
You might be familiar with REPLs from other languages: the JavaScript console, Python interpreter and even the Bash command line are all REPLs!


## Task

Write a program that reads a line of input from the user, and responds by repeating the input back to the user.
In other words, a REPL where our expression data structure is just a string, and our evaluation does nothing.

You'll need to use your language's functions for getting user input, and printing strings.
If you don't know what these are for your chosen language, you can probably find them via searching online.

You may want to implement this by storing the user's input into a variable, and then passing that variable into your language's `print` function.
This approach will make future steps easier to implement.

This program should work in a loop; in other words, once the string has been printed, the program should return to its initial state, asking the user for their input once again.

While it's not a particularly useful program yet, we've already laid the foundations for interacting with our interpreter.

## Tests

Here's some test cases that you can use to check if your implementation is along the right lines:

```plaintext
Hello, world!  // this line is user input
Hello, world!  // this line is program output
```

```plaintext
TypeSig <3 you!                // this line is user input
TypeSig <3 you!                // this line is program output
https://discord.gg/dnXzHRkJww  // this line is user input
https://discord.gg/dnXzHRkJww  // this line is program output
```

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete.
None of them are required for a fully-functional interpreter.
They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later.
Depending on your language choice, they might be easier or harder than anticipated!

- Print a prompt to the console to indicate when the user should input text:

  ```console
  MLTS> 42
  42
  MLTS>
  ```

- If the user enters `quit` or `exit` as their input, stop the loop.
  You should also print some text when starting the interpreter so your users know this is a possibility!

- Add a command line flag to read a file as input, rather than a line from the user.
  When running in this mode, the program shouldn't loop after printing.
  Effectively, this means your program will print the contents of the file, line by line.

  ```console
  sh$ echo "Hello, world!\nTypeSig is the best SIG!" > input.txt
  sh$ ./step1 -f input.txt
  Hello, world!
  TypeSig is the best SIG!
  sh$
  ```

- Implement some commands that toggle useful features in the REPL.
  For example, the user could enter `:timing` as a command to have the REPL show how long each input took to run (currently, this example won't do much, but once the evaluator is implemented, it becomes very handy!).

  Another example is `:help`, which should print a list of all commands the user can input (including the `quit`/`exit` commands from the earlier challenge).
  You could even add a command that lets the user customise the text and colour of the prompt.

- Add history to your REPL.
  The user should be able to press the up and down arrow keys to navigate through the previous inputs they gave.
  Up should go backwards through the history, and down should go forwards.
  Also, the user should be able to press Control-R to search through the history.

  These keybindings are fairly standard across command line inputs.
  You can try using them in your chosen language's REPL, or your system's command line.
  Your language (or its ecosystem) may provide a `readline` library, which should simplify implementing this.

---
layout: page
title: "Step 2: Parsing and Printing | Language Workshop"
permalink: "/resources/lang-workshop/step2"
---

Complexity: Long

## Table of Contents
{:.no_toc}

* toc dummy
{:toc}

## Motivation

In the last step, we wrote a program that could read a line of input as a string, and print that string out to the console.
While it's a good starting ground, it doesn't do anything particularly interesting.

Our first *real* step towards a language interpreter is a parser.
A parser converts a string into an *abstract syntax tree* (or AST); a data structure that represents the internal structure of expressions in our language.

## S-Expressions

All languages, even human languages, adhere to a *grammar*.
A grammar describes the *syntax*, or the textual representation, of a language; in English, for example, it's a grammatical error to have a verb follow another verb (`eat organise` isn't a valid English sentence).

Programming languages also adhere to a grammar.
Here, a grammar says how we're allowed to combine expressions to build larger expressions.
For example, `1 + 2` is composed of the literal expression `1`, the operator `+`, and the literal expression `2`.

{% include infobox.html
  text="
  It's important to note that we don't give any semantic meaning to these expressions yet.
  This means that `1 + 2` does *not* equal `2 + 1`; the two expressions are composed in different ways.
  "
  color="info" align="center"
%}

Natural languages tend to be *ambiguous*, meaning that there are sentences that cannot be parsed into exactly one parse tree.
For natural languages, this is a useful property, as it enables things like puns and poetry.

{% include infobox.html
  text="
  To illustrate this, try and figure out how many ways you can parse the English expressions "Superfluous hair remover" and "Programming language implementations".
  "
  color="success" align="center"
%}

For programming languages, however, it's less useful.
When we're talking to a computer, we want to be as exact about what we mean as possible!
As a result, when picking or designing a grammar for a programming language, we should always make sure that it's unambiguous.

To keep things simple for our language, we've opted for a very simple grammar, known as S-Expressions.
S-Expressions are known for their use in the Lisp family of programming languages, where they are sometimes called sexps.
We chose to use S-Expressions in particular as our grammer, since they give us a direct correspondence between the textual representation of our language and our internal representation.

An S-Expression consists of a pair of brackets, that contain a list of "atoms" separated by whitespace.
These atoms may be literal values, like numbers or strings, or symbols, which are arbitrary strings of characters.
You're also allowed to have another S-Expression in place of an atom, allowing you to build more complex programs.

In Lisp-like syntax, the first atom is used as a function or operator name, and the following atoms are provided as arguments to the function or operator.
Here's an example of some code written in this style:

```scheme
(+ 1 2)
(* 3 (- 4 5))
(concat3 "TypeSig" "<3" "you")
(lambda (x) x)
(define factorial (n) (if (= 0 n) 1 (* n (factorial (- n 1)))))
```

{% include mcq.html
  header="Exercise 1"
  text="Which of the following are valid S-Expressions?"
  options="`(factorial 6)`:This is a valid S-Expression.;`factorial 6`:This is not a valid S-Expression.
If you want to join multiple atoms into one expression, they must be in brackets.;`(factorial)`:This is a valid S-Expression syntactically.
It may not be a semantically valid program, but that doesn't affect its syntactic validity.;`factorial`:This is a valid S-Expression, consisting of the single atom `factorial`."
%}

You don't need to fully understand what the semantics of these mean yet!
We'll build up to that knowledge over the next few steps.
The syntax may look quite strange if you're used to popular languages like Python or JavaScript, but it's still expressive enough to represent any program.

We've picked S-Expressions other other grammars (say, C-style or Python-like grammars) because it's very straightforward to convert them into an AST.
In fact, they're already a textual representation of an AST!
To see what we mean by this, consider the following snippet:

```scheme
(+ 1 (* (- 2 3) 4))
```

This code corresponds to the following AST:

```plaintext
  sexp
 / | \
+  1  sexp
    /  |   \
   *  sexp  4
     / | \
    -  2  3
```

Each of the bracket pairs turns into a `sexp` node, and the atoms between the brackets turn into its children.

## Grammar

A parser operates according to a set of *parse rules*.
This set is known as a *grammar*.
You can learn about parsing in detail the courses IADS and Compiling Techniques, but we'll give a brief overview here to get you started.

We'll build up our grammar piece by piece.
First, let's just write a grammar that recognises some basic literals.

```ebnf
INTEGER ::= /[0-9]+/
SYMBOL  ::= /(^\s|\(|\))+/    // this just means no whitespace or brackets
Literal ::= INTEGER | SYMBOL
```

Here, we've defined two literal types: integers (whole numbers), and symbols (any string of characters that doesn't contain whitespace or brackets).
We've given regular expressions to describe valid strings that can be be parsed as these literals, although you don't necessarily need to use regex in your parser implementation.
Extending the grammar for more literals (for example, strings, floating point numbers, etc) is straightforward - we just add a new rule to the grammar.
For now, let's say our starting rule is `Literal`.
When trying to parse a string with this grammar, we'll first check
Currently, our grammar admits the following strings:

```scheme
1
hello
42
typesig-is-best-sig
137.5
```

(exercise: why does the last one work?)

It won't admit the following:

```scheme
hello world!
1 + 2
(* 3 4)
```

Once we've parsed one literal, the parse rules say there's nothing else for us to do, so we stop.
Let's update our parse rules to allow multiple expressions.
We'll add a new rule, called `Program`, which will be our starting rule from now on:

```ebnf
INTEGER ::= /[0-9]+/
SYMBOL  ::= /(^\s|\(|\))+/    // this just means no whitespace or brackets
Literal ::= INTEGER | SYMBOL
Program ::= Literal*
```

The new `Program` rule refers to `Literal`, but there's an `*` after it.
This symbol is called a *Kleene star*, and it means that we're looking for zero or more `Literal`s.
You might have seen similar syntax before if you've studied regular expressions.
We could replace it with a `+` if we wanted one or more `Literal`s, or a `?` if we wanted exactly zero or one.

By the way, we've not handled the fact that there needs to be whitespace between each literal.
We could replace our program rule with something like `Program ::= Literal | Literal \s Program`, which would do the trick, but for the sake of explanation and clarity, we'll leave it implicit.
We're going to use a sneaky trick later on to avoid having to worry about it anyways!

Now we admit the strings from above.
We've implemented a bunch of literals, but we haven't touched S-Expressions yet!
Let's move on to them now.
As mentioned above, an S-Expression is a pair of brackets, containing a list of expressions.
We'll say an *expression* is either an atom (a literal) or an S-Expression (with the brackets).
In other (more formal) words:

```ebnf
Expr    ::= Literal | '(' Expr* ')'
```

The `'('` just means we're checking our input for `(` as a character literal.

We're now ready to construct our full grammar:

```ebnf
INTEGER ::= /[0-9]+/
SYMBOL  ::= /(^\s|\(|\))+/    // this just means no whitespace or brackets
Literal ::= INTEGER | SYMBOL
Expr    ::= Literal | '(' Expr* ')'
Program ::= Expr*
```

All we've done is combine the S-Expression grammar with the earlier one, and made program admit a list of S-Expressions instead of literals.

## Lexing

It's perfectly possible to build a parser that operates directly on an input string, and that's the model we've operated under so far.
But, the task of parsing is usually simpler if we first convert our input string into a list of *tokens* — strings that are syntactically important to our grammar — and run our parser on that instead of a list of characters.
This process is called *lexing*, and a program that does lexing is called a *lexer*.
Luckily for us, lexing is straightforward for most grammars, and for S-Expressions in particular, there's a neat hack that does almost the whole thing for us!

Remember how most things in our syntax were whitespace separated?
The only real exception to this is the brackets delimiting an S-Expression.
Here's the hack: we can just loop through our input, and wherever we find a bracket, we can surround it with whitespace.
For example:
`(+ 1 (exp 2 3))` becomes `` ( + 1  ( exp 2 3 )  ) ``.
Now all we have to do is split our string on whitespace.
Your language probably already has support for this in its standard library: for most languages, it's something along the lines of `String.split()`.
For Haskell, there's a function called `words`.
Now we have a list of strings; our example from before has become `["(", "+", "1", "(", "exp", "2", "3", ")", ")"]`.
As you'll see later, our parsing logic will be *much* simpler thanks to our lexer.

## Abstract Syntax Tree

As mentioned before, our parser should convert a string into an AST.
But how do we represent an AST in code?
We'll make a custom data type for it.
Depending on your language, the exact mechanism you use to do so differs; you might use an algebraic data type for something like Haskell, a class for something like Python or Java, or a struct for something like Rust or C.
Our AST is going to have a similar structure to the one drawn above.
Here's how we might represent it in Haskell:

```hs
data Expr = LInt Integer
          | LSym String
          | SExpr [Expr]
          deriving (Eq, Show)
type Program = [Expr]
```

It's a good idea to keep your AST representation as flat as possible.
A simple AST makes writing your evaluator much more pleasant.
The above example keeps the literals and the S-Expressions at the same level, compared to the grammar, which had a separate rule for literals.
Here I've defined a type alias so I can call a list of `Expr`s a `Program`, but this is just for convenience.

## Parser

Now we need to actually write our parser.
A parser, as mentioned before, is a function from a string to an AST.
This type signature works in the abstract sense, but we'll need to keep our list of tokens accessible.
In OOP languages, you should probably make a class that has the token stream as a variable.
For a pure functional language like Haskell, we'll need to pass around our data explicitly.
This means our type actually looks more like `[String] -> (Expr, [String])` (remember that we're representing our token stream as a list of strings).

We'll use a top-down approach, which means we'll start by writing a parser for a `Program`, and work our way down to the smaller types.

A program, as defined by our grammar, is a list of top-level expressions.
Thus, our function to parse a program should repeatedly try and parse an expression from the token stream until there aren't any tokens left.
Once we've reached the end of the input, we should return the list of expressions we've built up.

Thanks to the work we did above with the lexer, each token in our stream can be one of three options: an open bracket `(`, a close bracket `)`, or some other string of characters (excluding whitespace and brackets).
Not convinced?
Go back to the lexer section, and see if you can find an input that would produce something else.

So how do we parse an expression?

As a reminder, our current grammar looks like this:

```ebnf
INTEGER ::= /[0-9]+/
SYMBOL  ::= /(^\s|\(|\))+/    // this just means no whitespace or brackets
Literal ::= INTEGER | SYMBOL
Expr    ::= Literal | '(' Expr* ')'
Program ::= Expr*
```

The current token at the front of our token stream contains everything we need to know.
If it's a `(`, then we're starting a new S-Expression, which we'll parse separately.
The S-Expression parser will handle the closing bracket, so if our token is `)` then we've found a syntax error in the input.
Now we know our current token must be a literal.
If we can convert the token from a string into an integer, then we'll say it's an integer literal.
Otherwise, it must be a symbol.

So far, so good; we can parse literals, and handle at least one form of syntax error.
All that's left is to parse S-Expressions.

The grammar rule for an S-Expression was `'(' Expr* ')'`.
We already know how to parse `(`, `)` and `Expr`, so all that's left is the `*`!
We already dealt with a similar situation when parsing the whole program, except here instead of stopping at the end of the input, we want to stop when our current token is a `)`.
If we *do* reach the end of the input before we find our `)`, then there must have been another syntax error!

With that, we should now be able to parse everything as dictated by our grammar!
We just need to put everything together, by writing a function that calls the lexer on our input, passes the result to our program parser, and then returns the parsed AST.

## Pretty Printing

We've spent most of this step implementing a way to go from strings to an AST.
While we're at it, we might as well write a function that goes the other way.
Such functions are called *pretty printers*, and are thankfully much easier to implement that parsers!

We'll make our program pretty printer put each top-level expression on its own line.
Then, for each expression:

- if it's an integer literal, convert the integer into a string
- if it's a symbol, then do nothing (it's already a string)
- if it's an S-Expression, then convert all of the expressions inside it to strings (recursion!), put whitespace between them, and surround them with brackets.

You should write make this function return a string, rather than immediately printing it to the console.

## 3/4ths of a REPL

We've implemented a parser, and a pretty printer.
It's time to update our REPL function from step 1!
We should pass the user's input into the parser, and pass the resultant AST into the pretty printer, and print the output to the console.

## **Task**

Implement a data structure for an AST.
If you're using a functional-style language, you may want to use an algebraic data type to do this; if you're in an OOP-style language, you may want to use classes instead.

Next, you should write the lexer, which converts an input string into a list of tokens.

Once the lexer is complete, write a parser that converts a list of tokens into the corresponding syntax tree, represented by your AST data structure.
It should match the following grammar:

```ebnf
INTEGER ::= /[0-9]+/
SYMBOL  ::= /(^\s|\(|\))+/    // this just means no whitespace or brackets
Literal ::= INTEGER | SYMBOL
Expr    ::= Literal | '(' Expr* ')'
Program ::= Expr*
```

Your language of choice likely has built in functions to convert a string to an integer (Python has `int`, Haskell has `read`, Rust has `string.parse::<i32>()`).
You'll probably want to use one of these functions to determine if a literal is a symbol or an integer.

Finally, you should also implement a pretty printer that converts the AST back into a string.
Hook these both into the REPL from the previous step, by parsing the user's input, and pretty printing the result.

### Hints

The code for this section can be quite difficult to come up with by yourself.
If you've spent some time trying to come up with a design for your parser, but are getting a little stuck, here's some pseudocode that might guide you.

<details markdown="1">
  <summary>Lexer pseudocode</summary>

  ```lua
  function lex(input: String) -> List<String>
    input = input.replace("(", " ( ")
    input = input.replace(")", " ) ")

    return input.split(" ")
  ```

</details>

<details markdown="1">
  <summary>Parser pseudocode</summary>

  ```lua
  enum Expr
    LInt Integer,
    LSym String,
    SExpr (List<Expr>)

  -- Parses an S-Expression (assuming that the initial `(` has been consumed)
  function parseSExpr(tokens: List<String>) -> (Expr, List<String>)
    res: List<Expr> = []

    while (head(tokens) is not ")")
      (e, ts) = parseExpr(tokens)
      res.add(e)
      tokens = ts

    return (SExpr(res), tail(tokens))  -- `tail` drops the closing bracket

  -- Parses a single expression
  function parseExpr(tokens: List<String>) -> (Expr, List<String>)
    match head(tokens)
      case ")" => error("Unexpected closing bracket")
      case "(" => return parseSExpr(tail(tokens))
      case t => if isNumeric(t)
        then return LInt(int(t))
        else return LSym(t)

  -- Parses a program (zero or more expressions)
  function parseProgram(tokens: List<String>) -> List<Expr>
    res: List<Expr> = []

    while (tokens is not [])
      (e, ts) = parseExpr(tokens)
      res.add(e)
      tokens = ts

    return res
  ```
</details>

## Tests

Here's some test cases that you can use to check if your implementation is along the right lines:

```console
MLTS>
MLTS> 1
1
MLTS> hello
hello
MLTS> ( )
()
MLTS> (+ 1 2)
(+ 1 2)
MLTS> (+ 1 (* 2 3))
(+ 1 (* 2 3))
MLTS> (())
(())
MLTS> (  ( )    )
(())
MLTS> (   foo    bar  )
(foo bar)
MLTS> (* 3
parse: expected closing bracket
MLTS> * 3 4)
parse: unexpected closing bracket
```

## Extra Challenges

These are some extra challenges you can attempt to build your understanding further, and make your interpreter more feature-complete.
None of them are required for a fully-functional interpreter.
They are listed in order of subjective difficulty; if you struggle on the later ones, you should move on to the next step and come back later.
Depending on your language choice, they might be easier or harder than anticipated!

- Allow floating point numbers as well as integers.

- Add support for comments.

- Treat square brackets (`[`/`]`) the same as normal brackets/parentheses, so the user can switch between them for clarity.

- Add the REPL commands `:lex` and `:parse`, which takes an expression and prints the output of the lexer and parser respectively when run on that expression.
  For example:

  ```console
  MLTS> :lex (+ 1 (* 2 foo))
  ["+", "1", "(", "*", "2", "foo", ")"]
  MLTS> :parse (+ 1 (* 2 foo))
  SExpr [LSym "+", LInt 1, SExpr [LSym "*", LInt 2, LSym "foo"]]
  ```

  Your output may look a bit different depending on how you implemented the data structure that represents parsed expressions.

  For bonus points, make `:parse` print its output in a tree format!

- Extend the grammar, tokeniser and parser to support string literals (strings of characters surrounded by double quotes).

- When a syntax error occurs, print out the line of input it occured on, and highlight underneath the unexpected token.
  The input:

  ```scheme
  (+ 1 2)
  (* 3 4))
  (- 5 6)
  ```

  should show an error similar to the following:

  ```plaintext
  input:2:8: Syntax Error: Unexpected closing bracket:
  2 | (* 3 4))
             ^
  ```

  For bonus points, add colour to the output!

- The combination of a parser and a pretty printer acts as a code formatter.
  Add a command line flag that formats the contents of a supplied file, and rewrite the pretty printer to display S-Exprs vertically if they have more than e.g. 3 elements:

  ```scheme
  (foo 1 2 3 4)
  (concat3 "hello, " (intToString 42) " world!")
  (* 5 6)
  ```

  becomes:

  ```scheme
  (foo 1
       2
       3
       4)
  (concat3 "hello, "
           (intToString 42)
           " world!")
  (* 5 6)
  ```

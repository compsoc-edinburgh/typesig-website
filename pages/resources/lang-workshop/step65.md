---
layout: page
title: "Step 6.5: Proofs about Types | Language Workshop"
permalink: "/resources/lang-workshop/step65"
latex: true
---

| Complexity | Medium
| Previous   | [Step 6: Types](/resources/lang-workshop/step6) |

## Table of Contents
{:.no_toc}

* toc dummy
{:toc}

## Motivation
When we write a program, we want to ensure that the program is doing what we want it to do. This is part of the job that types do; they make sure that each of your programs are meaningful.

However, this is placing a lot of trust in your type system. 
For example, what if we started with a program that's well-typed but then, once it's been fully evaluated, it no longer remains well-typed?
This places a question on how you actually go about typing that initial expression. Is it well-typed, because it started that way, or not well-typed, because it evaluates to something that isn't?

To demonstrate a type system like this, consider the typing rule:

\begin{prooftree}
  \AxiomC{$\Gamma \vdash e_1$ : \texttt{Bool}}
  \AxiomC{$\Gamma \vdash e_2 : t_1$}
  \AxiomC{$\Gamma \vdash e_3 : t_2$}
  \TrinaryInfC{$\Gamma \vdash$ \texttt{(if} $e_1$ \texttt{then} $e_2$ \texttt{else} $e_3$\texttt{)} : $t_1$}
\end{prooftree}

and the reduction rule:

$\texttt{(if false } e_1 \texttt{ } e_2 \texttt{)} \longrightarrow e_2$




## Structural Induction
Proofs abouts type systems often involve a proof technique called *structural induction*.

If you've done mathematical induction before, structural induction is a generalisation of that. 
To demonstrate this, consider the natural numbers as a derivation tree like so:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$0$ : $\mathbb{N}$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$n$ : $\mathbb{N}$}
  \UnaryInfC{$n + 1$ : $\mathbb{N}$}
\end{prooftree}

i.e. 0 is a natural number and, if $n$ is a natural number, $n + 1$ is also a natural number.

To prove a property holds of the natural numbers, you prove the property holds in each case:
1. Prove that it holds for 0.
2. Assuming that it holds for a generic natural number $n$, prove that it holds for $n + 1$.

Structural induction is just a generalisation of this for any kind of derivation tree. For each case, you assume the property holds for what's above the line, and prove the property holds for what's below the line.

Since our typing rules are a derivation tree, you can prove things about them in this way.

For example, say you wanted to prove that 

## Progress, Preservation and Type Safety
There's a well-known slogan for typed languages: "well-typed programs don't go wrong"! This notion is called *type safety*, and is an important property to prove to make sure that programs that start with no type errors stay with no type errors when they're evaluated.
It can come about from two properties of type systems: *progress* and *preservation*.

### Progress
Progress says that, for any well-typed expression $e : t$ in our language, either e is a value, or e evaluates *in one step* to some other expression $e^\prime$ in our language.

- TODO: Do progress for one case.

### Preservation
Preservation says that, for any well-typed expression $e : t$ in our language, either e is a value, or e evaluates *in one step* to some other expression $e^\prime$ in our language.

Preservation is usually slightly more tricky than progress: you typically need some intermediate lemmas. 
In particular, *renaming* and *substitution* are lemmas you often need to prove.

Weakening is the idea that extending a context doesn't affect whether an expression produced by that context is well-typed. It can be formulated like this:

\begin{prooftree}
  \AxiomC{$\Gamma \vdash e : t_1$}
  \UnaryInfC{$\Gamma, x : t_2 \vdash e : t_1$}
\end{prooftree}

### Type Safety




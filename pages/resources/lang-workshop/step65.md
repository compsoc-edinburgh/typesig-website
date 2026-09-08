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
For example, what if we have a program that starts with one type but then, once it's been fully evaluated, it has a different type, or isn't even well-typed at all?
This means that programs that are in some sense equivalent (they evaluate to the same thing) don't type the same way, which could lead to program behaviour that seems very unintuitive.

While we could check this isn't the case through testing, testing may not provide 100% coverage, and sometimes it's difficult to know exactly what tests you want to write.
Proving properties about our type system helps with both of these problems, and is standard in programming language research.

This is a half chapter for a reason; this doesn't have a lot to do with writing an interpreter. However, if you're interested in something a little more mathsy, this could be a chapter worth reading.

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

For example, say you wanted to prove that types are *unique*: if $\Gamma \vdash e : t$ and $\Gamma \vdash e : t^\prime$, then $t = t^\prime$.
Here, we're performing structural induction on both of the hypotheses, so both of them will be expanded into their cases.

Let's start with the base type case. Assume you have:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\Gamma \vdash v : t$}
\end{prooftree}

and

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\Gamma \vdash v : t^\prime$}
\end{prooftree}

where v is some integer literal, as in the example from Step 6. Since integer literals cannot have any type other than $\texttt{Int}$, we have $t_1 = t_2 = \texttt{Int}$, as required.

Slightly less trivial are composite types. Let's take the example of the typing rule for lambda introduction. Assume:

\begin{prooftree}
  \AxiomC{$\Gamma, x : t_1 \vdash$ \texttt{e} : $t_2$}
  \UnaryInfC{$\Gamma \vdash$ \texttt{(lambda ((x }$t_1$\texttt{)) e)} : $t_1$ \texttt{->} $t_2$}
\end{prooftree}

and

\begin{prooftree}
  \AxiomC{$\Gamma, x : t_1 \vdash$ \texttt{e} : $t_2^\prime$}
  \UnaryInfC{$\Gamma \vdash$ \texttt{(lambda ((x }$t_1$\texttt{)) e)} : $t_1$ \texttt{->} $t_2^\prime$}
\end{prooftree}

{% include infobox.html
  align="start"
  header="Exercise 1"
  text="
  Prove type uniqueness for your programming language's type system by structural induction.
  "
  color="success" align="center"
%}

<!-- ## Progress, Preservation and Type Safety -->
<!-- There's a well-known slogan for typed languages: "well-typed programs don't go wrong"! This notion is called *type safety*, and is an important property to prove to make sure that programs that start with no type errors stay with no type errors when they're evaluated. -->
<!-- It can come about from two properties of type systems: *progress* and *preservation*. -->
<!---->
<!-- ### Progress -->
<!-- Progress says that, for any well-typed expression $e : t$ in our language, either e is a value, or e evaluates *in one step* to some other expression $e^\prime$ in our language. -->
<!---->
<!-- - TODO: Do progress for one case. -->
<!---->
<!-- ### Preservation -->
<!-- Preservation says that, for any well-typed expression $e : t$ in our language, if $e $ -->
<!---->
<!-- Preservation is usually slightly more tricky than progress: you typically need some intermediate lemmas.  -->
<!-- In particular, *renaming* and *substitution* are lemmas you often need to prove. -->
<!---->
<!-- Weakening is the idea that extending a context doesn't affect whether an expression produced by that context is well-typed. It can be formulated like this: -->
<!---->
<!-- \begin{prooftree} -->
<!--   \AxiomC{$\Gamma \vdash e : t_1$} -->
<!--   \UnaryInfC{$\Gamma, x : t_2 \vdash e : t_1$} -->
<!-- \end{prooftree} -->
<!---->
<!-- ### Type Safety -->




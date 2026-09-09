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
  \RightLabel{\scriptsize{ZERO}}
  \UnaryInfC{$0$ : $\mathbb{N}$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$n$ : $\mathbb{N}$}
  \RightLabel{\scriptsize{SUC}}
  \UnaryInfC{$n + 1$ : $\mathbb{N}$}
\end{prooftree}

i.e. 0 is a natural number and, if $n$ is a natural number, $n + 1$ is also a natural number.

To prove a property holds of the natural numbers, you prove the property holds in each case:
1. Prove that it holds for 0.
2. Assuming that it holds for a generic natural number $n$, prove that it holds for $n + 1$.

Structural induction is just a generalisation of this for any kind of derivation tree. For each case, you can assume the property holds for what's above the line, and must prove the property holds for what's below the line. 
The assumption that the property holds for the term above the line is known as the *inductive hypothesis*.

Let's look at another example. You can express binary trees as derivation rules, considering two cases: 
- Tree leaves, which have a value. These represent the ends of the tree, where the tree doesn't branch any further.
- Tree nodes, which have a value and branch to two other trees.

\begin{prooftree}
  \AxiomC{x : Int}
  \RightLabel{\scriptsize{LEAF}}
  \UnaryInfC{leaf(x) : Tree}
\end{prooftree}

\begin{prooftree}
  \AxiomC{left : Tree}
  \AxiomC{x : Int}
  \AxiomC{right : Tree}
  \RightLabel{\scriptsize{NODE}}
  \TrinaryInfC{node(x, left, right) : Tree}
\end{prooftree}

An example of such a tree derivation would be

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{3 : Int}
  \UnaryInfC{leaf(3) : Tree}
  \AxiomC{}
  \UnaryInfC{2 : Int}
  \AxiomC{}
  \UnaryInfC{4 : Int}
  \UnaryInfC{leaf(4) : Tree}
  \TrinaryInfC{node(2, leaf(3), leaf(4)) : Tree}
  \AxiomC{}
  \UnaryInfC{1 : Int}
  \AxiomC{}
  \UnaryInfC{5 : Int}
  \UnaryInfC{leaf(5) : Tree}
  \TrinaryInfC{node(1, node(2, leaf(3), leaf(4)), leaf(5)) : Tree}
\end{prooftree}

which represents the tree

<img src="/assets/images/mlts-diagrams/btree.png" width="200" align="middle" style="display: block; margin-left: auto; margin-right: auto;">

Let's say we wanted to prove that, for every tree of height $k$, the number of values the tree contains, which we'll call its *size*, does not exceed $2^k - 1$.

We can proceed by strctural induction, which splits our proof into two cases:

Case LEAF.

In this case, $k = 1$, so we need to prove that the number of values in the tree does not exceed $2^1 - 1 = 1$.
In the LEAF case, there is always only 1 value in the tree. $1 \le 2^1 - 1 = 1$, as required.

Case NODE.

In this case, we have a value, as well as branches to two sub-trees, *left* and *right*. We'll say these trees have heights $k_l$ and $k_r$ respectively.

By using the *inductive hypothesis*, we can say that *left* has a size not exceeding $2^{k_l} - 1$, and *right* has a size not exceeding $2^{k_r} - 1$.
From this, we can infer that the combined tree's size does not exceed $(2^{k_l} - 1) + (2^{k_r} - 1) + 1 = 2^{k_l} + 2^{k_r} - 1$.

To figure out the height of the combined tree, we want to take the *greater* of the two sub-tree heights, and then add one for the new node.
Let's denote the greater height as $k_{max}$.
Hence, the height of the combined tree is $k_{max} + 1$, and so we want to show that the size of the combined tree does not exceed $2^{k_{max} + 1} - 1$.

Since $k_{max}$ is the maximum of $k_l$ and $k_r$, we have $k_l \le k_{max}$ and $k_r \le k_{max}$. Therefore, we can say that $2^{k_l} + 2^{k_r} - 1 \le 2 \cdot 2^{k_{max}} - 1 \le 2^{k_{max} + 1} - 1$, as required.

---

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

Since the argument type of the function is determined by the expression, this type will remain the same in both expressions. It's only the return type that can change.

Here, for each of our two derivations, not only do we have a typing judgement underneath the line to prove the property holds for, we also have one above the line to assume the property holds for, as with the earlier natural numbers $n + 1$ example.

As such, considering $\Gamma, x : t_1 \vdash \texttt{e} : t_2$ and $\Gamma, x : t_1 \vdash \texttt{e} : t_2^\prime$, we may say that, by the induction hypothesis, $t_2 = t_2^\prime$.

Now that we have this, we can consider the two typing judgements we have below the line. Since we've determined that $t_2 = t_2^\prime$, we can go through and replace every instance of $t_2^\prime$ with $t_2$.
By doing this, we get

\begin{prooftree}
  \AxiomC{$\Gamma \vdash \texttt{(lambda ((x } t_1 \texttt{)) e)} : t_1 \, \texttt{->} \, t_2$}
\end{prooftree}

for both typing judgements, which is exactly what we're looking for.

You can then do this for every typing rule to end up with a complete proof of type uniqueness.

Since our typing rules are a derivation tree, you can prove things about them in this way.

{% include infobox.html
  align="start"
  header="Exercise 1"
  text="
  Prove type uniqueness for your programming language's type system by structural induction.
  "
  color="success" align="center"
%}

## Progress, Preservation and Safety
There's a well-known slogan for typed languages: "well-typed programs don't go wrong"! This notion is called *type safety*, and is the property we alluded to earlier, making sure that programs that start well-typed stay well-typed when they're evaluated.
It can come about from two properties of type systems: *progress* and *type preservation*.

### Progress
Progress says that, for any well-typed expression $e : t$ in our language, either e is a value, or e evaluates *in one step* to (which we'll henceforth call *stepping to*) some other expression $e^\prime$ in our language.

- TODO: Outline progress proof.

### Type Preservation
Type preservation says that, for any well-typed expression $e : t$ in our language, if $e$ steps to $e^\prime$, then $e^\prime : t$.

Type preservation is usually slightly more tricky than progress: you typically need some intermediate lemmas. 
In particular, *weakening* and *substitution* are lemmas you often need to prove.

Weakening is the idea that extending a context doesn't affect whether an expression produced by that context is well-typed. It can be formulated like this:

\begin{prooftree}
  \AxiomC{$\Gamma \vdash e : t$}
  \UnaryInfC{$\Gamma, x : t^\prime \vdash e : t$}
\end{prooftree}

### Type Safety




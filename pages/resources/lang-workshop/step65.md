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

Structural induction is just a generalisation of this for any kind of derivation tree.

In particular, the term *below the line* in a derivation rule is always some object of a particular type $U$. 
We can see the derivation rules as ways of *constructing* an object of type $U$. 
In the example above, $U$ is the type of *natural numbers*, $\mathbb{N}$. In the case of our type system, $U$ would be the type of *well-typed terms*.
In this light, the derivation rules of our type system should really be rewritten as

\begin{prooftree}
  \AxiomC{($\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$) : Term}
  \AxiomC{($\Gamma \vdash e_2 : t_1$) : Term}
  \BinaryInfC{($\Gamma \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)}$ : $t_2$) : Term}
\end{prooftree}

but we omit these extra type annotations for brevity. 
Note that the two colons in 
\begin{prooftree}
  \AxiomC{($\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$) : Term}
\end{prooftree}
are different: the first is part of the syntax of Terms, and the second is a kind of meta-colon that we use to give the object ($\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$) the type Term, like we gave $0$ the type $\mathbb{N}$.


As for the objects *above the line* in a derivation rule, we may both assume that they exist and, if they have type $U$, assume that the property we're trying to prove holds for them.
Considering objects above the line having different types isn't relevant for the natural numbers, but they are relevant for our next example: *binary trees*.

You can express binary trees as derivation rules, considering two cases: 
- Tree leaves, which have a value. These represent the ends of the tree, where the tree doesn't branch any further.
- Tree nodes, which have a value and branch to two other trees.

\begin{prooftree}
  \AxiomC{x : Int}
  \RightLabel{\scriptsize{LEAF}}
  \UnaryInfC{leaf(x) : Tree}
\end{prooftree}

\begin{prooftree}
  \AxiomC{x : Int}
  \AxiomC{left : Tree}
  \AxiomC{right : Tree}
  \RightLabel{\scriptsize{NODE}}
  \TrinaryInfC{node(x, left, right) : Tree}
\end{prooftree}

An example of such a tree derivation would be

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{1 : Int}
  \AxiomC{}
  \UnaryInfC{2 : Int}
  \AxiomC{}
  \UnaryInfC{3 : Int}
  \UnaryInfC{leaf(3) : Tree}
  \AxiomC{}
  \UnaryInfC{4 : Int}
  \UnaryInfC{leaf(4) : Tree}
  \TrinaryInfC{node(2, leaf(3), leaf(4)) : Tree}
  \AxiomC{}
  \UnaryInfC{5 : Int}
  \UnaryInfC{leaf(5) : Tree}
  \TrinaryInfC{node(1, node(2, leaf(3), leaf(4)), leaf(5)) : Tree}
\end{prooftree}

which represents the construction of the tree

<img src="/assets/images/mlts-diagrams/btree.png" width="200" align="middle" style="display: block; margin-left: auto; margin-right: auto;">

Let's say we wanted to prove that, for every tree of height $k$, the number of values the tree contains, which we'll call its *size*, does not exceed $2^k - 1$.

We can proceed by structural induction, which splits our proof into two cases:

*Case* LEAF.

In this case, $k = 1$, so we need to prove that the number of values in the tree does not exceed $2^1 - 1 = 1$.
In the LEAF case, there is always only 1 value in the tree. $1 \le 2^1 - 1 = 1$, as required.

*Case* NODE.

In this case, we have a value, as well as branches to two sub-trees, *left* and *right*. We'll say these trees have heights $k_l$ and $k_r$ respectively.

By using the *inductive hypothesis*, we can say that *left* has a size not exceeding $2^{k_l} - 1$, and *right* has a size not exceeding $2^{k_r} - 1$.
From this, we can infer that the combined tree's size does not exceed $(2^{k_l} - 1) + (2^{k_r} - 1) + 1 = 2^{k_l} + 2^{k_r} - 1$.

To figure out the height of the combined tree, we want to take the *greater* of the two sub-tree heights, and then add one for the new node.
Let's denote the greater height as $k_{max}$.
Hence, the height of the combined tree is $k_{max} + 1$, and so we want to show that the size of the combined tree does not exceed $2^{k_{max} + 1} - 1$.

Since $k_{max}$ is the maximum of $k_l$ and $k_r$, we have $k_l \le k_{max}$ and $k_r \le k_{max}$. Therefore, we can say that $2^{k_l} + 2^{k_r} - 1 \le 2 \cdot 2^{k_{max}} - 1 \le 2^{k_{max} + 1} - 1$, as required.

Our typing rules also form derivation trees, so we can apply structural induction to prove things about them, too.

{% include infobox.html
  align="start"
  header="Exercise 1"
  text="
  Something
  "
  color="success" align="center"
%}

## Progress, Preservation and Safety
There's a well-known slogan for typed languages: "well-typed programs don't go wrong"! This notion is called *type safety*, and is the property we alluded to earlier, making sure that programs that start well-typed stay well-typed when they're evaluated.
It can come about from two properties of type systems: *progress* and *type preservation*.

### Progress
Progress says that, for any well-typed term $\cdot \vdash e : t$ in our language, either e is a value, or e *evaluates in one step* to (which we'll henceforth call *stepping to*) some other expression $e^\prime$ in our language.

For this, we need to define what a value actually is. In general, a value is something that you can't reduce any further. In our language, this would be values of base types, and lambdas.

Let's consider some of the derivation rules we have in Step 6.

*Case* $\frac{}{\cdot \vdash v : \texttt{Int}}$.

Here, since $v$ is a value, the property is trivially true in this case. This goes for the introduction of *any* base type.

*Case* $\frac{\cdot \vdash e_1 : \texttt{Int}\,\cdot \vdash e_2 : \texttt{Int}}{\cdot \vdash \texttt{(+ }e_1\texttt{ }e_2\texttt{)} : \texttt{Int}}$.

By applying the inductive hypothesis to $e_1$, we can determine that either $e_1$ is a value, or $e_1$ steps to some other expression $e_1^\prime$.

Let's consider the case that $e_1$ steps to $e_1^\prime$. Then, $\texttt{(+ }e_1\texttt{ }e_2\texttt{)}$ steps to $\texttt{(+ }e_1^\prime\texttt{ }e_2\texttt{)}$, as required.

Now consider the case that $e_1$ is some value $v_1$, and whether $\texttt{(+ }v_1\texttt{ }e_2\texttt{)}$ satisfies the desired property.
Let's apply the inductive hypothesis to $e_2$. Either $e_2$ is a value, or steps to some $e_2^\prime$.

Similarly to before, if $e_2$ steps to $e_2^\prime$, then $\texttt{(+ }v_1\texttt{ }e_2\texttt{)}$ steps to $\texttt{(+ }v_1\texttt{ }e_2^\prime\texttt{)}$, as required.

If $e_2$ is some value $v_2$, then $\texttt{(+ }v_1\texttt{ }v_2\texttt{)}$ steps to the *integer sum* of $v_1$ and $v_2$, $v_1 + v_2$, as required.

By applying to the inductive hypothesis to all of our sub-expressions, we've managed to determine what $\texttt{(+ }e_1\texttt{ }e_2\texttt{)}$ steps to in every situation.
This is the general idea of this proof.

{% include infobox.html
  align="start"
  header="Exercise 2"
  text="
  Complete a proof of progress for your type system.
  "
  color="success" align="center"
%}

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


---
layout: page
title: "Step 6.5: Proofs about Types | Language Workshop"
permalink: "/resources/lang-workshop/step65"
latex: true
---

| Length   | Long                                            |
| Previous | [Step 6: Types](/resources/lang-workshop/step6) |

## Table of Contents
{:.no_toc}

* toc dummy
{:toc}

## Motivation
Last step, we made claims in the last chapter about how our type system operates. 
In particular, we said up front that `(1 2)` should not be permissible in our language, because it's not meaningful. 
However, this begs the question: how do we know that we don't have any other non-meaningful programs lurking about? 

We could check that cases like this don't arise through testing. 
The problem is that tests may not provide 100% coverage, and sometimes it's difficult to know exactly what tests you want to write.
Instead, we propose *proving* that such programs don't exist.

This step aims to make more formal what we actually mean when we say that programs are "not meaningful".
We express this through the property of being *stuck*.

An expression $e$ is *stuck* when $e$ is not a value, but there is no further expression $e^\prime$ that $e$ reduces to. 
This makes sense intuitively speaking: `(1 2)` can't reduce to any further expression, but since it's a function application, it also isn't a value.
What we then aim to show is that no well-typed term in our language gets stuck, a property known as *type safety*.

To examine whether this is actually the case, we need to make more formal the notion of *reduction*.
Once we've done this, we aim to prove type safety through two other properties: *progress*, which says that any well-typed term is not stuck, and *preservation*, which says that a well-typed program of a type will remain a well-typed program of that type when it reduces, and so it remains unstuck.

This is a half chapter for a reason; this doesn't immediately have a lot to do with writing an interpreter. However, if you're interested in something a little more mathsy, this chapter is worth reading.

## Reduction Rules
To formally express how programs evaluate, we'll introduce the $\rightsquigarrow$ judgement, read as "steps to". This judgement is very similar to the `~>` notation we've used before.
Throughout these example rules, we'll use $e$ to denote expressions and $v$ to denote values.

Let's start with the $\texttt{Int}$ example.

\begin{prooftree}
  \AxiomC{$e_1 \rightsquigarrow e_1^\prime$}
  \RightLabel{\scriptsize{\texttt{+}-RED-1}}
  \UnaryInfC{$\texttt{(+ }e_1\texttt{ }e_2\texttt{)} \rightsquigarrow \texttt{(+ }e_1^\prime\texttt{ }e_2\texttt{)}$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$e_2 \rightsquigarrow e_2^\prime$}
  \RightLabel{\scriptsize{\texttt{+}-RED-2}}
  \UnaryInfC{$\texttt{(+ }v_1\texttt{ }e_2\texttt{)} \rightsquigarrow \texttt{(+ }v_1\texttt{ }e_2^\prime\texttt{)}$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{\texttt{+}-RED-3}}
  \UnaryInfC{$\texttt{(+ }v_1\texttt{ }v_2\texttt{)} \rightsquigarrow v_1 +_\mathbb{Z} v_2$}
\end{prooftree}

Together, these rules express the idea of evaluating each argument in turn. 
- If the first argument can step to another expression, we apply the first rule, replacing the first argument of the outer expression with what it steps to. This rule is applied repeatedly until the first argument steps to a value, and so cannot be evaluated further.
- Once this occurs, we do the same with the second argument, applying the second rule until the second argument steps to a value and cannot step further.
- Once both arguments are values, we can evaluate the expression to its *integer sum*. This is done using the `+` operator from the language you've implemented your interpreter in.

To describe reduction of functions, just as with types, we need some way to express our *environment* in our reduction system.
To do this, we'll expand $\rightsquigarrow$ to relate *pairs* $\langle e, \rho \rangle$, where $\rho$ represents our environment, instead of just expressions $e$.

We define environments similarly to typing contexts, as follows:
- $\cdot$ represents the empty environment.
- $\rho[x \mapsto v]$ represents the *extension* of $\rho$ with the mapping $x \mapsto v$.

Just as with our type system, we can use a *variable* rule to take out reductions from our environment and use them in reductions of larger expressions.

\begin{prooftree}
  \AxiomC{$\rho(x) = v$}
  \RightLabel{\scriptsize{VAR-RED}}
  \UnaryInfC{$\langle x, \rho \rangle \rightsquigarrow \langle v, \rho \rangle$}
\end{prooftree}

We also extend the previous reduction rules with our new environment representation.

\begin{prooftree}
  \AxiomC{$\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho \rangle$}
  \RightLabel{\scriptsize{\texttt{+}-RED-1}}
  \UnaryInfC{$\langle \texttt{(+ }e_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(+ }e_1^\prime\texttt{ }e_2\texttt{)}, \rho \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho \rangle$}
  \RightLabel{\scriptsize{\texttt{+}-RED-2}}
  \UnaryInfC{$\langle \texttt{(+ }v_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(+ }v_1\texttt{ }e_2^\prime\texttt{)}, \rho \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{\texttt{+}-RED-3}}
  \UnaryInfC{$\langle \texttt{(+ }v_1\texttt{ }v_2\texttt{)}, \rho \rangle \rightsquigarrow \langle v_1 +_\mathbb{Z} v_2, \rho \rangle$}
\end{prooftree}

Now we can consider how functions reduce. Here, I'll describe function application.

\begin{prooftree}
  \AxiomC{$\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho \rangle$}
  \RightLabel{\scriptsize{APP-RED-1}}
  \UnaryInfC{\langle $\texttt{(}e_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)}, \rho \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho \rangle$}
  \RightLabel{\scriptsize{APP-RED-2}}
  \UnaryInfC{$\langle \texttt{(}v_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}v_1\texttt{ }e_2^\prime\texttt{)}, \rho \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{BETA-RED}}
  \UnaryInfC{$\langle \texttt{((lambda ((x }t\texttt{)) }e\texttt{)}\texttt{ }v\texttt{)}, \rho \rangle \rightsquigarrow \langle e, \rho[x \mapsto v] \rangle$}
\end{prooftree}

The first two rules evaluate each argument, like with `+`. The last rule evaluates the lambda application by evaluating the expression, with $x$ now mapping to $v$ in our environment, just as it is in our `eval` function.

You may notice that we don't use the argument type $t$ on the right-hand side of the reduction. This is by design; reduction rules aren't concerned with types. The relation between reductions and typing judgements comes from proving type safety.

Let's try an example reduction of the lambda application $\texttt{((lambda ((x Int)) (+ x 1)) (+ 2 3))}$, with an empty initial environment.

We see that the left-hand side of the reduction is a value, so we skip over the $\text{\scriptsize{APP-RED-1}} rule.

The right-hand side of the reduction is not a value, but instead an expression $\texttt{(+ 2 3)}$. 
Noting that $\texttt{2}$ and $\texttt{3}$ are values, we can apply the $\texttt{+}$-RED-3 rule:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\langle \texttt{(+ 2 3)}, \cdot \rangle \rightsquigarrow \langle \texttt{5}, \cdot \rangle$}
\end{prooftree}

Now that we know this, we can apply the $\text{\scriptsize{APP-RED-2}}$ rule to the lambda application:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\langle \texttt{(+ 2 3)}, \cdot \rangle \rightsquigarrow \langle \texttt{5}, \cdot \rangle$}
  \UnaryInfC{$\begin{aligned} 
                &\,\, \langle \texttt{((lambda ((x Int)) (+ x 1)) (+ 2 3))}, \cdot \rangle \newline
                &\rightsquigarrow \langle \texttt{((lambda ((x Int)) (+ x 1)) 5)}, \cdot \rangle
              \end{aligned}$}
\end{prooftree}

Now that the right-hand side of the application is a value, we can apply $\text{\scriptsize{BETA-RED}}$ to reduce further:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\begin{aligned}
                &\,\, \langle \texttt{((lambda ((x Int)) (+ x 1)) 5)}, \cdot \rangle \newline
                &\rightsquigarrow \langle \texttt{(+ x 1)}, \cdot[x \mapsto \texttt{5}] \rangle
              \end{aligned}$}
\end{prooftree}

Now we're back to a $\texttt{+}$ expression. $\texttt{x}$ can reduce further as a variable, so we extract out the reduction for $\texttt{x}$ from the environment and apply the VAR-RED rule:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\cdot\[x \mapsto \texttt{5}\](x) = \texttt{5}$}
  \UnaryInfC{$\begin{aligned}
                 \langle \texttt{(+ x 1)}, \cdot[x \rightsquigarrow \texttt{5}] \rangle \rightsquigarrow \langle \texttt{(+ 5 1)}, \cdot[x \mapsto \texttt{5}] \rangle
               \end{aligned}$}
\end{prooftree}

Finally, since 5 and 1 are values, as before, we apply the $\texttt{+}$-RED-3 rule to arrive at our final reduction:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\begin{aligned}
                 \langle \texttt{(+ 5 1)}, \cdot[x \mapsto \texttt{5}] \rangle \rightsquigarrow \langle \texttt{6}, \cdot[x \mapsto \texttt{5}] \rangle
               \end{aligned}$}
\end{prooftree}

{% include infobox.html
  align="start"
  header="Exercise 1"
  text="
  Write down the additional reduction rules for your programming language.
  "
  color="success" align="center"
%}

{% include infobox.html
  align="start"
  text="
  The reduction rules that we've shown are for a *call-by-value* language, since we evaluate the arguments to an application before applying.
  If you've been experimenting with different reduction strategies, your reduction rules will look a bit different.
  Try to figure it out for yourself!
  "
  color="info" align="center"
%}

Now that we've talked about reduction as a judgement, we can talk about how we perform proofs over judgements.
This is done by a technique called *structural induction*.

## Structural Induction
If you've done mathematical induction before, structural induction is a generalisation of that. 
To demonstrate this, consider the natural numbers as a derivation tree like so:

\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{ZERO}}
  \UnaryInfC{$0 \in \mathbb{N}$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$n \in \mathbb{N}$}
  \RightLabel{\scriptsize{SUC}}
  \UnaryInfC{$\text{suc}(n) \in \mathbb{N}$}
\end{prooftree}

i.e. 0 is a natural number and, if $n$ is a natural number, the successor of $n$ is also a natural number.
For example, 1 is represented as $\text{suc}(0)$, 2 is represented as $\text{suc}(\text{suc}(0))$, and so on.
We can consider 0 and $\text{suc}$ to be *constructors* for the natural numbers.

To prove a property $P$ holds of the natural numbers, we prove that:
1. $P$ holds for 0.
2. If $P$ holds for n, then $P$ holds for $\text{suc}(n)$.

Structural induction is just a generalisation of this for any kind of derivation tree.

In particular, if we want to prove a property $P$ for a set of expressions $L$, then it suffices to prove that, for each constructor $c$, if $P$ holds for each sub-tree $e_1, ..., e_k \in L$, then $P$ holds for the whole tree $c(e_1, ..., e_k) \in L$.
This is called the *principle of structural induction*.
The assumption that P holds for each sub-tree is called the *inductive hypothesis*.

We can apply this to the natural numbers to see how we arrive at mathematical induction: 
1. For the constructor 0, we have no sub-trees, so we just need to show that P holds for 0.
2. For the constructor $\text{suc}$, we have the single sub-tree $n$, so we need to show that, if P holds for $n$, P holds for $\text{suc}(n)$.

Since we've covered all constructors, these two statements suffice to prove that $P$ holds for every natural number.

As another example, let's examine the set of binary trees. Binary trees can be constructed in two ways:
- Tree leaves, which have a value. These represent the ends of the tree, where the tree doesn't branch any further.
- Tree nodes, which have a value and branch to two other trees.

\begin{prooftree}
  \AxiomC{$x \in \mathbb{Z}$}
  \RightLabel{\scriptsize{LEAF}}
  \UnaryInfC{$\text{leaf}(x) \in \text{Tree}$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$l \in \text{Tree}$}
  \AxiomC{$x \in \mathbb{Z}$}
  \AxiomC{$r \in \text{Tree}$}
  \RightLabel{\scriptsize{NODE}}
  \TrinaryInfC{$\text{node}(x, l, r) \in \text{Tree}$}
\end{prooftree}

An example of such a tree derivation would be

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$3 \in \mathbb{Z}$}
  \UnaryInfC{$\text{leaf}(3) \in \text{Tree}$}
  \AxiomC{}
  \UnaryInfC{$2 \in \mathbb{Z}$}
  \AxiomC{}
  \UnaryInfC{$4 \in \mathbb{Z}$}
  \UnaryInfC{$\text{leaf}(4) \in \text{Tree}$}
  \TrinaryInfC{$\text{node}(2, \text{leaf}(3), \text{leaf}(4)) \in \text{Tree}$}
  \AxiomC{}
  \UnaryInfC{$1 \in \mathbb{Z}$}
  \AxiomC{}
  \UnaryInfC{$5 \in \mathbb{Z}$}
  \UnaryInfC{$\text{leaf}(5) \in \text{Tree}$}
  \TrinaryInfC{$\text{node}(1, \text{node}(2, \text{leaf}(3), \text{leaf}(4)), \text{leaf}(5)) \in \text{Tree}$}
\end{prooftree}

which represents the construction of the tree

<img src="/assets/images/mlts-diagrams/btree.png" width="200" align="middle" style="display: block; margin-left: auto; margin-right: auto;">

Let's say we wanted to prove that, for every tree of height $k$, the number of values the tree contains, which we'll call its *size*, does not exceed $2^k - 1$.
We'll call this property $P$.

By applying the principle of structural induction, to prove $P(t)$ for all $t \in \text{Tree}$, we prove that:
1. $P(\text{leaf}(x))$ holds.
2. If $P(l)$ and $P(r)$ hold, then $P(\text{node}(x, l, r))$ holds.

Let's follow through with this, proving each case.

*Case* $\frac{x \in \mathbb{Z}}{\text{node}(x, l, r) \in \text{Tree}} \text{\scriptsize{LEAF}}$.

In this case, $k = 1$, so we need to prove that the number of values in the tree does not exceed $2^1 - 1 = 1$.
In the LEAF case, there is always only 1 value in the tree. $1 \le 2^1 - 1 = 1$, as required.

*Case* $\frac{l \in \text{Tree} \,\,x \in \mathbb{Z}\,\,r \in \text{Tree}}{\text{node}(x, l, r) \in \text{Tree}} \text{\scriptsize{NODE}}$.

In this case, we have a value, as well as branches to two sub-trees, $l$ and $r$. We'll say these trees have heights $k_l$ and $k_r$ respectively.

From the inductive hypothesis, we can assume that $l$ has a size not exceeding $2^{k_l} - 1$, and $r$ has a size not exceeding $2^{k_r} - 1$.
From this, we can infer that the combined tree's size does not exceed $(2^{k_l} - 1) + (2^{k_r} - 1) + 1 = 2^{k_l} + 2^{k_r} - 1$.

To figure out the height of the combined tree, we want to take the *greater* of the two sub-tree heights, and then add one for the new node.
Let's denote the greater height as $k_{max}$.
Hence, the height of the combined tree is $k_{max} + 1$, and so we want to show that the size of the combined tree does not exceed $2^{k_{max} + 1} - 1$.

Since $k_{max}$ is the maximum of $k_l$ and $k_r$, we have $k_l \le k_{max}$ and $k_r \le k_{max}$. Therefore, we can say that $2^{k_l} + 2^{k_r} - 1 \le 2 \cdot 2^{k_{max}} - 1 \le 2^{k_{max} + 1} - 1$, as required.

Our typing rules also form derivation trees, so we can apply structural induction to prove things about them, too.

{% include infobox.html
  align="start"
  header="Exercise 2"
  text="
  Here are the derivation rules for a linked list.

  \begin{prooftree}
    \AxiomC{}
    \RightLabel{\scriptsize{NIL}}
    \UnaryInfC{$[] \in \text{List}$}
  \end{prooftree}

  \begin{prooftree}
    \AxiomC{$x \in \mathbb{Z}$}
    \AxiomC{$l \in \text{List}$}
    \RightLabel{\scriptsize{CONS}}
    \BinaryInfC{$x :: l \in \text{List}$}
  \end{prooftree}

  As an example, the construction of the list $[1, 2, 3]$ is $1 :: (2 :: (3 :: []))$.

  Define a function $\text{concat}$ on lists as follows:

  \begin{aligned}
    &\text{concat}([], l_2) \stackrel{\text{def}}{=} l_2 \newline
    &\text{concat}(x :: l_1, l_2) \stackrel{\text{def}}{=} x :: \text{concat}(l_1, l_2)
  \end{aligned}

  Prove that $\text{concat}$ is *associative* i.e.  
  $\text{concat}(\text{concat}(l_1, l_2), l_3) = \text{concat}(l_1, \text{concat}(l_2, l_3))$.

  Hint: this proof mostly follows from continually expanding out the definitions.
  "
  color="success" align="center"
%}

## Progress and Preservation
Here, we describe the theorem statements and proofs for progress and type preservation in a little more detail.

### Progress
Now that we have our reduction rules in place, we can state the progress theorem more formally.

<u>Theorem (Progress).</u> If $\cdot \vdash e : t$, then either e is a value or there exists some $e^\prime$ such that $\langle e, \rho \rangle \rightsquigarrow \langle e^\prime, \rho^\prime \rangle$.

To prove this statement, we want to perform structural induction over the term $\cdot \vdash e : t$. Since this is constructed by a derivation tree, we can apply the principle of structural induction to figure out what we need to prove:
1. For the $\text{\scriptsize{LAM}}$ rule, we have the sub-tree $\Gamma, x : t_1 \vdash e : t_2$, so we assume that progress holds for this sub-tree and then prove that progress holds for $\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$.
2. For the $\text{\scriptsize{APP}}$ rule, we have the sub-trees $\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$ and $\Gamma \vdash e_2 : t_1$, so we assume that progress holds for these sub-trees and then prove that preservation holds for $\Gamma \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2$.

...and so on for the rest of our rules.

{% include infobox.html
  align="start"
  header="Exercise 3"
  text="
  Use the principle of structural induction to determine the rest of the proof cases for typing derivations. Do this for reduction derivations as well.
  "
  color="success" align="center"
%}

As an example of proving progress, let's consider those derivation rules we have for functions.

*Case* $\frac{\cdot, x : t_1 \vdash e : t_2}{\cdot \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1 \texttt{->} t_2} \text{\scriptsize{LAM}}$.

Here, preservation holds since $\texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)}$ is a value. 
We don't even need to use our assumption!
This also goes for the introduction of an object of any base type.

*Case* $\frac{\cdot \vdash e_1 : t_1 \texttt{->} t_2\,\,\cdot \vdash e_2 : t_1}{\cdot \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2} \text{\scriptsize{APP}}$.

By using the inductive hypothesis to assume that progress holds for $\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$, we can determine that either $e_1$ is a value, or $\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho \rangle$.

Let's consider the case that $\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho \rangle$. Then, by $\text{\scriptsize{APP-RED-1}}$, $\langle \texttt{(}e_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)}, \rho \rangle$, as required.

Now consider the case that $e_1$ is some value $v_1$, and consider whether $\texttt{(}v_1\texttt{ }e_2\texttt{)}$ satisfies the desired property.
Let's now use the inductive hypothesis assumption that progress holds for $\Gamma \vdash e_2 : t_1$. 
From this, either $e_2$ is a value, or $\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho \rangle$.

If $\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho \rangle$, then by $\text{\scriptsize{APP-RED-2}}$, $\langle \texttt{(}v_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}v_1\texttt{ }e_2^\prime\texttt{)}, \rho \rangle$, as required.

If $e_2$ is some value $v$, then, taking $v_1 = \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)}$, since lambdas are the only form that function values can take, by $\text{\scriptsize{BETA-RED}}$, $\langle \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{)}\texttt{ }v\texttt{)}, \rho \rangle \rightsquigarrow \langle e, \rho[x \mapsto v] \rangle$, as required.

By applying the inductive hypothesis to all of our sub-expressions, and applying our reduction rules, we've managed to determine what $\texttt{(}e_1\texttt{ }e_2\texttt{)}$ steps to in every situation!

{% include infobox.html
  align="start"
  header="Exercise 4"
  text="
  Complete a proof of progress for the rest of the Simply-Typed Lambda Calculus.
  "
  color="success" align="center"
%}

### Type Preservation
Type preservation is a bit trickier than progress. It's a theorem that relates the reduction of an expression $e$ and the typing of $e$.

Part of this will be to prove that reductions maintain that environments and our typing contexts are in lock-step with each other: there isn't anything in one that isn't in the other, and values in the environment have the type of the variable associated with them in the typing context.

We will express this idea using the judgement $\Gamma \vdash \rho$, defined as follows:  
\begin{displaymath}
  \Gamma \vdash \rho \stackrel{\text{def}}{=} \text{dom}(\Gamma) = \text{dom}(\rho) \land \forall x \in \text{dom}(\Gamma).\,\Gamma \vdash \rho(x) : \Gamma(x).
\end{displaymath}

To explain a few pieces of notation here:
- The $\text{dom}$ function returns a set of the variables of environments $\rho$ or typing contexts $\Gamma$.
  We can define this recursively as:
  \begin{aligned}
    &\text{dom}(\cdot) \stackrel{\text{def}}{=} \emptyset \newline
    &\text{dom}(\Gamma, x : t) \stackrel{\text{def}}{=} \text{dom}(\Gamma) \cup \set{x}
  \end{aligned}
  and similarly for environments.
- Similarly to $\Gamma(x)$, $\rho(x)$ is a lookup of the value associated with x in $\rho$.

We're also going to introduce the idea of *ordering* contexts. 
In particular, $\Gamma \subseteq \Gamma^\prime$ holds when $\Gamma^\prime$ has all of the variables $\Gamma$ has (and potentially more), and $\Gamma$ and $\Gamma^\prime$ agree on the types of the variables of $\Gamma$.

More formally, you can define this as follows:  
\begin{displaymath}
  \Gamma \subseteq \Gamma^\prime \stackrel{\text{def}}{=} \text{dom}(\Gamma) \subseteq \text{dom}(\Gamma^\prime) \land \forall x \in \text{dom}(\Gamma).\,\Gamma(x) = \Gamma^\prime(x).
\end{displaymath}

With the ordering of contexts, we can define a statement for *weakening*, the idea that extending a context doesn't affect whether an expression produced by that context is well-typed. 
We'll need this for the preservation proof.

<u>Theorem (Weakening)</u>. If $\Gamma \vdash e : t$ and $\Gamma \subseteq \Gamma^\prime$, then $\Gamma^\prime \vdash e : t$.  

As with progress, we'll perform structural induction over $\Gamma \vdash e : t$. Let's examine the function application case again.

*Case* $\frac{\Gamma \vdash e_1 : t_1\texttt{ -> }t_2\,\,\Gamma \vdash e_2 : t_1}{\Gamma \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2} \text{\scriptsize{APP}}$.

In this case, we're looking to prove that, given a $\Gamma^\prime \supseteq \Gamma$, $\Gamma^\prime \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2$.

Assuming that weakening holds for the premises, we have $\Gamma^\prime \vdash e_1 : t_1\texttt{ -> }t_2$ and $\Gamma^\prime \vdash e_2 : t_1$.

Hence, by applying the function application rule to these two statements, we have $\Gamma^\prime \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2$, as required.

{% include infobox.html
  align="start"
  header="Exercise 5"
  text="
  Complete a proof of weakening for the rest of the Simply-Typed Lambda Calculus.
  "
  color="success" align="center"
%}

Once this is proven, we can now state preservation.

<u>Theorem (Preservation).</u> If $\Gamma \vdash e : t$, $\langle e, \rho \rangle \rightsquigarrow \langle e^\prime, \rho^\prime \rangle$ and $\Gamma \vdash \rho$, then there exists some $\Gamma^\prime \supseteq \Gamma$ such that $\Gamma^\prime \vdash e^\prime : t$ and $\Gamma^\prime \vdash \rho^\prime$.

Here, there are two different derivations we need to induct over: $\Gamma \vdash e : t$, and $\langle e, \rho \rangle \rightsquigarrow \langle e^\prime, \rho^\prime \rangle$. 
Inducting over two derivations isn't much different from inducting over one, except now there are a lot more cases and assumptions to get your head around.

Again, let's examine the function application case.

*Case* $\frac{\Gamma \vdash e_1 : t_1\texttt{ -> }t_2\,\,\Gamma \vdash e_2 : t_1}{\Gamma \vdash \texttt{(}e_1\,e_2\texttt{)} : t_2} \text{\scriptsize{APP}}$.

*Sub-case* $\frac{\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho \rangle}{\langle \texttt{(}e_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)}, \rho \rangle} \text{\scriptsize{APP-RED-1}}$. 

By assumption, we have $\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$, $\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho^\prime \rangle$ and $\Gamma \vdash \rho$. 
By using the inductive hypothesis to assume preservation holds for these three assumptions, we have a $\Gamma^\prime \supseteq \Gamma$ such that $\Gamma^\prime \vdash e_1^\prime : t_1\texttt{ -> }t_2$ and $\Gamma^\prime \vdash \rho^\prime$.

We use this same $\Gamma^\prime$ to prove the exists statement of the theorem. To do this, we want to show that 
1. $\Gamma^\prime \supseteq \Gamma$.
2. $\Gamma^\prime \vdash \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)} : t_2$.
3. $\Gamma^\prime \vdash \rho^\prime$.

(1) and (3) follow from the inductive hypothesis. 

Since the term of (2) is a function application, we aim to prove it using the derivation:

\begin{prooftree}
  \AxiomC{$\Gamma^\prime \vdash e_1^\prime : t_1\texttt{ -> }t_2$}
  \AxiomC{$\Gamma^\prime \vdash e_2 : t_1$}
  \RightLabel{\scriptsize{APP}}
  \BinaryInfC{$\Gamma^\prime \vdash \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)} : t_2$}
\end{prooftree}

The first assumption follows directly from the inductive hypothesis from earlier. 

We prove the second assumption by taking the assumption $\Gamma \vdash e_2 : t_1$ from the initial typing derivation tree:

\begin{prooftree}
  \AxiomC{$\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$}
  \AxiomC{$\color{#048ee0}\boxed{\color{black} \Gamma \vdash e_2 : t_1}$}
  \RightLabel{\scriptsize{APP}}
  \BinaryInfC{$\Gamma \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2$}
\end{prooftree}

and then, since the inductive hypothesis gives us that $\Gamma^\prime \supseteq \Gamma$, we use our weakening lemma to conclude $\Gamma^\prime \vdash e_2 : t_1$ from $\Gamma \vdash e_2 : t_1$.

By proving all of (1), (2) and (3), we've finished proving this case.

The $\text{\scriptsize{APP-RED-2}}$ case follows similarly to $\text{\scriptsize{APP-RED-1}}$, so we now consider the $\text{\scriptsize{BETA-RED}}$ case.

*Sub-case* $\frac{}{\langle \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)}, \rho \rangle \rightsquigarrow \langle e, \rho[x \mapsto v] \rangle} \text{\scriptsize{BETA-RED}}$. 

In this case, the typing derivation takes the form 

\begin{prooftree}
  \AxiomC{$\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$}
  \AxiomC{$\Gamma \vdash v : t_1$}
  \BinaryInfC{$\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)} : t_2$}
\end{prooftree}

so we're looking to show that there exists some $\Gamma^\prime \supseteq \Gamma$ such that $\Gamma^\prime \vdash e : t_2$ and $\Gamma^\prime \vdash \rho[x \mapsto v]$.

Keeping in mind that we want to keep the environment and the typing context in lock-step, and we're extending $\rho$ with $x$, let's try extending $\Gamma$ with $x$ too.
Hence, we'll let $\Gamma^\prime$ be $\Gamma, x : t_1$.

Now we want to show:
1. $\Gamma, x : t_1 \supseteq \Gamma$.
2. $\Gamma, x : t_1 \vdash e : t_2$.
3. $\Gamma, x : t_1 \vdash \rho[x \mapsto v]$.

(1) holds by the definition of $\supseteq$.

We can prove (2) by considering the derivation of $\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)}$.
By assumption, we have $\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$, and, since this is a lambda introduction, this must have been derived from $\Gamma, x : t_1 \vdash e : t_2$, as below.

\begin{prooftree}
  \AxiomC{$\color{#048ee0}\boxed{\color{black}
      \begin{prooftree}
        \AxiomC{$\Gamma, x : t_1 \vdash e : t_2$}
        \RightLabel{\scriptsize{LAM}}
        \UnaryInfC{$\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$}
      \end{prooftree}
    }$}
  \AxiomC{$\Gamma \vdash v : t_1$}
  \RightLabel{\scriptsize{APP}}
  \BinaryInfC{$\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)} : t_2$}
\end{prooftree}

This is exactly (2).

To prove (3), we make use of the assumption $\Gamma \vdash \rho$. 
Since this holds, we must only consider the effect of extending $\Gamma$ and $\rho$ by $x$ to prove (3).

By expanding the definition of the above assumption, we have $\text{dom}(\Gamma) = \text{dom}(\rho)$. 
By the definition of $\text{dom}$, $\text{dom}(\Gamma, x : t_1) = \text{dom}(\rho[x \mapsto v]) = \text{dom}(\Gamma) \cup \set{x}$.

Similarly, by expanding the definition of the assumption, we have $\Gamma \vdash \rho(x^\prime) : \Gamma(x^\prime)$ for all $x^\prime \in \text{dom}(\Gamma)$. To prove this for all $x^\prime \in \text{dom}(\Gamma) \cup \set{x}$, we only need to consider this statement for the additional variable $x$, namely $\Gamma \vdash v : t_1$.
Fortunately, this holds by the other assumption made from the initial typing derivation tree.

\begin{prooftree}
  \AxiomC{$\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$}
  \AxiomC{$\color{#048ee0}\boxed{\color{black} \Gamma \vdash v : t_1}$}
  \RightLabel{\scriptsize{APP}}
  \BinaryInfC{$\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)} : t_2$}
\end{prooftree}

Now that we've proven all of (1), (2) and (3), we've proven that preservation holds in the $\text{\scriptsize{BETA-RED}}$ case, and by extension the entire function application typing case.

{% include infobox.html
  align="start"
  header="Exercise 6"
  text="
  Complete a proof of type preservation for the rest of the Simply-Typed Lambda Calculus.
  "
  color="success" align="center"
%}

{% include infobox.html
  align="start"
  text="
  Typically, beta reduction uses *substitution* instead of our environment system, which makes the preservation proof look a little different.
  In particular, these proofs show that substitution preserves types, before proving type preservation for the whole system.
  To read more on a proof of preservation with a reduction system that uses substitution, check out [Types and Programming Languages](https://i.warosu.org/data/sci/img/0163/64/1725651701869705.pdf), chapter 9.3.
  "
  color="info" align="center"
%}

## **Task**

The task for this exercise is simply stated: prove progress and preservation for the extensions in your language.

Once you're done proving this with pen and paper, you can try proving progress and preservation for your language in Lean!

In particular, you'll need to express the untyped terms and types in your language as inductive types. 
To get you started, here are some terms and types for functions.
```lean
abbrev Id := String

inductive Ty : Type where
  | function : Ty → Ty → Ty 
  | int : Ty 

inductive Term : Type where
  | lambda  : Id → Ty → Term → Term
  | app     : Term → Term → Term
  | var     : Id → Term
  | int_lit : ...
  | add     : ...
```

You'll have to think about what exactly each term or type needs for it to be constructed. 
For example, the `->` constructor takes two other types to form a function type.

We also need to define what values are. 
Implement this as an inductively-defined predicate `Value : Term → Prop`, with constructors for `Value (lambda x t e)` and, for each base type, `Value x` for every `x` in that base type.

Once this is done, define contexts and environments as inductive types, each one having two cases: the `empty` case, and the `extend` case.
We also want to restrict environments to values, so the signature for `extend` will look something like `extend : Env → Id → (v : Term) → {_ : Value v} → Env`, taking the proof that `v` is a value as an implicit argument.
 
Once this is done, we should be able to construct types,
```lean
-- Int
#check Ty.int 

-- Int -> Int -> Int
#check Ty.function Ty.int (Ty.function Ty.int Ty.int) 
```

terms,
```lean
-- 5
#check Term.int_lit 5 

-- ((lambda ((x Int)) (+ x 5)) 3)
#check Term.app (Term.lambda "x" Ty.int (Term.add (Term.var "x") (Term.int_lit 5))) (Term.int_lit 3)
```


typing contexts,
```lean
-- ·
#check Ctx.empty

-- ·, x : Int, y : Int
#check (Ctx.extend "y" Ty.int (Ctx.extend "x" Ty.int Ctx.empty))
```

and environments.
```lean
-- ·
#check Env.empty

-- ·[x ↦ 3][y ↦ 5]
#check (Ctx.extend "y" (Term.int_lit 5) (Ctx.extend "x" (Term.int_lit 3) Ctx.empty))
```

In our overview of progress and preservation, we omitted a formal notion of lookup for typing contexts and environments.
When we're theorem-proving, we need to provide this.

We can think of lookup judgements as derivation trees with two constructors:
\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{HERE}}
  \UnaryInfC{$x : t \in \Gamma, x : t$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$x \neq y$}
  \AxiomC{$x : t_1 \in \Gamma$}
  \RightLabel{\scriptsize{THERE}}
  \BinaryInfC{$x : t_1 \in \Gamma, y : t_2$}
\end{prooftree}

The first rule says that if the context begins with the mapping for $x$, then $x$ is in the context with its associated type.
The second rule says that, if the context begins with a different mapping, we can discard the first mapping and look for $x$ in the rest of the context.
Together, these rules describe a procedure for *searching* through the context.

For example, here is the derivation for the lookup of $x : t_1$ in the context $\Gamma, x : t_1, y : t_2, z : t_3$.

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$x \neq z$}
  \AxiomC{}
  \UnaryInfC{$x \neq y$}
  \AxiomC{}
  \UnaryInfC{$x : t_1 \in \Gamma, x : t_1$}
  \BinaryInfC{$x : t_1 \in \Gamma, x : t_1, y : t_2$}
  \BinaryInfC{$x : t_1 \in \Gamma, x : t_1, y : t_2, z : t_3$}
\end{prooftree}

Implement a new inductive type `CtxLookup : Ctx → Id → Ty → Prop` that can be constructed in two ways, corresponding to the two judgement rules, and another inductive type `EnvLookup : Env → Id → Term → Prop` that does the same for environments.

```lean
-- x : Int ∈ ·, x : Int
example : CtxLookup (Ctx.extend "x" Ty.int Ctx.empty) "x" Ty.int := by  
  apply CtxLookup.here

-- x : Int ∈ ·, x : Int, y : Int 
example : CtxLookup (Ctx.extend "y" Ty.int (Ctx.extend "x" Ty.int Ctx.empty)) "x" Ty.int := by  
  apply CtxLookup.there 
  apply CtxLookup.here
```

We can also use these lookup judgements to define context ordering:
```lean
def Leq Γ Γ' := ∀ x t, Lookup Γ x t → Lookup Γ' x t
```

Once these building blocks have been defined, we can now express the typing and reduction rules of our language in Lean as inductive definitions `Wtt : Ctx → Term → Ty → Prop` and `Red : Term × Env → Term × Env → Prop`.
We can express these rules as implications in Lean; the premises imply the conclusions.

As an example of each,
```lean
inductive Wtt : Ctx → Term → Ty → Prop where 
  | wt_var     : Lookup Γ x t
               → Wtt Γ (Term.var x) t
  | wt_lambda  : Wtt (Context.extend Γ x t₁) e t₂ 
               → Wtt Γ (Term.lambda x t₁ e) (Ty.function t₁ t₂)
  | wt_int_lit : ...
  | wt_add     : ...
  ...

inductive Red : Term × Env → Term × Env → Prop where 
  | red_beta  : Value v 
              → Red (Term.app (Term.lambda x t e) v, ρ) (e, Env.extend ρ x v)
  | red_app_1 : Red (e₁, ρ) (e₁', ρ) 
              → Red (Term.app e₁ e₂, ρ) (Term.app e₁' e₂, ρ)
  | red_app_2 : ...
  | add_app_1 : ...
  | add_app_2 : ...
  | add_app_3 : ...
  ...
```

Once you've completed your typing and derivation rules, you should be able to write Lean proofs for type checking and reduction.
```lean
/- Type checking the term · ⊢ (lambda ((x Int)) (+ x 1)) : Int -> Int -/

example : Wtt Ctx.empty (Term.lambda "x" Ty.int (Term.add (Term.var "x") (Term.int_lit 1))) (Ty.function Ty.int Ty.int) := by
  apply Wtt.wt_lambda
  apply Wtt.wt_add 
  -- ·, x : Int ⊢ x : Int
  apply Wtt.wt_var
  apply Lookup.here
  -- ·, x : Int ⊢ 1 : Int
  apply Wtt.wt_int_lit
```

All that's left to do now before stating our theorems is define our lock-step judgement. We can do this by specifying another derivation rule system:

\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{EMPTY}}
  \UnaryInfC{$\cdot \vdash \cdot$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$\Gamma \vdash v : t$}
  \AxiomC{$\Gamma \vdash \rho$}
  \RightLabel{\scriptsize{EXTEND}}
  \BinaryInfC{$\Gamma, x : t \vdash \rho[x \mapsto v]$}
\end{prooftree}

Similarly to the lookup judgements, implement this as an inductive type `Lockstep : Ctx → Env → Prop`.

Now we can state our theorems! Prove the following:
```lean
theorem progress : 
    Wtt Ctx.empty e t 
    → Value e ∨ ∃ e' ρ', Red (e, ρ) (e', ρ') := by 
  sorry

theorem weakening : 
    Leq Γ Γ'
    → Wtt Γ e t 
    → Wtt Γ' e t := by 
  sorry

theorem preservation : 
    Wtt Γ e t 
    → Red (e, ρ) (e', ρ') 
    → Lockstep Γ ρ 
    → ∃ Γ', Leq Γ Γ' ∧ Wtt Γ' e' t ∧ Lockstep Γ' ρ' := by  
  sorry
```


## Further Reading

Through this step, we've given you an idea of how to prove progress and preservation for your Lisp, but you may be looking for a broader overview.
For this, refer to [Types and Programming Languages](https://i.warosu.org/data/sci/img/0163/64/1725651701869705.pdf), or [University of Cambridge Part IB Semantics](https://www.cl.cam.ac.uk/teaching/2526/Semantics/notes.pdf).

Additionally, progress and preservation aren't the only way to prove type safety. 
You can use a more general proof technique called *logical relations*, which, as well as letting you prove type safety, also lets you prove other theorems. 
These include *strong normalisation* (every sequence of steps ends at a normal form), or statements about program equivalence, such as the statement that the only value of type $\forall a. a \to a$ is $\lambda x.x$.

To read more about logical relations, have a look at Types and Programming Languages, chapter 12, or the [Oregon Programming Languages Summer School course](https://www.cs.uoregon.edu/research/summerschool/summer16/notes/AhmedLR.pdf) on logical relations.


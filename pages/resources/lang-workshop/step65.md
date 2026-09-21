---
layout: page
title: "Step 6.5: Proofs about Types | Language Workshop"
permalink: "/resources/lang-workshop/step65"
latex: true
---

| Length   | Medium                                          |
| Previous | [Step 6: Types](/resources/lang-workshop/step6) |

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
In the example above, $U$ is the type of *natural numbers*, $\mathbb{N}$. In the case of our type system, $U$ would be the type of *well-typed terms* of the form $\Gamma \vdash e : t$.
In this light, the derivation rules of our type system should really be rewritten as

\begin{prooftree}
  \AxiomC{($\Gamma \vdash e_1 : \texttt{Int}$) : Term}
  \AxiomC{($\Gamma \vdash e_2 : \texttt{Int}$) : Term}
  \BinaryInfC{($\Gamma \vdash \texttt{(+ }e_1\texttt{ }e_2\texttt{)}$ : \texttt{Int}) : Term}
\end{prooftree}

but we omit these extra type annotations for brevity. When we write $\frac{}{\Gamma \vdash 3 : \texttt{Int}}$, we don't mean that we have $\Gamma \vdash 3$ of type Int, but rather that the whole thing is of type Term.

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

From the *inductive hypothesis*, we can assume that *left* has a size not exceeding $2^{k_l} - 1$, and *right* has a size not exceeding $2^{k_r} - 1$.
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
It can come about from two properties of type systems: *progress* and *type preservation*. These properties together describe how programs evaluate, and how types interact with program evaluation.

To set up this theorem, we have to talk about how programs *evaluate* in a more formal sense. We'll continue to use deduction rules for this...

### Reduction Rules
To express how programs evaluate, we'll formally introduce the $\rightsquigarrow$ relation, which you can pronounce as "steps to". This relation roughly corresponds to one run of your `eval` function, and is very similar to the `~>` notation we've used before.
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
  \UnaryInfC{$\texttt{(+ }v_1\texttt{ }v_2\texttt{)} \rightsquigarrow v_1 + v_2$}
\end{prooftree}

Together, these rules express the idea of evaluating each argument in turn. 
- If the first argument can evaluate to another expression, we apply the first rule, replacing the first argument with what it steps to in the larger expression. This rule is applied repeatedly until the first argument becomes a value, and cannot be evaluated further.
- Once this occurs, we do the same with the second argument, applying the second rule until the second argument becomes a value and cannot be evaluated further.
- Once both arguments are values, we can evaluate the expression to its *integer sum*. What exactly this is will depend on your implementation.

To describe reduction of functions, just as with types, we need some way to express our *environment* in our reduction system.
To do this, we'll expand $\rightsquigarrow$ to relate *pairs* $\langle e, \rho \rangle$, where $\rho$ represents our environment, instead of just expressions $e$.

We define environments similarly to typing contexts, as follows:
- $\cdot$ represents the empty environment.
- $\rho[x \rightsquigarrow v]$ represents the *extension* of $\rho$ with the new reduction $x \rightsquigarrow v$.

Just as with our type system, we can use a *variable* rule to take out reductions from our environment and use them in reductions of larger expressions.

\begin{prooftree}
  \AxiomC{$\rho(x) = v$}
  \RightLabel{\scriptsize{VAR-RED}}
  \UnaryInfC{$\langle x, \rho \rangle \rightsquigarrow \langle v, \rho \rangle$}
\end{prooftree}

We also extend the previous reduction rules with our new environment representation.

\begin{prooftree}
  \AxiomC{$\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho^\prime \rangle$}
  \RightLabel{\scriptsize{\texttt{+}-RED-1}}
  \UnaryInfC{$\langle \texttt{(+ }e_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(+ }e_1^\prime\texttt{ }e_2\texttt{)}, \rho^\prime \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho^\prime \rangle$}
  \RightLabel{\scriptsize{\texttt{+}-RED-2}}
  \UnaryInfC{$\langle \texttt{(+ }v_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(+ }v_1\texttt{ }e_2^\prime\texttt{)}, \rho^\prime \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{\texttt{+}-RED-3}}
  \UnaryInfC{$\langle \texttt{(+ }v_1\texttt{ }v_2\texttt{)}, \rho \rangle \rightsquigarrow \langle v_1 + v_2, \rho \rangle$}
\end{prooftree}

There is some subtlety to adding environments into our rules.
In the first two rules, we consider $\rho$ stepping as well as $e$. This is to account for $e_1$ containing some mutable operation (like a variable reassignment) that might change our environment.
However, we maintain the same $\rho$ in the last rule, because there is nothing that 

Now we can consider how functions reduce. Here, I'll describe function application.

\begin{prooftree}
  \AxiomC{$\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho^\prime \rangle$}
  \RightLabel{\scriptsize{APP-RED-1}}
  \UnaryInfC{\langle $\texttt{(}e_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)}, \rho^\prime \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{$\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho^\prime \rangle$}
  \RightLabel{\scriptsize{APP-RED-2}}
  \UnaryInfC{$\langle \texttt{(}v_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}v_1\texttt{ }e_2^\prime\texttt{)}, \rho^\prime \rangle$}
\end{prooftree}

\begin{prooftree}
  \AxiomC{}
  \RightLabel{\scriptsize{APP-RED-LAM}}
  \UnaryInfC{$\langle \texttt{((lambda ((x }t\texttt{)) }e\texttt{)}\texttt{ }v\texttt{)}, \rho \rangle \rightsquigarrow \langle e, \rho[x \rightsquigarrow v] \rangle$}
\end{prooftree}

The first two rules evaluate each argument, like with `+`. The last rule evaluates the lambda application by evaluating the expression, with $x$ now mapping to $v$ in our environment, just as it is in our `eval` function.

You may notice that we don't use the argument type $t$ on the right-hand side of the reduction. This is by design; reduction rules aren't concerned with types. The relation between reductions and typing judgements comes with proving type safety.

Let's try an example reduction of the lambda application $\texttt{((lambda ((x Int)) (+ x 1)) (+ 2 3))}$, with an empty initial environment.

We see that the left-hand side of the reduction is a value, so we skip over the APP-RED-1 rule.

The right-hand side of the reduction is not a value, but instead an expression $\texttt{(+ 2 3)}$. 
Noting that $\texttt{2}$ and $\texttt{3}$ are values, we can apply the $\texttt{+}$-RED-3 rule:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\langle \texttt{(+ 2 3)}, \cdot \rangle \rightsquigarrow \langle \texttt{5}, \cdot \rangle$}
\end{prooftree}

Now that we know this, we can apply the APP-RED-2 rule to the lambda application:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\langle \texttt{(+ 2 3)}, \cdot \rangle \rightsquigarrow \langle \texttt{5}, \cdot \rangle$}
  \UnaryInfC{$\begin{aligned} 
                &\,\, \langle \texttt{((lambda ((x Int)) (+ x 1)) (+ 2 3))}, \cdot \rangle \newline
                &\rightsquigarrow \langle \texttt{((lambda ((x Int)) (+ x 1)) 5)}, \cdot \rangle
              \end{aligned}$}
\end{prooftree}

Now that the right-hand side of the application is a value, we can apply APP-RED-LAM to reduce further:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\langle \texttt{(+ 2 3)}, \cdot \rangle \rightsquigarrow \langle \texttt{5}, \cdot \rangle$}
  \UnaryInfC{$\begin{aligned}
                &\,\, \langle \texttt{((lambda ((x Int)) (+ x 1)) (+ 2 3))}, \cdot \rangle \newline
                &\rightsquigarrow \langle \texttt{((lambda ((x Int)) (+ x 1)) 5)}, \cdot \rangle \newline
                &\rightsquigarrow \langle \texttt{(+ x 1)}, \cdot[x \rightsquigarrow \texttt{5}] \rangle
              \end{aligned}$}
\end{prooftree}

Now we're back to a $\texttt{+}$ expression. $\texttt{x}$ can reduce further as a variable, so we extract out the reduction for $\texttt{x}$ from the environment and apply the VAR-RED rule:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\langle \texttt{(+ 2 3)}, \cdot \rangle \rightsquigarrow \langle \texttt{5}, \cdot \rangle$}
  \AxiomC{}
  \UnaryInfC{$\cdot\[x \rightsquigarrow \texttt{5}\](x) = \texttt{5}$}
  \BinaryInfC{$\begin{aligned}
                 &\,\, \langle \texttt{((lambda ((x Int)) (+ x 1)) (+ 2 3))}, \cdot \rangle \newline
                 &\rightsquigarrow \langle \texttt{((lambda ((x Int)) (+ x 1)) 5)}, \cdot \rangle \newline
                 &\rightsquigarrow \langle \texttt{(+ x 1)}, \cdot[x \rightsquigarrow \texttt{5}] \rangle \newline
                 &\rightsquigarrow \langle \texttt{(+ 5 1)}, \cdot[x \rightsquigarrow \texttt{5}] \rangle
               \end{aligned}$}
\end{prooftree}

Finally, since 5 and 1 are values, as before, we apply the $\texttt{+}$-RED-3 rule to arrive at our final reduction:

\begin{prooftree}
  \AxiomC{}
  \UnaryInfC{$\langle \texttt{(+ 2 3)}, \cdot \rangle \rightsquigarrow \langle \texttt{5}, \cdot \rangle$}
  \AxiomC{}
  \UnaryInfC{$\cdot\[x \rightsquigarrow \texttt{5}\](x) = \texttt{5}$}
  \BinaryInfC{$\begin{aligned}
                 &\,\, \langle \texttt{((lambda ((x Int)) (+ x 1)) (+ 2 3))}, \cdot \rangle \newline
                 &\rightsquigarrow \langle \texttt{((lambda ((x Int)) (+ x 1)) 5)}, \cdot \rangle \newline
                 &\rightsquigarrow \langle \texttt{(+ x 1)}, \cdot[x \rightsquigarrow \texttt{5}] \rangle \newline
                 &\rightsquigarrow \langle \texttt{(+ 5 1)}, \cdot[x \rightsquigarrow \texttt{5}] \rangle \newline
                 &\rightsquigarrow \langle \texttt{6}, \cdot[x \rightsquigarrow \texttt{5}] \rangle
               \end{aligned}$}
\end{prooftree}

{% include infobox.html
  align="start"
  header="Exercise 2"
  text="
  Write down the reduction rules for your programming language.
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

Now that we've talked about reduction rules, we can start defining our *progress* and *preservation* properties.

### Progress
Progress says that, for any well-typed term $\cdot \vdash e : t$ in our language, either e is a value, or there exist some $e^\prime$ and $\rho^\prime$ such that $\langle e, \rho \rangle \rightsquigarrow \langle e^\prime, \rho^\prime \rangle$ in our language.

As an example, let's consider the derivation rules we have for functions from Step 6.

*Case* $\frac{\cdot, x : t_1 \vdash e : t_2}{\cdot \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1 \texttt{->} t_2}$.

Here, since $\texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)}$ is a value, the property is trivially true in this case. This also goes for the introduction of an object of any base type.

*Case* $\frac{\cdot \vdash e_1 : t_1 \texttt{->} t_2\,\,\cdot \vdash e_2 : t_1}{\cdot \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2}$.

By applying the inductive hypothesis to $e_1$, we can determine that either $e_1$ is a value, or $\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho^\prime \rangle$.

Let's consider the case that $\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho^\prime \rangle$. Then, by APP-RED-1, $\langle \texttt{(}e_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)}, \rho^\prime \rangle$, as required.

Now consider the case that $e_1$ is some value $v_1$, and consider whether $\texttt{(}v_1\texttt{ }e_2\texttt{)}$ satisfies the desired property.
Let's apply the inductive hypothesis to $e_2$. Either $e_2$ is a value, or $\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho^\prime \rangle$.

If $\langle e_2, \rho \rangle \rightsquigarrow \langle e_2^\prime, \rho^\prime \rangle$, then by APP-RED-2, $\langle \texttt{(}v_1\texttt{ }e_2\texttt{)}, \rho \rangle \rightsquigarrow \langle \texttt{(}v_1\texttt{ }e_2^\prime\texttt{)}, \rho^\prime \rangle$, as required.

If $e_2$ is some value $v$, then, taking $v_1 = \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)}$, by APP-RED-LAM, $\langle \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{)}\texttt{ }v\texttt{)}, \rho \rangle \rightsquigarrow \langle e, \rho[x \rightsquigarrow v] \rangle$, as required.

By applying to the inductive hypothesis to all of our sub-expressions, and applying our reduction rules, we've managed to determine what $\texttt{(}e_1\texttt{ }e_2\texttt{)}$ steps to in every situation!

{% include infobox.html
  align="start"
  header="Exercise 2"
  text="
  Complete a proof of progress for your type system.
  "
  color="success" align="center"
%}

### Type Preservation
Type preservation is a bit trickier than progress. It's a theorem that relates the reduction of an expression $e$ and the typing of $e$.

Part of this will be to prove that reductions maintain that environments and our typing contexts are in lock-step with each other: there isn't anything in one that isn't in the other, and values in the environment have the type of the variable associated with them in the typing context.

We will express this idea using the predicate $\Gamma \vdash \rho$, defined as follows:  
$\Gamma \vdash \rho \stackrel{\text{def}}{=} \text{dom}(\Gamma) = \text{dom}(\rho)$ and, for all $x \in \text{dom}(\Gamma), \Gamma \vdash \rho(x) : \Gamma(x)$.

We're also going to introduce the idea of *ordering* contexts. 
In particular, $\Gamma \subseteq \Gamma^\prime$ is true when $\Gamma^\prime$ has all of the variables $\Gamma$ has (and potentially more), and $\Gamma$ and $\Gamma^\prime$ agree on the types of $\Gamma$'s variables.

This is so that we can define a statement for *weakening*, the idea that extending a context doesn't affect whether an expression produced by that context is well-typed. 
We'll need this for the preservation proof.

<u>Lemma (Weakening)</u>. If $\Gamma \vdash e : t$ and $\Gamma \subseteq \Gamma^\prime$, then $\Gamma^\prime \vdash e : t$.  

...

{% include infobox.html
  align="start"
  header="Exercise 3"
  text="
  Complete a proof of weakening for your type system.
  "
  color="success" align="center"
%}

Once this is proven, we can now state preservation.

<u>Theorem (Preservation).</u> If $\Gamma \vdash e : t$, $\langle e, \rho \rangle \rightsquigarrow \langle e^\prime, \rho^\prime \rangle$ and $\Gamma \vdash \rho$, then there exists some $\Gamma^\prime \supseteq \Gamma$ such that $\Gamma^\prime \vdash e^\prime : t$ and $\Gamma^\prime \vdash \rho^\prime$.

As we did for progress and weakening, let's try proving this for function application.

*Case* $\frac{\Gamma \vdash e_1 : t_1\texttt{ -> }t_2\,\,\Gamma \vdash e_2 : t_1}{\Gamma \vdash \texttt{(}e_1\,e_2\texttt{)}}$.

Let's consider the APP-RED-1 case. By assumption, we have that $\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$, $\langle e_1, \rho \rangle \rightsquigarrow \langle e_1^\prime, \rho^\prime \rangle$ and $\Gamma \vdash \rho$. 
By invoking the inductive hypothesis on these three assumptions, we have a $\Gamma^\prime \supseteq \Gamma$ such that $\Gamma^\prime \vdash e_1^\prime : t_1\texttt{ -> }t_2$ and $\Gamma^\prime \vdash \rho^\prime$.

We use this same $\Gamma^\prime$ to prove the exists statement of the theorem. To do this, we want to show that 
1. $\Gamma^\prime \supseteq \Gamma$.
2. $\Gamma^\prime \vdash \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)} : t_2$.
3. $\Gamma^\prime \vdash \rho^\prime$.

(1) and (3) follow from the inductive hypothesis. 

Since the term of (2) is a function application, we aim to prove it using the derivation:

\begin{prooftree}
  \AxiomC{$\Gamma^\prime \vdash e_1^\prime : t_1\texttt{ -> }t_2$}
  \AxiomC{$\Gamma^\prime \vdash e_2 : t_1$}
  \BinaryInfC{$\Gamma^\prime \vdash \texttt{(}e_1^\prime\texttt{ }e_2\texttt{)} : t_2$}
\end{prooftree}

The first assumption follows directly from the inductive hypothesis from earlier. 

We prove the second assumption by taking the assumption $\Gamma \vdash e_2 : t_1$ from the initial typing derivation tree:

\begin{prooftree}
  \AxiomC{$\Gamma \vdash e_1 : t_1\texttt{ -> }t_2$}
  \AxiomC{$\color{red}\boxed{\color{black} \Gamma \vdash e_2 : t_1}$}
  \BinaryInfC{$\Gamma \vdash \texttt{(}e_1\texttt{ }e_2\texttt{)} : t_2$}
\end{prooftree}

and then, since the inductive hypothesis gives us that $\Gamma^\prime \supseteq \Gamma$, we use our weakening lemma to conclude $\Gamma^\prime \vdash e_2 : t_1$ from $\Gamma \vdash e_2 : t_1$.

By proving all of (1), (2) and (3), we've finished proving this case.

The APP-RED-2 case follows similarly to APP-RED-1, so we now consider the APP-RED-LAM case.

In this case, the typing derivation takes the form 

\begin{prooftree}
  \AxiomC{$\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$}
  \AxiomC{$\Gamma \vdash v : t_1$}
  \BinaryInfC{$\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)} : t_2$}
\end{prooftree}

and the reduction takes the form $\langle \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)}, \rho \rangle \rightsquigarrow \langle e, \rho[x \rightsquigarrow v] \rangle$, so we're looking to show that there exists some $\Gamma^\prime \supseteq \Gamma$ such that $\Gamma^\prime \vdash e : t_2$ and $\Gamma^\prime \vdash \rho[x \rightsquigarrow v]$.

Keeping in mind that we want to keep the environment and the typing context in lock-step, and we're extending $\rho$ with $x$, let's try extending $\Gamma$ with $x$ too.
Hence, we'll let $\Gamma^\prime$ be $\Gamma, x : t_1$.

Now we want to show:
1. $\Gamma, x : t_1 \supseteq \Gamma$.
2. $\Gamma, x : t_1 \vdash e : t_2$.
3. $\Gamma, x : t_1 \vdash \rho[x \rightsquigarrow v]$.

(1) is trivially true.

We can prove (2) by considering the derivation of $\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)}$.
By assumption, we have $\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$, and, since this is a lambda introduction, this must have been derived from $\Gamma, x : t_1 \vdash e : t_2$, as below.

\begin{prooftree}
  \AxiomC{$\color{red}\boxed{\color{black}
      \begin{prooftree}
        \AxiomC{$\Gamma, x : t_1 \vdash e : t_2$}
        \UnaryInfC{$\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$}
      \end{prooftree}
    }$}
  \AxiomC{$\Gamma \vdash v : t_1$}
  \BinaryInfC{$\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)} : t_2$}
\end{prooftree}

This is exactly (2).

To prove (3), we make use of the assumption $\Gamma \vdash \rho$. 
Since this is true, we must only consider the effect of extending $\Gamma$ and $\rho$ by $x$ to prove (3).

By expanding the definition of the above assumption, $\text{dom}(\Gamma) = \text{dom}(\rho)$. 
Extending each of these by $x$ will keep the domains the same relative to each other if they started the same, so $\text{dom}(\Gamma, x : t_1) = \text{dom}(\rho[x \rightsquigarrow v])$.

Similarly, since $\Gamma \vdash \rho(x^\prime) : \Gamma(x^\prime)$ for all $x^\prime \in \text{dom}(\Gamma)$ by expanding the assumption, we now only need to consider this statement for the variable $x$ - $\Gamma \vdash v : t_1$.
Fortunately, this is true by the other assumption made from the initial typing derivation tree.

\begin{prooftree}
  \AxiomC{$\Gamma \vdash \texttt{(lambda ((x }t_1\texttt{)) }e\texttt{)} : t_1\texttt{ -> }t_2$}
  \AxiomC{$\color{red}\boxed{\color{black} \Gamma \vdash v : t_1}$}
  \BinaryInfC{$\Gamma \vdash \texttt{((lambda ((x }t_1\texttt{)) }e\texttt{) }v\texttt{)} : t_2$}
\end{prooftree}

Now that we've proven all of (1), (2) and (3), we've proven that preservation holds in the APP-RED-LAM case, and by extension the entire function application typing case.

{% include infobox.html
  align="start"
  header="Exercise 4"
  text="
  Complete a proof of type preservation for your type system.
  "
  color="success" align="center"
%}

### Type Safety


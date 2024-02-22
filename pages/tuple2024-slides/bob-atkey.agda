{-# OPTIONS --postfix-projections #-}

module tuple where





------------------------------------------------------------------------------
--
--         A Quick Introduction to Denotational Semantics
--                      (perhaps using Agda?)
--
--          Robert Atkey    <robert.atkey@strath.ac.uk>
--
--           Mathematically Structured Programming group
--               Computer and Information Sciences
--                   University of Strathclyde
--
------------------------------------------------------------------------------













------------------------------------------------------------------------------
-- I'll be using the Agda Standard Library:

open import Data.List using ([]; [_]; _++_; List; sum)
open import Data.List.Properties using (sum-++-commute)
open import Data.Nat using (ℕ; _+_)
open import Data.Nat.Properties using (+-identityʳ)
open import Data.Product using (_×_; proj₁; proj₂; _,_)
open import Data.Unit using (⊤; tt)
open import Relation.Binary.PropositionalEquality
   using (_≡_; refl; module ≡-Reasoning; cong; cong₂)

------------------------------------------------------------------------------













------------------------------------------------------------------------------
-- If we write a program in a programming language what will it do
-- when we run it?
--
--    1. It does what it does. (will it do the same thing next time?
--       what if we use a different compiler?)
--
--    2. We all know what it does, it says so there in the code. You
--       just read it.
--
--    3. There is a big thick language specification that tells you.
--
--    4. There is a mathematical description
--         - Operational semantics (as a transition system)
--         - Denotational semantics ...
--
------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- Denotational Semantics
--
-- Key idea: we understand the meaning of the program by composing
-- meanings of the parts.
--
--   - Often matches our intuitive model of the language
--       - “functions” _are_ functions
--
--   - Get to use lots of beautiful mathematics to construct
--     denotational semantics for different purposes, and to relate
--     them.
--
-- Also: using Agda as a mathematical workbench for playing around.
--
------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- The smallest thing that you could call a programming language
--     (thanks to Graham Hutton)


data Type : Set where
  Nat : Type


data Term : Type → Set where
  literal :  (n : ℕ)
        ---------------
           → Term Nat

  _`+_ :     Term Nat
           → Term Nat
        ---------------
           → Term Nat



------------------------------------------------------------------------------













------------------------------------------------------------------------------
-- Standard Semantics

⟦_⟧ : ∀ {T} → Term T → ℕ
⟦ literal n ⟧ = n
⟦ t `+ u    ⟧ = ⟦ t ⟧ + ⟦ u ⟧


-- ⟦_⟧ turns _syntax_ into _semantics_


-- “re-notational pedantics”

------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- Normalisation (by Evaluation)
--
-- Instead of seeing a program as denoting a natural number, let's
-- _normalise_ by the law of associativity:
--
--   ((1 + 4) + 5) + 6  becomes   1 + (4 + (5 + 6))
--
-- Could write this as a source-to-source translation.
--
-- Or... we could treat this as a non-standard semantics...
--
------------------------------------------------------------------------------















------------------------------------------------------------------------------
-- Normalising Semantics
--
-- Idea: replace the interpretation of numbers with one that
-- represents numbers as expressions in normal form, and interpret the
-- two basic operations as manipulations of the normal form expressions.

NFNat : Set
NFNat = List ℕ   -- [ 1 , 2 , 3 ] represents 1 + (2 + (3 + 0))

⟦_⟧NF : NFNat → ℕ
⟦ summands ⟧NF = sum summands

------------------------------------------------------------------------------















------------------------------------------------------------------------------
-- Normalisation as a semantics

-- literals 'n' are represented as 'n + 0'
literalNF : ℕ → NFNat
literalNF n = [ n ]

-- could have
-- literalNF 0 = []

-- Interpret addition as concatenation
--
-- Concatenation essentially implements the rewriting by associativity
addNF : NFNat → NFNat → NFNat
addNF x y = x ++ y

⟦_⟧norm : ∀ {T} → Term T → NFNat
⟦ literal n ⟧norm = literalNF n
⟦ t `+ u    ⟧norm = addNF ⟦ t ⟧norm ⟦ u ⟧norm

------------------------------------------------------------------------------













------------------------------------------------------------------------------
-- Correctness of the normalising semantics

⟦_⟧norm-ok : ∀ {T} (t : Term T) → ⟦ ⟦ t ⟧norm ⟧NF ≡ ⟦ t ⟧
⟦ literal n ⟧norm-ok =
  +-identityʳ n
⟦ t `+ u    ⟧norm-ok =
  begin
    ⟦ addNF ⟦ t ⟧norm ⟦ u ⟧norm ⟧NF   ≡⟨⟩
    ⟦ ⟦ t ⟧norm ++ ⟦ u ⟧norm ⟧NF      ≡⟨⟩
    sum (⟦ t ⟧norm ++ ⟦ u ⟧norm)      ≡⟨ sum-++-commute ⟦ t ⟧norm ⟦ u ⟧norm ⟩
    sum (⟦ t ⟧norm) + sum (⟦ u ⟧norm) ≡⟨ cong₂ _+_ ⟦ t ⟧norm-ok ⟦ u ⟧norm-ok ⟩
    ⟦ t ⟧ + ⟦ u ⟧
  ∎ where open ≡-Reasoning

------------------------------------------------------------------------------












------------------------------------------------------------------------------
-- Correctness as another interpretation
--
-- Instead of proving correctness afterwards, we can define a
-- normalising semantics that is correct by construction.
--
-- We interpret the Nat type as a triple:

record NFCNat : Set where
  field
    value : ℕ                  -- standard semantics
    nf    : NFNat               -- normalised version
    nf-ok : ⟦ nf ⟧NF ≡ value    -- they agree
open NFCNat



-- Key point: if we can interpret every construct of the language in
--   terms of NFCNat, then we get a correct normaliser “for free”.

literalNFC : ℕ → NFCNat
literalNFC n .value = n
literalNFC n .nf = literalNF n
literalNFC n .nf-ok = +-identityʳ n

addNFC : NFCNat → NFCNat → NFCNat
addNFC x y .value = x .value + y .value
addNFC x y .nf = x .nf ++ y .nf
addNFC x y .nf-ok =
  begin
    ⟦ x .nf ++ y .nf ⟧NF      ≡⟨ sum-++-commute (x .nf) (y .nf) ⟩
    ⟦ x .nf ⟧NF + ⟦ y .nf ⟧NF ≡⟨ cong₂ _+_ (x .nf-ok) (y .nf-ok) ⟩
    x .value + y .value
  ∎ where open ≡-Reasoning


-- Correct-by-Construction normalisation semantics
⟦_⟧NFC : ∀ {T} → Term T → NFCNat
⟦ literal n ⟧NFC = literalNFC n
⟦ t `+ u    ⟧NFC = addNFC ⟦ t ⟧NFC ⟦ u ⟧NFC


-- Three derived things:
⟦_⟧std : ∀ {T} → Term T → ℕ
⟦ t ⟧std = ⟦ t ⟧NFC .value

⟦_⟧nf : ∀ {T} → Term T → NFNat
⟦ t ⟧nf = ⟦ t ⟧NFC .nf

⟦_⟧correct : ∀ {T} (t : Term T) → ⟦ ⟦ t ⟧nf ⟧NF ≡ ⟦ t ⟧std
⟦ t ⟧correct = ⟦ t ⟧NFC .nf-ok

------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- Compilation as a semantics
--
--
-- We can see compilation as an alternative semantics.
--
-- The meaning of a program is the code that implements it.
--
-- The meaning of a program is the *correct* code that implements it.

module StackMachine where

  -- Stack shapes
  data StackShape : Set where
    empty : StackShape
    _◁_   : Type → StackShape → StackShape
  infixr 4 _◁_


  -- Instructions, indexed by stack shapes
  data Instr : StackShape → StackShape → Set where
    PUSH : ∀ {σ} → ℕ →
                   Instr σ               (Nat ◁ σ)
    ADD  : ∀ {σ} → Instr (Nat ◁ Nat ◁ σ) (Nat ◁ σ)


  -- Programs are lists of instructions
  data Prog : StackShape → StackShape → Set where
    ε   : ∀ {σ} →
                    ------------------
                         Prog σ σ

    _⍮_ : ∀ {σ₁ σ₂ σ₃} → Instr σ₁ σ₂
                       → Prog σ₂ σ₃
                    ------------------
                       → Prog σ₁ σ₃
  infixr 21 _⍮_



  -- Stacks are indexed by shapes
  data Stack : StackShape → Set where
    empty : Stack empty
    _◁_   : ∀ {σ} → ℕ → Stack σ → Stack (Nat ◁ σ)


  -- Execution
  exec-instr : ∀ {σ₁ σ₂} → Instr σ₁ σ₂ → Stack σ₁ → Stack σ₂
  exec-instr (PUSH x) stk             = x ◁ stk
  exec-instr ADD      (n₁ ◁ n₂ ◁ stk) = (n₁ + n₂) ◁ stk

  exec : ∀ {σ₁ σ₂} → Prog σ₁ σ₂ → Stack σ₁ → Stack σ₂
  exec ε       stk = stk
  exec (i ⍮ p) stk = exec p (exec-instr i stk)

  -- Sticking programs together end-to-end
  _⍮*_ : ∀ {σ₁ σ₂ σ₃} → Prog σ₁ σ₂ → Prog σ₂ σ₃ → Prog σ₁ σ₃
  ε       ⍮* q = q
  (x ⍮ p) ⍮* q = x ⍮ (p ⍮* q)
  infixr 20 _⍮*_

  exec* : ∀ {σ₁ σ₂ σ₃} →
             (p : Prog σ₁ σ₂)(q : Prog σ₂ σ₃) →
             ∀ stk → exec (p ⍮* q) stk ≡ exec q (exec p stk)
  exec* ε       q stk = refl
  exec* (i ⍮ p) q stk = exec* p q (exec-instr i stk)

  ------------------------------------------------------------------------------














  ------------------------------------------------------------------------------
  -- A correct-by-construction compiler
  --
  -- An 'ImplementedNat' consists of:
  --    - an actual natural number            (the spec)
  --    - a program                           (the implementation / “realiser”)
  --    - a proof that they agree             (correctness)

  record ImplementedNat : Set where
    field
      value    : ℕ
      prog     : ∀ {σ} → Prog σ (Nat ◁ σ)
      prog-ok  : ∀ {σ} (stk : Stack σ) → exec prog stk ≡ (value ◁ stk)
  open ImplementedNat


  -- Correct-by-construction compiled literals
  literalImpl : ℕ → ImplementedNat
  literalImpl n .value = n
  literalImpl n .prog = PUSH n ⍮ ε
  literalImpl n .prog-ok stk = refl


  -- Correct-by-construction compiled addition
  addImpl : ImplementedNat → ImplementedNat → ImplementedNat
  addImpl x y .value = x .value + y .value
  addImpl x y .prog  = y .prog ⍮* x .prog ⍮* ADD ⍮ ε
  addImpl x y .prog-ok stk =
    begin
      exec (y .prog ⍮* (x .prog ⍮* (ADD ⍮ ε))) stk         ≡⟨ exec* (y .prog) (x .prog ⍮* (ADD ⍮ ε)) stk ⟩
      exec (x .prog ⍮* (ADD ⍮ ε)) (exec (y .prog) stk)     ≡⟨ exec* (x .prog) (ADD ⍮ ε) _ ⟩
      exec (ADD ⍮ ε) (exec (x .prog) (exec (y .prog) stk)) ≡⟨ cong (λ □ → exec (ADD ⍮ ε) (exec (x .prog) □))
                                                                    (y .prog-ok stk) ⟩
      exec (ADD ⍮ ε) (exec (x .prog) (y .value ◁ stk))     ≡⟨ cong (λ □ → exec (ADD ⍮ ε) □) (x .prog-ok _) ⟩
      exec (ADD ⍮ ε) (x .value ◁ y .value ◁ stk)           ≡⟨⟩
      x .value + y .value ◁ stk
    ∎ where open ≡-Reasoning


  -- Correct-by-construction compiler
  ⟦_⟧Compiler : ∀ {T} → Term T → ImplementedNat
  ⟦ literal n ⟧Compiler = literalImpl n
  ⟦ t `+ u    ⟧Compiler = addImpl ⟦ t ⟧Compiler ⟦ u ⟧Compiler

  -- _ = {!⟦ literal 1 `+ literal 2 ⟧Compiler!}

------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- Languages with variables, towards categories
--
-- The language above is somewhat boring because every program always
-- computes the same thing. Let's make it more interesting by adding
-- variables to the language.


-- Contexts, where variables live
data Context : Set where
  ε   : Context
  _▷_ : Context → Type → Context
infix 5 _▷_


-- Referencing variables in a context
data _∋_ : Context → Type → Set where
  here : ∀ {Γ T}
                  --------------
                    → Γ ▷ T ∋ T

  there : ∀ {Γ S T} →     Γ ∋ T
                   -------------
                    → Γ ▷ S ∋ T
infix 4 _∋_

-- Terms with variables, in context
data _⊢_ : Context → Type → Set where
  var     : ∀ {Γ} → Γ ∋ Nat
               ---------------
                  → Γ ⊢ Nat

  literal : ∀ {Γ}   (n : ℕ)
               ---------------
                  → Γ ⊢ Nat

  _`+_    : ∀ {Γ} → Γ ⊢ Nat
                  → Γ ⊢ Nat
               ---------------
                  → Γ ⊢ Nat
infix 4 _⊢_

------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- The “Standard” semantics
--
-- A program-in-context is modelled as a _function_ from the values of
-- its variables to its value.
--
-- Implicitly: types are modelled as Sets, Nat is modelled as the set
-- of naturals, contexts are modelled as nested tuples.

module standard-semantics where

  ⟦_⟧ty : Type → Set
  ⟦ Nat ⟧ty = ℕ

  ⟦_⟧ctxt : Context → Set
  ⟦ ε ⟧ctxt     = ⊤
  ⟦ Γ ▷ T ⟧ctxt = ⟦ Γ ⟧ctxt × ⟦ T ⟧ty

  ⟦_⟧var : ∀ {Γ T} → Γ ∋ T → ⟦ Γ ⟧ctxt → ⟦ T ⟧ty
  ⟦ here    ⟧var = proj₂
  ⟦ there x ⟧var = λ γ → ⟦ x ⟧var (proj₁ γ)

  ⟦_⟧term : ∀ {Γ T} → Γ ⊢ T → ⟦ Γ ⟧ctxt → ⟦ T ⟧ty
  ⟦ var x     ⟧term = ⟦ x ⟧var
  ⟦ literal n ⟧term = λ γ → n
  ⟦ t `+ u    ⟧term = λ γ → ⟦ t ⟧term γ + ⟦ u ⟧term γ

------------------------------------------------------------------------------















------------------------------------------------------------------------------
-- Abstract semantics
--
-- We want to give many different semantics for this language, but
-- there's a lot going on!
--
-- In the language without variables, we had to model one type and two
-- operations.
--
-- Here, we need a lot more bookkeeping. Let's put everything we need
-- into a big record:

record Sem : Set₂ where
  field
    Obj : Set₁                -- Interpretations of types
    _==>_ : Obj → Obj → Set   -- Interpretations of judgements

    𝟙   : Obj                 -- Empty context
    _⟨×⟩_ : Obj → Obj → Obj    -- Pairing contexts

    -- Composition
    _∘_ : ∀ {X Y Z} → Y ==> Z → X ==> Y → X ==> Z

    -- Operations on pairs
    project₁ : ∀ {X Y} → (X ⟨×⟩ Y) ==> X
    project₂ : ∀ {X Y} → (X ⟨×⟩ Y) ==> Y
    ⟨_,_⟩ : ∀ {X Y Z} → (X ==> Y) → (X ==> Z) → X ==> (Y ⟨×⟩ Z)

    -- Language specific things
    NatObj       : Obj
    literalArrow : ∀ {X} → ℕ → X ==> NatObj
    addArrow     : (NatObj ⟨×⟩ NatObj) ==> NatObj

-- Is this enough? We will see that it is...

------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- Generic semantics
--
-- Given a 'Sem', we get an interpretation of the language as a
-- morphisms from (interpretation of) contexts to (interpretation of)
-- the result type.

module Interpretation (𝒜 : Sem) where

  open Sem 𝒜

  ⟦_⟧ty : Type → Obj
  ⟦ Nat ⟧ty = NatObj

  ⟦_⟧ctxt : Context → Obj
  ⟦ ε     ⟧ctxt = 𝟙
  ⟦ Γ ▷ T ⟧ctxt = ⟦ Γ ⟧ctxt ⟨×⟩ ⟦ T ⟧ty

  ⟦_⟧var : ∀ {Γ T} → Γ ∋ T → ⟦ Γ ⟧ctxt ==> ⟦ T ⟧ty
  ⟦ here    ⟧var = project₂
  ⟦ there x ⟧var = ⟦ x ⟧var ∘ project₁

  ⟦_⟧term : ∀ {Γ T} → Γ ⊢ T → ⟦ Γ ⟧ctxt ==> ⟦ T ⟧ty
  ⟦ var x     ⟧term = ⟦ x ⟧var
  ⟦ literal n ⟧term = literalArrow n
  ⟦ t `+ u    ⟧term = addArrow ∘ ⟨ ⟦ t ⟧term , ⟦ u ⟧term ⟩

------------------------------------------------------------------------------














------------------------------------------------------------------------------
-- Standard Semantics

open Sem

Standard : Sem
Standard .Obj = Set
Standard ._==>_ X Y = X → Y

Standard .𝟙 = ⊤
Standard ._⟨×⟩_ = _×_

Standard ._∘_ = λ f g x → f (g x)

Standard .project₁ = proj₁
Standard .project₂ = proj₂
Standard .⟨_,_⟩ = λ f g x → f x , g x

Standard .NatObj = ℕ
Standard .literalArrow n _ = n
Standard .addArrow (m , n) = m + n

⟦_⟧standard : ε ▷ Nat ⊢ Nat → ℕ → ℕ
⟦ t ⟧standard n = ⟦ t ⟧term (tt , n)
  where open Interpretation Standard

------------------------------------------------------------------------------











------------------------------------------------------------------------------
-- A Normalising Semantics
--
-- Normal forms:
--
--    10 + (x + (y + (z + x)))
--
-- • Variables are rearranged by associativity
-- • Arithmetic on numbers
--
-- Crucial thing to work out: what context do the variables live in.

-- Would this work?
NormType⟨wrong⟩ : Set₁
NormType⟨wrong⟩ = Set

-- NormNat⟨wrong⟩ : NormType⟨wrong⟩
-- NormNat⟨wrong⟩ = Σ[ Γ ∈ Context ] ℕ × List {!Γ ∋ Nat!}

------------------------------------------------------------------------------























------------------------------------------------------------------------------
-- A Normalising Semantics (towards presheaves)

-- Types are now interpreted relative to a context
NormType : Set₁
NormType = Context → Set


NormMor : NormType → NormType → Set
NormMor X Y = ∀ Γ → X Γ → Y Γ


_∘N_ : ∀ {X Y Z} → NormMor Y Z → NormMor X Y → NormMor X Z
f ∘N g = λ Γ z → f Γ (g Γ z)


𝟙N : NormType
𝟙N Γ = ⊤


_×N_ : NormType → NormType → NormType
(X ×N Y) Γ = X Γ × Y Γ


normProj₁ : ∀ {X Y} → NormMor (X ×N Y) X
normProj₁ = λ Γ → proj₁


normProj₂ : ∀ {X Y} → NormMor (X ×N Y) Y
normProj₂ = λ Γ → proj₂


normPair : ∀ {X Y Z} → NormMor X Y → NormMor X Z → NormMor X (Y ×N Z)
normPair f g = λ Γ z → f Γ z , g Γ z

------------------------------------------------------------------------------












------------------------------------------------------------------------------
-- Normalisation

NormNat : NormType
NormNat Γ = ℕ × List (Γ ∋ Nat)

normLit : ∀ {X} → ℕ → NormMor X NormNat
normLit n Γ _ = n , []

normAdd : NormMor (NormNat ×N NormNat) NormNat
normAdd Γ ((n₁ , vs₁) , (n₂ , vs₂)) = (n₁ + n₂) , (vs₁ ++ vs₂)




NormSem : Sem
NormSem .Obj = NormType
NormSem ._==>_ = NormMor
NormSem .𝟙 = 𝟙N
NormSem ._⟨×⟩_ = _×N_
NormSem ._∘_ = _∘N_
NormSem .project₁ = normProj₁
NormSem .project₂ = normProj₂
NormSem .⟨_,_⟩ = normPair
NormSem .NatObj = NormNat
NormSem .literalArrow = normLit
NormSem .addArrow = normAdd




normalise : ε ▷ Nat ⊢ Nat → ℕ × List (ε ▷ Nat ∋ Nat)
normalise t = ⟦ t ⟧term (ε ▷ Nat) (tt , (0 , [ here ]))
  where open Interpretation NormSem


------------------------------------------------------------------------------











------------------------------------------------------------------------------
-- A Quick Introduction to Denotational Semantics
--
-- Denotational semantics is the definition of the meaning of programs
-- in terms of their subparts (“compositionally”)
--
-- Surprisingly many properties of a language can be deduced by
-- choosing well designed semantics
--
-- Lots of places to go:
--
--     polymorphic and dependent types?   Fibrations, CwFs, ...
--
--     substructural types?    monoidal categories, comonads, ...
--
--     infinite data or behaviour?   Domain theory, topos of trees
--
--     connecting to program reasoning?   Categorical Logic, temporal logics
--
--     concurrency, state, non-determinism, probability, distribution, ..., monads
--
-- Reusable tools: categories, fibrations, (pre)sheaves, glueing, ...
--
------------------------------------------------------------------------------

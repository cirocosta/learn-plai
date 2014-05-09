# Parsing?

>   Parsing or syntactic analysis is the process of analysing a string of symbols, either in natural language or in computer languages, according to the rules of a formal grammar.

From a character stream we convert it to a structured internal representation, while checking for correct syntax in the process. In our case, a tree, which programs can recursively process it and do whatever it wants.

>   Within computational linguistics the term is used to refer to the formal analysis by a computer of a sentence or other string of words into its constituents, resulting in a parse tree showing their syntactic relation to each other, which may also contain semantic and other information.

## The Process

Before understanding the process, which is composed of the lexycal and the syntactical phases, we need to understand what it means each of these.

>    **Lexycal Analysis** is the process of converting a sequence of characters into a sequence of tokens, i. e. meaningful character strings.

First, it takes a character stream and splits it into meaningful symbols defined by a particular grammar. Then it checks that the tokens form an allowable expression. After that, it is time for semantic parsing, which is working out the implications of the expression which was evaluated and then performing a particular action.

## Our first Language

Our first language will only be valid for some simple arithmetic. We start by defining our most simple datastructure:

```scheme
(define-type ArithC
  [numC (n : number)]
  [plusC (l : ArithC) (r : ArithC)]
  [multC (l : ArithC) (r : ArithC)])
```

This one will only have sum and multiplication.

We have then to construct a parser, which will translate an s-expression to our internal datastructure.

```scheme

; Given a s-expression, returns an ArtihC object so that the interpreter
; is able to understand what is being passed to it.

(define (parse [s : s-expression]) : ArithC
  (cond
    [(s-exp-number? s) (numC (s-exp->number s))]
    [(s-exp-list? s)
     (let ([sl (s-exp->list s)])
       (case (s-exp->symbol (first sl))
         [(+) (plusC (parse (second sl)) (parse (third sl)))]
         [(*) (multC (parse (second sl)) (parse (third sl)))]
         [else (error 'parse "invalid list input")]))]
    [else (error 'parse "invalid input")]))
```

and also an interpreter which will handle our internal datastructure, evaluate it and return the result of it (in this case, a number):

```scheme
(define (interp [a : ArithC]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l) (interp r))]
    [multC (l r) (* (interp l) (interp r))]))
```


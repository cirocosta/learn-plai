# Sugaring our language

From now on we are able to perform almost anything in terms of math. Lots of stuff derives from sum and multiplication. But what if we would like our users to be able to express subtraction in the way everybody is used to?

## Syntatic Sugar

> **syntactic sugar** is syntax within a programming language that is designed to make things easier to read or to express. It makes the language "sweeter" for human use: things can be expressed more clearly, more concisely, or in an alternative style that some may prefer. (...) a construct in a language is called syntactic sugar if **it can be removed from the language without any effect on what the language can do**.

To include subtraction we just need to change the signal and then perform the sum operation. We'll now build a new tree (*ArithS*) which it'll then be transformed to *ArithC*, which contains the core.

Let's start building our new datastructure:

```scheme

(define-type ArithS
  [numS (n : number)]
  [plusS (l : ArithS) (r : ArithS)]
  [bminusS (l : ArithS) (r : ArithS)]
  [multS (l : ArithS) (r : ArithS)])
```

Having *ArithS* built, create a desugar function so that we don't need to change our interpreter:

```scheme
(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS (n) (numC n)]
    [plusS (l r) (plusC (desugar l) (desugar r))]
    [multS (l r) (multC (desugar l) (desugar r))]
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]))
```

Now update our parser to be able to understand the subtraction operator:

```scheme
(define (parse [s : s-expression]) : ArithS
  (cond
    [(s-exp-number? s) (numS (s-exp->number s))]
    [(s-exp-list? s)
     (let ([sl (s-exp->list s)])
       (case (s-exp->symbol (first sl))
         [(+) (plusS (parse (second sl)) (parse (third sl)))]
         [(*) (multS (parse (second sl)) (parse (third sl)))]
         [(-) (bminusS (parse (second sl)) (parse (third sl)))]
         [else (error 'parse "invalid list inpput")]))]
    [else (error 'parse "invalid input")]))
```

**//TODO menos unário**

**//TODO condicional**

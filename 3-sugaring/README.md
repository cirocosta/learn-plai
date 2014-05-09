# Sugaring our language

From now on we are able to perform almost anything in terms of math. Lots of stuff derives from sum and multiplication. But what if we would like our users to be able to express subtraction in the way everybody is used to?

## Syntatic Sugar

> **syntactic sugar** is syntax within a programming language that is designed to make things easier to read or to express. It makes the language "sweeter" for human use: things can be expressed more clearly, more concisely, or in an alternative style that some may prefer. (...) a construct in a language is called syntactic sugar if **it can be removed from the language without any effect on what the language can do**.

### Subtraction

To include subtraction we just need to change the signal and then perform the sum operation. We'll now build a new tree (*ArithS*) which will then be transformed to *ArithC*, which contains the core.

Let's start building our new datastructure:

```scheme
(define-type ArithS
  [numS (n : number)]
  [plusS (l : ArithS) (r : ArithS)]
  [bminusS (l : ArithS) (r : ArithS)]
  [multS (l : ArithS) (r : ArithS)])
```

Having *ArithS* built, create a desugar function so that we don't need to change our interpreter (i.e, we keep the interpreter receiving a ArithC - something it understands -, evaluating it, and then returning a number):

```scheme
(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS (n) (numC n)]
    [plusS (l r) (plusC (desugar l) (desugar r))]
    [multS (l r) (multC (desugar l) (desugar r))]
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]))
```

The parser, however, has to be changed. This occurs because the parser is the *frontend* of the compiler and it then needs to understand what's going on before things get done in the background. Let's do it!

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

### Unary Minus

Just like we did with subtraction, we need to add something new to our `ArithS`, to our `desugar` function and also to the parser:

```scheme
(define-type ArithS
  [numS (n : number)]
  [plusS (l : ArithS) (r : ArithS)]
  [bminusS (l : ArithS) (r : ArithS)]
  [uminusS (e: ArithS)]
  [multS (l : ArithS) (r : ArithS)])
```

As `uminusS` is, by definition, an unary operator, it will receive only one argument, which is different from the others.

```scheme
(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS (n) (numC n)]
    [plusS (l r) (plusC (desugar l) (desugar r))]
    [multS (l r) (multC (desugar l) (desugar r))]
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]
    [uminusS (e) (multC (numC -1) (desugar e))]))
```

Then we get the following parser:

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
         [(~) (uminusS (parse (second sl)))]
         [else (error 'parse "invalid list inpput")]))]
    [else (error 'parse "invalid input")]))
```


### Conditional

For implementing conditional in our language we are going to establish the folowing assumption: *everything that evaluates to 0 will be treated as false, otherwise, true*.

As this is a core functionality that we are adding to our language, this must, then, be at its core: ArithC.

```scheme
(define-type ArithC
  [numC (n : number)]
  [plusC (r : ArithC) (l : ArithC)]
  [multC (r : ArithC) (l : ArithC)]
  [ifC (condition : ArithC) (yes : ArithC) (no : ArithC)])
```

But, as ArithS is the main entrance to our core structure, it has to implement it as well:

```scheme
(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS (n) (numC n)]
    [plusS (l r) (plusC (desugar l) (desugar r))]
    [multS (l r) (multC (desugar l) (desugar r))]
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]
    [uminusS (e) (multC (numC -1) (desugar e))]
    [ifS (c : ArithS) (y : ArithS) (n : ArithS)]))
```

As ArithS changed, so does desugar:

```scheme
(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS (n) (numC n)]
    [plusS (l r) (plusC (desugar l) (desugar r))]
    [multS (l r) (multC (desugar l) (desugar r))]
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]
    [uminusS (e) (multC (numC -1) (desugar e))]
    [ifS (c y n) (ifC (desugar y) (desugar s) (desugar n))]))
```

and so the parser:


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
         [(~) (uminusS (parse (second sl)))]
         [(if) (ifS (parse (second sl))
                    (parse (third sl))
                    (parse (fourth sl)))]
         [else (error 'parse "invalid list inpput")]))]
    [else (error 'parse "invalid input")]))
```

## And the interpreter?

For the interpreter we just need to pass something to it that it understands:

```scheme
(define (interpS [a : ArithS]) : number
  (interp (desugar a)))
```

For example:

```scheme
(interpS (parse ’(if (- 3 2) 42 (+ 5 8))))
```

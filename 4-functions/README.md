# Functions

Before jumping right into the code, some explanation has to be done:

- **declaration** is the contract that the function does;
- **parameters** are not variables, but a simple association between symbols and values;
- **application** is calling the function, which is an operation by itself.

They are going to be defined by a new type, `FunDefC`:

```scheme
(define-type FunDefC
  [fdC (name : symbol)
       (arg : symbol)
       (body : ExprC)])
```


## The Core

For this we are going to construct a new language. That's because we are renaming our core and adding some new functionality to it.

These additional things are `idC` and `appC`. The first one is a identifier, which will be used for the arguments of the functions, and the second one for the application of the functions (how we are going to represent a call to a particular function with an argument being passed to it).

```scheme
(define-type ExprC
  [numC (n : number)]
  [plusC (r : ExprC) (l : ExprC)]
  [multC (r : ExprC) (l : ExprC)]
  [idC (s : symbol)]
  [appC (fun : symbol) (arg : ExprC)]
  [ifC (condition : ExprC) (yes : ExprC) (no : ExprC)])
```

## Syntatic Sugar

If we want to keep with the syntatic sugar that we've add we need to define a ExprS and also a desugar function:

```scheme
(define-type ExprS
  [numS (n : number)]
  [plusS (l : ExprS) (r : ExprS)]
  [bminusS (l : ExprS) (r : ExprS)]
  [uminusS (e: ExprS)]
  [multS (l : ExprS) (r : ExprS)]
  [idS (s : symbol)]
  [appS (fun : symbol) (arg : ExprS)]
  [ifS (c : ExprS) (y : ExprS) (n : ExprS)])
```

```scheme
(define (desugar [as : ExprS]) : ExprC
  (type-case ExprS as
    [numS (n) (numC n)]
    [plusS (l r) (plusC (desugar l) (desugar r))]
    [multS (l r) (multC (desugar l) (desugar r))]
    [idS (s) (idC s)] ; symbol does not need desugar
    [appS (fun arg) (appC (fun (desugar arg)))] ; fun does not require desugar
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]
    [uminusS (e) (multC (numC -1) (desugar e))]
    [ifS (c y n) (ifC (desugar y) (desugar s) (desugar n))]))
```

## The Intepreter

Here is were unicorns starts appearing. We just defined that in `ExprC` we call a function by passing a symbol as its name and a `ExprC` as arg. But, where does the function definition lives? It lives in a list with function definitions that we must have.

We have then to define a mechanism to get the definition from a list and prepare it with the argument passed.

We need, so, two functions: `get-fundef` and `subst`. The first one will be a linear-search which goes into a list and tries to find the definition of a function (given a symbol). The second one will substitute the values before the actual call (urgh!).

```scheme
(define (get-fundef [n : symbol] [fds : (listof FunDefC)]) : FunDefC
  (cond
    [(empty? fds) (error 'get-fundef "referencia para funcao nao definida")]
    [(cons? fds) (cond
                   [(equal? n (fdC-name (first fds))) (first fds)]
                   [else (get-fundef n (rest fds))])]))
```

now subst will have a bit more logic:

```scheme
(define (subst [valor : ExprC] [isso : symbol] [em : ExprC]) : ExprC
  (type-case ExprC em
    [numC (n) em]
    [idC (s) (cond
               [(symbol=? s isso) valor]
               [else em])]
    [appC (f a) (appC f (subst valor isso a))]
    [plusC (l r) (plusC (subst valor isso l) (subst valor isso r))]
    [multC (l r) (multC (subst valor isso l) (subst valor isso r))]
    [ifC (c s n) (ifC (subst valor isso c)
                      (subst valor isso s)
                      (subst valor isso n))]))
```

and then the interpreter with everything together:

```scheme
(define (interp [a : ExprC] [fds : (listof FunDefC)]) : number
  (type-case ExprC a
    [numC (n) n]; subst must only happen with application of function
    [appC (f a)
      (local ([define fd (get-fundef f fds)]) ; get the function definition
        (interp (subst a ; interp the result of the substitution
                       (fdC-arg fd)
                       (fdC-body fd))
                 fds))]
    ; it should not remain any identifiers in the expression
    [idC (_) (error ’ interp " não deveria encontrar isso!")]
    [plusC (l r) (+ (interp l fds) (interp r fds))]
    [multC (l r) (* (interp l fds) (interp r fds))]
    [ifC (c s n) (if (zero ? (interp c fds)) (interp n fds) (interp s
    fds))]))
```

## The Parser

```scheme
(define (parse [s : s-expression]) : ExprS
  (cond
    [(s-exp-number? s) (numS (s-exp->number s))]
    [(s-exp-list? s)
     (let ([sl (s-exp->list s)])
       (case (s-exp->symbol (first sl))
         [(+) (plusS (parse (second sl)) (parse (third sl)))]
         [(*) (multS (parse (second sl)) (parse (third sl)))]
         [(-) (bminusS (parse (second sl)) (parse (third sl)))]
         [(~) (uminusS (parse (second sl)))]
         [(call) (appS (s-exp->symbol (second sl)) (parse (third sl)))]
         [(if) (ifS (parse (second sl))
                    (parse (third sl))
                    (parse (fourth sl)))]
         [else (error 'parse "invalid list inpput")]))]
    [else (error 'parse "invalid input")]))
```

// **TODO** responder ás questões dessa parte

### Testes

```scheme
(define lib
  (list
    [fdC 'double 'x (plusC (idC 'x) (idC 'x))]
    [fdc 'square 'y (multC (idC 'y) (idC 'y))]))
```

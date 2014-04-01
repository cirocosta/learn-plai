#lang plai-typed

; -- UNARY STUFF!

; A unary operation is an operation with only one operand, i.e, a single
; input. It is a function `f: a -> a`. Here we are wanting to provide
; the negation of a value, i.e, something multiplied by the -1.

; How to approach that? Sugar!

; keep the ArithC
(define-type ArithC
  [numC (n : number)]
  [plusC (l : ArithC) (r : ArithC)]
  [multC (l : ArithC) (r : ArithC)])


; Include both bMinus (defined earlier) and uminus (which we are
; defining now)
(define-type ArithS
  [numS    (n : number)]
  [plusS   (l : ArithS) (r : ArithS)]
  [bminusS (l : ArithS) (r : ArithS)]
  [uminusS (e : ArithS)]
  [multS   (l : ArithS) (r : ArithS)])


; Adding some new stuff to the desugar procedure

; //TODO do this in a better way

(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS    (n)   (numC n)]
    [plusS   (l r) (plusC (desugar l) (desugar r))]
    [multS   (l r) (multC (desugar l) (desugar r))]
    [bminusS (l r) (plusC (desugar l) (multC (numC -1) (desugar r)))]

    ; //TODO explain the wrong approaches to this. It is a great
    ; //exercise to find how could we break it.

    [uminusS (e)   (multC (numC -1) (desugar e))]
    ))


; The interpreter keeps the same.
(define (interp [a : ArithC]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l) (interp r))]
    [multC (l r) (* (interp l) (interp r))]))


; o parser muda mais um pouco
(define (parse [s : s-expression]) : ArithS
  (cond
    [(s-exp-number? s) (numS (s-exp->number s))]
    [(s-exp-list? s)
     (let ([sl (s-exp->list s)])
       (case (s-exp->symbol (first sl))
         [(+) (plusS (parse (second sl)) (parse (third sl)))]
         [(*) (multS (parse (second sl)) (parse (third sl)))]
         [(-) (bminusS (parse (second sl)) (parse (third sl)))]
         ; para o parser precisamos um sinal negativo...
         [(~) (uminusS (parse (second sl)))]
         [else (error 'parse "invalid list input")]))]
    [else (error 'parse "invalid input")]))

(test (interp (desugar (uminusS (numS 3) ))) -3)


(define (interpS [a : ArithS]) (interp (desugar a)))

(interpS (parse '(+ 5 (~ 3))))



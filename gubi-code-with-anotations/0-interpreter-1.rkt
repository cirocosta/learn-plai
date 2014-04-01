#lang plai-typed

; Defining the structure hat we'll use for the parser. This is a tree
; which may contain a number, a plusC operator (which takes 2
; artithmetic expressions) or a multC operator (the same as the last).
(define-type ArithC
  [numC (n : number)]
  [plusC (l : ArithC) (r : ArithC)]
  [multC (l : ArithC) (r : ArithC)])

; Defining the parser, which takes a s-expression and then converts it
; to an ArithC, which we are then able to interpret it and know its
; result. This is the process of taking an unknown input and
; transforming to a particular structure which our language is able to
; understand.
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

; Defining a simple interpreter, which takes an ArithC structure and
; then returns its result (number).
(define (interp [a : ArithC]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l) (interp r))]
    [multC (l r) (* (interp l) (interp r))]))

; Testing it so that we are able to quickly know if we had done any
; mistake so far.

(parse '(+ (* 1 2) (+ 2 3)))

(interp (parse  '(+ (* 1 2) (+ 2 3))))
(test
  (interp
    (parse  '(* (+ 1 2) (+ 6 8)))) 43)  ; errado!
(test
  (interp
    (parse  '(+ (* (* 12 12) 12) 1))) (+ (* 9 (* 9 9 )) (* 10 ( * 10 10)))) ; v. Ramanujan
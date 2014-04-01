#lang plai-typed

; -- CONDITIONALS --

; For adding conditionals to our language there's not so much of things
; to do: suppose that 0 == false and all the rest are truthy.

(define-type ArithC
  [numC (n : number)]
  [plusC (l : ArithC) (r : ArithC)]
  [multC (l : ArithC) (r : ArithC)]
  [ifC (condition : ArithC) (yes : ArithC) (no : ArithC)])

(define (interp [a : ArithC]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l) (interp r))]
    [multC (l r) (* (interp l) (interp r))]
    [ifC (c s n) (if (zero? (interp c))
                      (interp n)
                      (interp s))]
  )
)

; //TODO explain better and provide de parser
; //TODO perform some tests
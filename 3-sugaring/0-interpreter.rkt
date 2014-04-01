; here we implement an interpreter which evaluates an ArithC expression
; an then reduces it to a number, which is the final result of what that
; arithmetic expressions do.

(define (interp [a : ArithC]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l) (interp r))]
    [multC (l r) (* (interp l) (interp r))]))
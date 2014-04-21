#lang plai-typed

; defining the datastructure that we'll use for the parser.
(define-type ArithC
  [numC (n : number)]
  [plusC (r : ArithC) (l : ArithC)]
  [multC (r : ArithC) (l : ArithC)])

; given a s-expression, returns an ArtihC object.
(define (parse [s : s-expression]) : ArithC
  (cond
    ; check if S is a number. if it is, instantiate a numC with it
    [(s-exp-number? s) (numC (s-exp->number s))]
    ; check if S is a list. If true,
    [(s-exp-list? s)
      ; create `sl` mapping to `s` parsed to a list of s-expressions
     (let ([sl (s-exp->list s)])
        ; will check the the symbol of the first elem of the s-exp list
       (case (s-exp->symbol (first sl))
          ; instantiate plusC if the symbol is a '+'
         [(+) (plusC (parse (second sl)) (parse (third sl)))]
          ; instantiate multC if the symbol is a '*'
         [(*) (multC (parse (second sl)) (parse (third sl)))]
          ; something wrong
         [else (error 'parse "invalid list input")]))]
    ; if not a list and not a number, then it is an invalid thing.
    [else (error 'parse "invalid input")]))


(define (interp [a : ArithC]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l) (interp r))]
    [multC (l r) (* (interp l) (interp r))]))

#lang plai-typed

; defining the datastructure that we'll use for the parser.
(define-type ArithC
  [numC (n : number)]
  [plusC (r : ArithC)
         (l : ArithC)]
  [multC (r : ArithC)
         (l : ArithC)])

; given a s-expression, returns an ArtihC object.
(define (parse [s : s-expression]) : ArithC
  (cond
    ; check if S is a number. if it is, instantiate a numC with it
    [(s-exp-number? s) (numC (s-exp->number s))]
    ; check if S is a list. If true,
    [(s-exp-list? s)
      ; create sl mapping to s parsed to a list of s-expressions
     (let ([sl (s-exp->list s)])
        ; will check the the symbol of the first elem of the s-exp list
       (case (s-exp->symbol (first sl))
          ; instantiate plusC
         [(+) (plusC (parse (second sl)) (parse (third sl)))]
          ; instantiate multC
         [(*) (multC (parse (second sl)) (parse (third sl)))]
          ; something wrong
         [else (error 'parse "invalid list input")]))]
    ; if not a list and not a number, then it is an invalid thing.
    [else (error 'parse "invalid input")]))

; Case sounds strange? that's because it is a bit.
; Here comes its syntax:

; case(expr
;   [(datum ...) body ...]
;   ...)

; The 'case(expr)' is like initiating the switch statement with exp
; being the switch expression and the 'datums' being the case expression
; thinking of a switch. What comes after the '(datum)' is the code to
; be executed.
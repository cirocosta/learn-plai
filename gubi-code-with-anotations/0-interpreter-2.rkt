#lang plai-typed

; -- ADDING SUBTRACTION TO OUR LANGUAGE --

; Keep the old ArithC structure as a substraction is just adding a
; negative number.

(define-type ArithC
  [numC (n : number)]
  [plusC (l : ArithC) (r : ArithC)]
  [multC (l : ArithC) (r : ArithC)])


; The idea here is to NOT modify ArithC just to accept a minus sign. If
; we do that (modify it), we'd have to modify all of the programs that
; processes ArithC (for now, only the interpreter, but it could be a lot
; worse). The other reason why we must not change ArithC is that AirithC
; represents our CORE language. Separating the core from the surface is
; a MUST.


; Define a new one (ArithS) which will be converted to ArithC so that
; the language is able to understand what's going on

(define-type ArithS
  [numS    (n : number)]
  [plusS   (l : ArithS) (r : ArithS)]
  [bminusS (l : ArithS) (r : ArithS)]
  [multS   (l : ArithS) (r : ArithS)])

; Now that we have the ArithS data structure, we need a procedure to
; convert it to a valid ArithC expression (by doing this we don't even
; have to change our basic interpreter).

; We'll call this de(sugaring). The desugaring phase will do the follow:

; ArithS(- a b) -->  ArithC(+ a (* -1 b))

(define (desugar [as : ArithS]) : ArithC
  (type-case ArithS as
    [numS    (n)   (numC n)]            ; direct conversion
    [plusS   (l r) (plusC (desugar l)   ; remove sugar from everybody
                         (desugar r))]
    [multS   (l r) (multC (desugar l)
                        (desugar r))]
    [bminusS (l r) (plusC (desugar l)   ; applying the transformation
                      (multC (numC -1) (desugar r)))]
  )
)

; We can't forget to remove the sugar from everybody (applying the
; recursive calls to desugar also L and R).

; As we expected, the interpreter still the same

(define (interp [a : ArithC]) : number
  (type-case ArithC a
    [numC (n) n]
    [plusC (l r) (+ (interp l) (interp r))]
    [multC (l r) (* (interp l) (interp r))]))


; The parser (which is the foremost thing) also changes as it has to
; accept the minus sign that may come.
(define (parse [s : s-expression]) : ArithS
  (cond
    [(s-exp-number? s) (numS (s-exp->number s))]
    [(s-exp-list? s)
     (let ([sl (s-exp->list s)])
       (case (s-exp->symbol (first sl))
         [(+) (plusS (parse (second sl)) (parse (third sl)))]
         [(*) (multS (parse (second sl)) (parse (third sl)))]
         [(-) (bminusS (parse (second sl)) (parse (third sl)))]
         [else (error 'parse "invalid list input")]))]
    [else (error 'parse "invalid input")]))

(define (ArithS->ArithC [as : ArithS]) (desugar as))
(test (interp (desugar (bminusS (numS 3) (numS 2)))) 1)

; What if we define a interpS? (remembering tha we don't need to do
; this)
(define (interpS [a : ArithS]) (interp (desugar a)))

(interpS (plusS (numS 45) (bminusS  (multS (numS 2) (numS 1)) (numS 5))))

(parse '(+ (* 1 2) (+ 2 3)))

(interpS (parse '(+ (* 1 2) (+ 2 3))))

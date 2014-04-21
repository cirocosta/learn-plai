
(define-type ExprC
  [numC (n : number)]
  [idC (s : symbol)] ; identifier for the arguments
  [appC (fun : symbol) (arg : ExprC)] ; aplication, with the name of the
                                      ; function and the argument
  [plusC (l : ExprC) (r : ExprC)]
  [multC (l : ExprC) (r : ExprC)]
  [ifC (condicao : ExprC) (sim : ExprC) (nao : ExprC)])

; take a look and notice that there is a difference between `function
; definition` - describing what the function is - and `function
; application` - using it.

; notice, also, that we are talking about Identifiers here for the
; arguments. We are calling in that way because we are thinking about a
; structure which will tell the interpreter to exchange that identifier
; by something which that identifies.


; Iniciaremos o desenvolvimento de funções em nossa linguagem apenas
; tornando-a passível de receber funções e aplicá-las. Apenas depois
; passaremos a tornar possível a definição de outras.

(define-type FunDefC
  [fdC (name : symbol)
       (arg: symbol)
       (body : exprC)])

; now that we've defined the function and the expr that contains the
; expression, let's define an interpreter for that. The interpreter will
; need to exchange the arguments values and also receive a list with the
; function definitions . In the application part, the function's name will
; need to be find on a list, which it'll be done by `get-fundef`.

; get-fundef : symbol * (listof FunDefC) -> FunDefC
; subst : ExprC * symbol * ExprC -> ExprC


; em ordem, a funcao subst irá substituir o VALOR no símbolo ISSO na
; expressao EM. Isto é, substitui o símbolo ISSO por VALOR na expressão
; EM.
(define (subst [valor : ExprC] [isso : symbol] [em : ExprC]) : ExprC
  ; analisando o tipo da expressão passada
  (type-case ExprC em
    [numC (n) em] ; nada para substituir, repassa
    [idC (s) (cond ; poderia ser um 'if', mas existem coisas no futuro
               [(symbol=? s isso) valor] ; se é simbolo, troque.
               [else em])] ; caso contrario, nao faca nada
    ; chamada de funcao e arruma o argumento
    [appC (f a) (appC f (subst valor isso a))]
    [plusC (l r) (plusC (subst valor isso l) (subst valor isso r))]
    [multC (l r) (multC (subst valor isso l) (subst valor isso r))]
    [ifC (c s n) (ifC (subst valor isso c)
                      (subst valor isso s) (subst valor isso n))]))


; agora o interpretador.

(define (interp [a : ExprC] [fds : (listof FunDefC)]) : number
  (type-case ExprC a
    ; recebendo apenas um numero, retorna apenas o numero
    [numC (n) n]
    ; recebendo uma aplicacao
    [appC (f a)
      ; definimos localmente o FD como a FunDefC que obtemos passando o
      ; symbol `f` e a lista das funcoes (obtemos a definicao da funcao)
          (local ([define fd (get-fundef f fds)])
           ; intepretamos a aplicacao ja substituidos os argumentos
            (interp (subst a
                           (fdC-arg fd)
                           (fdC-body fd)
                           )
                    fds))]
    ; nao espera-se um identificador - ja que estamos substituindo antes
    [idC (_) (error 'interp "nao deveria encontrar isso!")]
    [plusC (l r) (+ (interp l fds) (interp r fds))]
    [multC (l r) (* (interp l fds) (interp r fds))]
    [ifC (c s n) (if (zero? (interp c fds)) (interp n fds) (interp s fds))]))


; realizando uma busca linear na lista para obtencao da definicao
(define (get-fundef [n : symbol] [fds : (listof FunDefC)]) : FunDefC
  (cond
    [(empty? fds) (error 'get-fundef "referencia para funcao nao definida")]
    [(cons? fds) (cond
                   [(equal? n (fdC-name (first fds))
                            (first fds))]
                   [else (get-fundef n (rest fds))])]))

; vale notar o seguinte ponto: sempre que formos interpretar uma funcao
; estaremos percorrendo a mesma duas vezes: uma para realizar a
; substituição e outra para de fato executá-la. O programa não deveria
; ser reescrito o tempo todo quando executado. Deveríamos pensar em
; tornar isto `lazy` de modo que o identificador fosse então apenas
; trocado (baseado em uma tabela de simbolos) quando necessário.

; Para isso, precisamos apenas então modificar o interpretador, que
; passa a receber uma lista que representa o ambiente, o qual contém uma
; lista de associações (bindings) de modo que o interpretador faça a
; troca então em tempo de execução.


; Como discutido inicialmente, nossa primeira implementação de uma
; linguagem que aceita funções não permite sua definição. Para que
; possamos permitir isso devemos então tornar funções valores válidos.

; 1. Incluímos `fdC` a `ExprC` e alteramos os argumentos de `appC`; 2.
; Alteramos o interpretador para que retorne um tipo que pode ser tanto
; uma representação numérica ou uma função.

# Funções como Valores

Até então nossa linguagem está restrita a trabalhar com números (ou expressões ExprC cujo resultado representa número). Desta forma não é então possível definir funções dentro de nossa linguagem.

```
(define-type ExprC
  [numC (n : number)]
  [idC (s : symbol)]
  [plusC (l : ExprC) (r : ExprC)]
  [multC (l : ExprC) (r : ExprC)]
  [fdC (name : symbol) (arg : symbol) (body : ExprC)]
  ; now the application may receive a function, and not a simple
  ;identifier. Don't need the list of expressions anymore! Whoa!
  [appC (fun : ExprC) (arg : ExprC)]
  [ifC (condition : ExprC) (yes : ExprC) (no : ExprC)])
```

Como o interpretador não deve mais retornar apenas números, devemos então alterá-lo para que consiga devolver tanto números como funções. Definimos então o seguinte tipo:

```scheme
(define-type Value
  [numV (n : number)]
  [funV (name : symbol) (arg : symbol) (body : ExprC)])
```

Como os resultados das operações aritiméticas devem então devolver, agora, um numV, temos de melhorar nossos operadores aritiméticos:

```scheme
(define (num+ [l : Value] [r : Value]) : Value
  (cond
    [(and (numV? l) (numV? r))])
```

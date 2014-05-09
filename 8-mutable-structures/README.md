# Mutable Structures

Sem mutação, um trecho de código que recebe o mesmo conjunto de entrada, retorna sempre o mesmo valor. Com mutação, o resultado dependerá se a variável foi alterada (??)



Há diferença entre mudar associação e mudar valor de uma variável. Uma variável tem apenas UMA associação (nome --> posição de memória), mas seu valor muda com o tempo.


## Construção minimalista de Campo

O termo utilizado para este container é box e possui 3 operações básicas: armazenas, recuperar e alterar.

Com mutação aparece a possibilidade de transferir valores de um container para outro, o que, em nossa linguagem, só poderá ser feito com sequenciamento de operações: primeiro pega o valor e depois armazena em outro lugar.

### Sequenciamento

```scheme
(define (beg l)
  (unless (empty? l)
          (let ([a (car l)])
          (beg (cdr l)))))
```

### Boxes


```scheme
[boxC (arg : ExprC)] ; define uma caixa/pacote
[unboxC (arg : ExprC)] ; desenpacota um valor
[setboxC (b : ExprC) (v : ExprC)] ; coloca um valor na caixa
[seqC (b1 : ExprC) (b2 : ExprC)]  ; uma lista de duas expressoes que devem
                                  ; ser executadas sequencialmente
```


```scheme
(define-type Value
  [numV (n : number)]
  [closV (arg : symbol) (body : ExprC) (env : Env)]
  [boxV (v : Value)])
```


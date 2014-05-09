- //TODO parte do código/documentação está ainda em functions. Passar para cá.

Com environments não precisamos nos preocupar com o problema de varrer duas vezes (sempre) o corpo da função (tinhamos que praticamente reescrever o programa e podíamos praticamente nem reescrever).

Com environments temos o conceito de tabelas o qual permite a substituição 'on-the-go' de variáveis (apenas de necessário). A outra vantagem é o poder para o uso de closures.

Não utilizamos aqui uma tabela de símbolos literalmente (não implementamos hash), mas apenas uma lista de associações onde fazemos então buscas por símbolos. Podemos, inclusive, passar uma expressão para tal (a qual é então interpretada) para ser passada para o bind fazer a associação.

Precisamos então trocar apenas nosso interpretador, que passa a receber como argumento uma lista de associações: o environment.

O interpretador então fará busca e troca em tempo de execução apenas.

```scheme
(define-type Binding
  [bind (name : symbol) (val : number)])

(define-type-alias Env (listof Binding))
(define mt-env empty)
(definy extend-env cons)
```

```scheme
(define (interp [a : ExprC] [env : Env] [fds : (listof FunDefC)]) : number
  (type-case ExprC a
    [numC (n) n]; subst must only happen with application of function
    [idC (n) (lookup n env)] ; changing an identifier by its association
    ; function application remains searching, but it does not performs
    ; substituions anymore. It just needs to perform an association
    [appC (f a)
          (local ([define fd (get-fundef f fds)])
            (interp (fdC-body fd)
                    (extend-env
                      (bind (fdC-arg fd) (interp a env fds))
                      env)
                    fds))]
    ; it should not remain any identifiers in the expression
    [plusC (l r) (+ (interp l fds) (interp r fds))]
    [multC (l r) (* (interp l fds) (interp r fds))]
    [ifC (c s n) (if (zero ? (interp c fds)) (interp n fds) (interp s
    fds))]))
```



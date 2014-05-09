# Introduzindo OOD

Introduziremos a noção de objeto (conjunto de valores tratados como unidade) em nossa linguagem, ou seja, coleções acompanhadas de um meio de acesso para cada valor (podendo se tratar também de funções) de maneira individual.

## Sem Herança

Objeto é um valor que mapeia *nomes* a outros *valores* ou *métodos*. Para colocarmos em nossa linguagem fazemos da mesma forma que para *environments*, mantendo valores em uma lista separada simplificando o código.

### O objeto

### Identificação de quem chamar

basta fazer um `case` no objeto e tentar obter o valor. O `else` do mesmo seria apenas uma mensagem de erro.

## Com Herança

-   Métodos <-> Nomes

-   conjunto finito e fixo ou não
- nomes podem ser estaticos ou dinamicos


| nome\conjunto |       fixo      |     variavel    |
| ------------- | --------------- | --------------- |
| estático      | Java            | ~~              |
| dinamico      | c/ Introspeccao | scripting langs |

* introspecção : permite-se reflexão --> p.ex, obter uma função através de uma string
* conjunto variável pode ser facilmente implementado em estruturas de hash para objetos

### Indentificação de quem chamar

Introduzimos agora um `else` em nosso case, o qual irá fazer uma busca em seu pai (recursivamente) para tentar obter o método (pode estar definido nele, ou não - até chegar na raíz de seus parentes).


### O Objeto

Para termos herança devemos então passar para os objetos (como argumento) o construtor - que no fundo é uma fábrica de *closures* -  do pai (um método para instanciação dos mesmos).


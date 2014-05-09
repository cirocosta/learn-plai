- //TODO parte do código/documentação está ainda em functions. Passar para cá.

Com environments não precisamos nos preocupar com o problema de varrer duas vezes (sempre) o corpo da função (tinhamos que praticamente reescrever o programa e podíamos praticamente nem reescrever). Com environments temos o conceito de tabelas o qual permite a substituição 'on-the-go' de variáveis (apenas de necessário). A outra vantagem é o poder para o uso de closures.

Não utilizamos aqui uma tabela de símbolos literalmente (não implementamos hash), mas apenas uma lista de associações onde fazemos então buscas por símbolos. Podemos, inclusive, passar uma expressão para tal (a qual é então interpretada) para ser passada para o bind fazer a associação.



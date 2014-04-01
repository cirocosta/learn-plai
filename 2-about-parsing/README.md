# Parsing?

>   Parsing or syntactic analysis is the process of analysing a string of symbols, either in natural language or in computer languages, according to the rules of a formal grammar.

From a character stream we convert it to a structured internal representation, while checking for correct syntax in the process. In our case, a tree, which programs can recursively process it and do whatever it wants.

>   Within computational linguistics the term is used to refer to the formal analysis by a computer of a sentence or other string of words into its constituents, resulting in a parse tree showing their syntactic relation to each other, which may also contain semantic and other information.

## The Process

Before understanding the process, which is composed of the lexycal and the syntactical phases, we need to understand what it means each of these.

>    **Lexycal Analysis** is the process of converting a sequence of characters into a sequence of tokens, i. e. meaningful character strings.

First, it takes a character stream and splits it into meaningful symbols defined by a particular grammar. Then it checks that the tokens form an allowable expression. After that, it is time for semantic parsing, which is working out the implications of the expression which was evaluated and then performing a particular action.
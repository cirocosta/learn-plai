# Getting Into [PLAI-TYPED](https://github.com/mflatt/plai-typed)

PLAI-Typed differs from Racket by being statically typed. This will give us basically:

-   `define-type`
-   `type-case`
-   `test`


## Basic

Here comes some explanation on the foundations of this module.


### Atomic Values and Methods

-   Booleans : true, false, #t, #f
-   Numbers : 1, 42, 4.23, 2/3, 4+5i
-   Strings : "lol", "something is cool"
-   Symbols : '#koaka, '$1-as
-   Characters #\a, #\u2232

For these, we have some built-in funcs:

-   not, and, or
-   +, -, *, /
-   >, <, =, and others
-   string=?, char=?
-   equal?  -- checks result
-   eq? -- checks structure and result
-   string-append, string-ref


### And, what's new?

#### s-expressions

something that is considered an input for interpretation. i.e, any quoted expression.

There's an especial type of functions, then, that are introduced. Those functions that are focused on converting things to s-expressions. They have a `->` between a type and a s-expression:

```
(symbol->s-exp 'today)
(number->s-exp 23)
(s-exp->number '23)
```

An s-expression consists of a large recursive datatype that has all of the base printable values (numbers, strings, etc) and collections of s-expressions.

for example:

```
(define l '(+ 1 2))
l
=> s-expression
=> '(+ 1 2)

(s-exp->list l)
=> (listof s-expression)

(define f (first (s-exp->list l)))
f
=> s-expression
=> '+

```

shows the recursive thing that we've talked about. For `l` we had defined `(quote (+ 1 2))`, which is, is depth, a list of lists and so on. So, if we perform `(s-exp->list l)` what we receive is `(listof s-expression)`. Having a list, we are then able to get the first element of it.


### Composed Data

#### Lists

-   empty
-   (list 2 4 4)  -- type (listof number)
-   (list "yes" "no") -- type (listof string)
-   first == car, but typed. (car is not valid anymore)
-   rest == cdr
-   list-ref returns an element given an index

**Vectors** are like lists but with a fixed size, which provides a better performance. Are typed just like lists.

**Values** are tuples of any type. May contain any combination of values (think of a `struct` in C):

-   (values 90 3/4)  -- type (vector-immutable)


### Defining stuff


The difference here is that now we are able to specify a type. If no type specified, it will try to infer it.

```scheme
; id receives an expr
(define id expr)

; id receives an expr and returns a type
(define id : type expr)

;so ...

(define x : number 3)
(define y 4)
x
=> - number
=> 3
y
=> - number
=> 4
```

When defining procedures we have, then, to specify some more stuff. Now they may return a specific type and each of its arguments may be enforced to a determined type.

Check it how we do:


```scheme
; id has params param with certain types and receives an expr
(define (id param/type ...) expr)

; id has params param with certain types, receives an expr and returns a
; certain type
(define (id param/type ...) type expr)

; so...

(define (times_tree [n : number]) : number (* 3 n))

```

ps: `id/type` or `param/type` equals to:

```scheme
[id : type ]
```

For the first-class procedures we have to specify types as well.

```scheme
; this is what we would do in a common racket/scheme program
(define plus1 (lambda (x) (+ x 1)))
(plus1 10)
=> 11

; now, with plai-typed

(define plus1 : (number -> number) (lambda (x) ( + x 1)))
(plus1 10)

; which is equal to

(define plus1 (lambda ([x : number]) : number (+ x 1)))

(plus1 10)
=> -number
=> 11
```

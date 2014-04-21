# Getting Into [PLAI-TYPED](https://github.com/mflatt/plai-typed)

PLAI-Typed differs from Racket by being statically typed. This will give us basically:

-   `define-type`
-   `type-case`
-   `test`

which i'll be covering mostly in the end.

## Basic

Here comes some explanation on the foundations of this module which are also present on racket's foundation.


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

They are something that is considered an input for interpretation. I.E, any quoted expression.

That said, we must then introduce some new functions. Those that are focused on converting things to *s-expressions*. They have a `->` between a type and a s-expression:

```scheme
(symbol->s-exp 'today)
(number->s-exp 23)
(s-exp->number '23)
```

An s-expression consists of a large recursive datatype that has all of the base printable values (numbers, strings, etc) and collections of s-expressions.

for example:

```scheme
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

So, when defining procedures we have to specify some more stuff. Now they may return a specific type and each of its arguments may be enforced to a determined type.

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

ps.: `id/type` or `param/type` equals to:

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

; and also equal to

(define (plus1 [n : number]) : number
  (+ 1 n))

(plus1 10)
=> -number
=> 11
```

### Defining types

Just like we would do in an OOD language, we are able to define some types. Here we'll use the `define-type` as i mentioned above.

Some terms will be introduced:

- Variant -- it is the constructor which receives the arguments declared.

Its syntax is:

```scheme
(define-type TYPE
  [variant (field : type)]
           (field : type)
              ...
           (field : type)]
    ...
  )

; or

(define-type ABSTRACT_CLASS
  [subclass1 (field1 : type1)]
  [subclass2 (field1 : type1) (field2 : typeN)])
```

leading to:

```scheme
(define-type Shape
  [square (side : number)]
  [circle (radius : number)]
  [triangle (height : number)
            (width : number)])
```


A way that i like to think is: *We have a constructor function called Shape, which is able to construct squares, circles and triangles*. Suppose that we would like to check if we are talking about a curvy thing. How would we achieve that? Let's define a function for it and use it:

```scheme
(define (curvy? [s : Shape]) : boolean
  (circle? s))

(curvy? (square 5))
=> #f

(curvy? (circle 10))
=> #t

(curvy? (triangle 3 5))
=> #f
```

Look carefully here. We've never defined the function `circle?` but we are using it here. Why? Because when we define a Type the variants *inherits* some methods (it is more like ... "something builds some functions to them", and not pure inheritance).

For each field of the variants there's a method for retrieving it:

```scheme
(define tower (triangle 90 4))
(triangle-width tower)
=> 4
```


The way one would bind one instance to a name would be:

```scheme
(define-type MisspelledAnimal
  [caml (humps : number)]
  [yacc (height : number)])

(define ma1 : MisspelledAnimal (caml 2))

; or, letting plai to infer:

(define ma1 (caml 2))  ; not good, but it is possible.

```

#### Type-Case

**type-case** lets us check some patterns in the construction of elements. It's syntax is:

```scheme
(type-case CLASS object
  [subclass (field1 field2 .. fieldn) (true-expression) (else-expression)]
  [subclass2 (field1 field2 .. fieldn) (true-expression) (else-expression)]
  ...
  )
```

Knowing that, here comes an example:

```scheme
(define (good? [ma : MisspelledAnimal]) : boolean
  (type-case MisspelledAnimal ma
    [caml (humps) (>= humps 2)]
    [yacc (height) (> height 2.1)]))
```

and then, test it:

```scheme
(test (good? ma1) #t)
(test (good? ma2) #f)
```

Both tests will pass :P


## Some cool things on Racket

### Conditionals

Just like any other languages, racket introduces conditionals. It has `if`, `and`, `or` and `cond`.

For `if ` the syntax is as follows:
```scheme
(if (expr1)
  (expr2)   ; if expr1 is true
  (expr3))  ; if expre1 is false
```

The `end` is a bit different. It forms something like *short circuits* by stopping and returning `#f` if an expression produces `#f` - and letting it go, otherwise. The `or` acts just like `and` but for `#t`.

```scheme
(define (reply s)
  (if (and (string? s)
           (>= (string-length s) 5)
           (equal? "hello" (substring s 0 5)))
      "hi!"
      "huh?"))

(reply "hello racket")
=> "hi!"
```

Finally, `cond`. This is a way of putting a sequence of test expressions and then evaluating them. It acts like a `if - else if - else if - ... - else` expression.

```scheme
(define (reply-more s)
  (cond
   [(equal? "hello" (substring s 0 5))
    "hi!"]
   [(equal? "goodbye" (substring s 0 7))
    "bye!"]
   [(equal? "?" (substring s (- (string-length s) 1)))
    "I don't know"]
   [else "huh?"]))
```

### Case

Just like `type-case`, racket implements `case`.

`case` will evaluate `val-expr` and then use the result to select a *case-clause*. The selected clause will then be the first one with a datum whose quoted form is `equal?` to the result of the *val-expr*.

```scheme
(case val-expr
  [(datum ...) (then-body ...)]
  ...
  [(datum ...) (then-body ...)]
  [else then-body ...])
```


### Local Binding

Here we have 3 cool procedures that are particular to racket and then naturally extended to plai-typed: `let`, `let*` and `letrec`.

`let` performs local mappings of symbols to values and `let*` lets us nest some `let` definitions

```scheme

(let ([x 5]) x)
=> 5

(let ([x 10]
      [y 11])
    (+ x 1))
=> 21
```

Notice that the construction is very similar to a **begin** with two definitions and then a procedure call. What a badass is this `let` :P

Let's nest some stuff. Pay attention to the scopes!

```scheme
(let ([x 0]           ; x = 0
  (let ([x 10]        ; x = 10 while inside this let
        [y (+ x 1)])  ; y = x+1 --> y = 11, get out of the inner scope
    (+ x y)))         ; x = 0 again, y = 11, so, output = 11
=> 11
```

ps.: don't try to think that way. It's not all that good as it may trick you. Imagine you are a parser and you just got into this tricky thing. What would you do? --> go look to the most inner scope and then, when looking to a variable, first check if the variable is being defined inside it. If you don't find, then go looking outside and so on. Seems clever but, idk, maybe it's not. I'm very tired :scream:

Now, using `let*`:

```scheme
(let ([x 0]           ; x = 0
  let* ([x 10]        ; x = 10
        [y (+ x 1)])  ; y = 11
    (+ x y)))         ; return 10 + 11 and fuckoff the scopes
=> 21
```

**letrec** lets us do some nasty things like function prototyping in C lang. It just makes as association of each identifier to an undefined value which is changed in its first use:

```scheme

```


There's also a named let, which exists to build tail recursions:

```scheme
(let loop ([x 10])
  (if (zero? x)
    (display "FIM\n")
    (begin
      (displayln x)
      (loop (- x 1)))))
```

which is the same as:

```scheme
(letrec ([L (lambda (x)
              (if (zero? x)
                (display "FIM\n")
                (begin
                  (displayln x)
                  (loop (- x 1)))))
         ])
        (L 1)0m)
```

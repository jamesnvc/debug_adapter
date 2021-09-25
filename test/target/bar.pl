:- module(
       bar,
       [
           bar/1,
           bar/2
       ]
   ).

:- dynamic bar/1.

bar(Bar, Baz) :-
    (   bar(Bar)
    ;   bar(Baz)
    ).
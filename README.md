gumsolver
=========

constraint-based propagation of uncertainties 


This lua package extends the propagation of constraints to values with uncertainties. Starting with one of the most exciting sections of the wizard book, these algorithms were ported to lua and then adapted to make better use of tables. 

A tool is provided, which can work on files with statements or tables or can be used interactively. In debugging mode, further messages on any changes ("probe") are sent to stderr. Check the example files for proper use of equations. In table mode, columns for absolute or relative uncertainties are marked with traing +- or ± or % respectively and filled during output.

## Typical Usage

gumsolver -h  
cat statements.txt | gumsolver  
cat tableformula.txt | gumsolver -t   
rlwrap gumsolver -i

## Syntax

Names of variables are case-sensitive and have to start with an letter, followed by an unlimited number of upper- and lowercase letters as well as numbers and dashes. Underscores and carets are not allowed, as this might interfere with math syntax. Spacing within lines is ignored. 

Notation of uncertainties:  
v+-u v±u v+-u% v±u%

Notation of equations:  
a=b+c a=b*c a=b*(c-d), ...

The order of precedence is as usual and can be modified by brackets. So far, variables have to be declared before first usage.

## Present Limitations

a=b+c+d will not resolve into all directions as it is converted to subexpressions with binary operators: a = (a+b)+c

s=a*a will not resolve into all directions, the reason is given as an excercise.

Declaration of variables neccessary in most cases

So far, the grammar is based on a chaotic network of regular expressions. 

## Future Improvements

Ensure range for allowed letters to latin-1.  
Formal description of the grammar, as well as a better parser.  
Group of samples v=x1,x2,x3,...,xn.  
Tablemode considering columns as arrays of values.  

## Licence

Parts of this work (propagation of constraints) are learned from a text book based on work at mitpress.mit.edu with is published under the "Creative Commons Attribution-ShareAlike 3.0 Unported License", which is adopted for this work as well:   
http://creativecommons.org/licenses/by-sa/3.0/ 

Therefore, this work is free to be used and shared and modified. However, proper attributions to the original ideas have to be made, especially in published work.



## Further reading

Structure and Interpretation of Computer Programs (Abelson, Sussman, and Sussman, 1984) Section 3.3.5  
http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-22.html#%_sec_3.3.5

Guide to the Expression of Uncertainty in Measurement (GUM) - JCGM 100:2008  
http://www.iso.org/sites/JCGM/GUM-JCGM100.htm


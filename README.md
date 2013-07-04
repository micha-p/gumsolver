gumsolver
=========

This Lua package extends the propagation of constraints to values with uncertainties. Starting with one of the most exciting sections of the wizard book, these algorithms were ported to Lua and then adapted to make better use of tables. According to the rules for propagation of errors, a network equations is filled with values and their associated uncertainties into both directions. 

A command line tool is provided, which can work on files or tables or can be used interactively. In debugging mode, additional messages on any changes ("probes") are sent to stderr. Check the example files for proper use of equations. In table mode, columns for absolute or relative uncertainties are marked with traing +- or ± or % respectively and filled during output.

## Example Usage

./gumsolver -h  
cat statements.txt | ./gumsolver  
cat tableformula.txt | ./gumsolver -d "\t" -t  
rlwrap ./gumsolver -i

## Syntax

Names of variables are case-sensitive and have to start with an upper- or lowercase letter, followed by any unlimited number of letters as well as numbers and dashes. Locale settings are taken into account. Underscores and carets are not allowed, as they might interfere with math notation. Spacing between tokens within lines is ignored. Any linebreak will trigger evaluations.

Notation of uncertainties:  
v+-u &emsp; v±u &emsp; v+-u% &emsp; v±u%

Notation of equations:  
a=b+c &emsp; a=b\*c &emsp; a=b\*(c-d) &emsp; ...

The order of precedence is as usual and can be modified by brackets. 


## Commands for interactions and pipelined files

	a 	Declare variable (will be automated)
	a=12    Assign value
	a=12+-3 Assign value with uncertainty
	a=12+-3% Assign value with uncertainty (percentage of value)
	a  	Forget value
	a=b*c	Submit equation for declared variables
	c=   	Set propagated value (to be implemented)

## Present Limitations

Declaration of variables is neccessary before assignment

Constant values within formulas are fixed without any uncertainties. Otherwise use variables.

a=b+c+d will not resolve into all directions as it is converted to subexpressions with binary operators: a = (a+b)+c

s=a*a will not resolve into all directions, the reason is given as an excercise.

## Future Improvements

Formal description of the grammar, as well as a clean parser instead of nested regular expressions.  
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

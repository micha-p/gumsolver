gumsolver
=========

This Lua package extends the propagation of constraints to values with uncertainties. Starting with one of the most exciting sections of the wizard book, these algorithms were ported to Lua and then adapted to make better use of tables. According to the rules for propagation of errors, a network equations is filled with values and their associated uncertainties into both directions. 

A command line tool is provided, which can work on files or tables or can be used interactively. In debugging mode, additional messages on any changes ("probes") are sent to stderr. Check the example files for proper use of equations. In table mode, columns for absolute or relative uncertainties are marked with traing +- or ± or % respectively and filled during output.

## Example Usage

./gumsolver -h  
cat demo/example.txt | ./gumsolver  
cat demo/tableformula.txt | ./gumsolver -d "\t" -t  
rlwrap ./gumsolver -i

## Syntax

Symbols are case-sensitive and might contain at least one letter as well as digits or dots without any limits in length. 
These dots divide symbol names into segments, which allow for simple object-oriented prototype-based inheritance. Underscores or carets or dashes are not allowed, as they might interfere too easily with math notation. 

Settings for local internalization are taken into account execpt for the decimal separator, which is always a decimal point. Numbers are read as decimals and might contain underscores at arbitrary locations to separate between parts of different magnitude. 

Spacing between tokens within lines is skipped and any linebreak will trigger evaluations.

Notation of uncertainties:  
v+-u &emsp; v±u &emsp; v+-u% &emsp; v±u%

Notation of equations:  
a=b+c &emsp; a=b\*c &emsp; a=b\*(c-d) &emsp; ...

The order of precedence is as usual and can be modified by brackets. 


## Commands for interactions and pipelined files

	a         Declare variable (will be automated)
	a=12      Assign value
	a=12+-3   Assign value with uncertainty
	a=12+-3%  Assign value with uncertainty (percentage of value)
	a         Forget value
	a=b*c     Submit equation for declared variables
	c=        Set propagated value (to be implemented)
	
	
## Special syntax at the command line

Comments start with a hash-sign and last until end of line.
It is possible to submit special directives following an exclamation mark. Usuanlly, the first letter is distinctive

	!ABSOLUTE  Switch to display absolute uncertainties (default)
	!RELATIVE  Switch to display relative uncertainties
	!INCLUDE   Literal inclusion of the specified file (TODO)
	!PRINT	   Send the rest of the line to standard output
	!DUMP 	   Show content of network
	!CLONE     Clones given name from constraint with one segment less. Prototype-based inheritance (TODO)
	!TRACE 	   Trigger tracing on/ off (TODO)
    	!SAVE      Save onto stack (TODO)
    	!LOAD      Load from stack (TODO)
	!QUIT	   Stop processing regardless of any following content
	
	
## Theory

There are two main types of objects: Connectors keep the values, a list of listeners and basically understand two signals for setting their values. Whenever they get such a signal from any informant, they inform all listeners except the informer whether they got a new value or they lost their value.

Constraints understand these changes, ask for values, compute new ones, and propagate them to another connector. Probes are derived from constraints and just communicate with the user. 

The right part of any given equation is parsed into smaller expressions, which are converted to a connector attached to a constraint, which in turn is attaches itself to it's operands (other connectors or constants) during creation. In most cases, the symbol on the left part is an already known connector and therefore connected to the connector resulting from the expression via a unary constraint acting as a bidirectional pipe. 

## Present Limitations

Declaration of variables might be neccessary before assignment

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


gumsolver
=========

Propagation of constraints for values with uncertainties implemented in Lua.

Starting with one of the most exciting sections of the wizard book, these algorithms were ported to Lua and then adapted to make better use of tables. According to the rules for propagation of errors, a network equations is filled with values and their associated uncertainties into both directions. 

A command line tool is provided, which can work on files or tables or can be used interactively. In debugging mode, additional messages on any changes ("probes") are sent to stderr. Check the example files for proper use of equations. In table mode, columns for absolute or relative uncertainties are marked with traing +- or ± or % respectively and filled during output.

So far, the list of commands is NOT stable but constantly modificated according to de needs of some private real world examples.


## News

- for interactive exploration of the rules network, a mask mode is available now
- trailing stars or apostrophes in symbol names
- declaration of arbitrary units or scale


## Theory

There are two main types of objects: Connectors keep the values, a list of listeners and basically understand two signals for setting their values. Whenever they get such a signal from any informant, they inform all listeners except the informer whether they got a new value or they lost their value.

Constraints understand these changes, ask for values, compute new ones, and propagate them to all other attached connectors. Probes are derived from constraints and just communicate with the user. 

Such constraints are given as arithmetic terms building a network of equations. The right part of any given equation is parsed into smaller expressions, which are converted to a connector attached to a constraint, which in turn is attaches itself to it's operands (other connectors or constants) during creation. 


## Example Usage

./gumsolver -h  
cat demo/example.txt | ./gumsolver  
cat demo/tableformula.txt | ./gumsolver -d "\t" -t  
./gumsolver -f demo/example.txt  
./gumsolver -t -f demo/tableformula.txt  
./gumsolver -d , -t -f demo/tableformula.csv  
rlwrap ./gumsolver -I

## Modes of operation

As default, gumsolver works in a *pipe* mode, accepting input from standard input and sending the evaluated results to standard output. Several other modes affect input as well as output and might be suitably combined. 

When any input files are given as argument, the program will evaluate these files subsequently until an explicit or implicit end of file is encountered within these files. After processing all arguments, the program will wait for additional input, if it works in an *interactive* mode, and terminate otherwise. Such interactions can be made either in *prompt* mode, which might be supported by a readline wrapper, or in *mask* mode, where output will update a nonscrolling table.

Input can be supplied line by line, either in a stream, from a file or at the command line prompt. In addition there is a *table* mode, where input might be given as lines of records. Finally, output can be switched to *record* mode as well, so it is possible to obtain an updated version of a table with missing cells. 

These normal modes of operation can be complemented by additional information on the standard error port. In *debug* mode, where all input is further explained and in *trace* mode, where all changes in state are encountered.



## Command line and arguments

Arguments given on the command line are evaluated from left to right and it is possible to use switches and file input multiple times. Options and directives are as close as possible to the same directives except for the leading character (TODO) and the additional options for showing help and version.


## Commands for interactions and pipelined files

	a=12      Assign value
	a=12+-3   Assign value with uncertainty
	a=12+-3%  Assign value with uncertainty (percentage of value)
	a         Forget value
	a=b*c     Submit equation
	c=        Set propagated value as user supplied (to be implemented)

## Domain specific language

### Principles

Notation should rather reflect math instead of code.  
No syntactic sugar.  
Commands to the underlying framework should be clearly distinct.  
Characterset within ASCII and some optional additions (for +- and ^2).  
All statements are evaluated sequentially.

### Syntax

Whitespace between tokens within lines is not significant and any linebreak will trigger evaluations.

Symbols are case-sensitive and might contain at least one letter as well as digits or dots without any limits in length. They can be further distinguished one or more trailing apostrophes, which is commonly used in formulas. The dots divide symbol names into segments, which allow for simple object-oriented prototype-based inheritance. Settings for local internalization are taken into account for these letters. Symbols are used for variables or (mathematical) functions. 

Values consist of real decimal numbers with or without absolute or relative uncertainty. The decimal separator is always denoted by the decimal point.

Underscores might be used to separate parts of symbols as well as parts of different magnitude in numbers. 

Values and Uncertainties:  
v+-u &emsp; v±u &emsp; v+-u% &emsp; v±u%

Group of samples (TODO): 
v=x1,x2,x3,...,xn   &emsp;  v = (x1 x2 x3 x4)
Either a delimier indicating subsequent values or a ending is neccessary

Operators:  
\+ - * / 
^2 &emsp; ² &emsp; ^0.5 
Order of precedence is as usual and might be modified by brackets

Equations:  
a=b+c &emsp; a=b\*c &emsp; a=b\*(c-d) &emsp; ...

Functions(TODO):  
f(x) = 2 * x + 1

### Special commands and commandline arguments

It is possible to submit special directives following a hash sign at the beginning of the line. 
In many cases, the first letter is distinctive.

	#(A)BSOLUTE  	Switch to display absolute uncertainties (default)
	#(R)ELATIVE  	Switch to display relative uncertainties
	#(I)NCLUDE   	Literal inclusion of specified file given by following characters
	#(P)RINT	Send the rest of the line to standard output
	#(D)UMP 	Show network of constraints
	#(T)ABLE     	Tabulate records (horizontally)
	#REC(O)RD	Print, save and clear current state of connectors 
	#(C)LONE     	Clones a connector with one name segment less. Prototype-based inheritance (TODO)
	#TRACE   	Toggle tracing on/ off
	#(V)ERBOSITY  	0=mute 1=normal 2=debug
	#(H)ELP	   	Show help
	#(Q)UIT	   	Stop processing regardless of any following content

### Comments 

Comments start anywhere in a line with a hash-sign followed by any letter not used for directives and last until end of line.
	
## Fields and Records in horizontal and vertical modes

Input is divided into records separated as fields. It might be provided vertically while feeding line after line (with or without prompt) or horizontally in table style. By default, output is formatted alike, but it is possible to trigger the tabulated output of records in vertical mode and the record based output in horizontal mode (TODO).

The current state of connectors might be recorded either by explicitely starting a new record or at any line ending in table mode. Fields within table records might be interpreted as statements with predefined left side. Moreover, full statements are not restricted to the header line but might occur within the table as well. On the other hand in vertical modes several statements might be combined at one line when separated by field delimiters (TODO). 

Backreferences to previous records are a powerful feature for studying simulations. They consist of a symbol name and an index, denoted by an at_sign followed by a valid record number. 

## Present Limitations

Constant values within formulas are fixed without any uncertainties. Otherwise use variables.  
s=a*a will not resolve into all directions, the reason is given as an excercise.

## Future Improvements

Consistent use of global variables in code.  
Formal description of the grammar, as well as a clean parser instead of nested regular expressions.  
Encapsulation of constraints into functions (in a mathematical sense).  
Tablemode considering columns as arrays of values.  
Compute means and uncertainties of a range of records or all records (star) or a SQL-like query. 


## Licence

Parts of this work (propagation of constraints) are learned from a text book based on work at mitpress.mit.edu with is published under the "Creative Commons Attribution-ShareAlike 3.0 Unported License", which is adopted for this work as well:   
http://creativecommons.org/licenses/by-sa/3.0/ 

Therefore, this work is free to be used and shared and modified. However, proper attributions to the original ideas have to be made, especially in published work.



## Further reading

Structure and Interpretation of Computer Programs (Abelson, Sussman, and Sussman, 1984) Section 3.3.5  
http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-22.html#%_sec_3.3.5

Guide to the Expression of Uncertainty in Measurement (GUM) - JCGM 100:2008  
http://www.iso.org/sites/JCGM/GUM-JCGM100.htm


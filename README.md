gumsolver
=========

Propagation of constraints for values with uncertainties implemented in Lua.

Starting with one of the most exciting sections of the wizard book, these algorithms were ported to Lua and then adapted to make better use of tables. According to the rules for propagation of errors, a network equations is filled with values and their associated uncertainties into both directions. 

A command line tool is provided, which can work on files or tables or can be used interactively. In debugging mode, additional messages on any changes ("probes") are sent to stderr. Check the example files for proper use of equations. In table mode, columns for absolute or relative uncertainties are marked with traing +- or ± or % respectively and filled during output.

So far, the list of commands is NOT stable but constantly modificated according to de needs of some private real world examples.


## Theory

There are two main types of objects: Connectors keep the values, take care of a list of listeners and basically understand two signals for changing their values: Setting and forgetting. Whenever they get such a signal from any informant, they inform all listeners except the informer whether they got a new value or they lost their value.

Constraints are listening to them, understand their messages, eventually ask for their values, compute new ones, and propagate them to all other attached connectors. Probes are a special kind of listeners, derived from constraints and just communicate with the user. 

Networks of constraints and linked connectors are specified as arithmetic terms and equations.

## Example Usage

./gumsolver -i demo/example.txt  
./gumsolver -q -t -i demo/tableformula.txt  
./gumsolver -d, -t -i demo/tableformula.csv  
cat demo/example.txt | ./gumsolver -b   
cat demo/tableformula.csv | ./gumsolver -b -TABLE   
rlwrap ./gumsolver

## Elementary commands for interactions and pipelined files

	a=12      Assign value
	a=12+-3   Assign value with uncertainty
	a=12+-3%  Assign value with uncertainty (percentage of value)
	a         Forget value
	a=b*c     Submit equation
	c?	       Try to get value by actively searching for satisfied equations (TODO)

## Modes of operation and output 

As default, gumsolver works in a *batch* mode, accepting input from standard input and sending the evaluated results to standard output. When any input files are given as argument, the program will evaluate these files subsequently until an explicit or implicit end of file is encountered within these files. After processing all arguments, the program will wait for additional interactions or terminate otherwise. 

Such interactions can be made either in *prompt* mode, which might be supported by a readline wrapper, or in *mask* mode, where output will update a nonscrolling table.

Input can be supplied line by line, either in a stream, from a file or at the command line prompt. In addition there is a *table* mode, where input might be given as lines of records. Finally, output can be switched to *record* mode as well, so it is possible to obtain an updated version of a table with missing cells. 

These normal modes of operation can be complemented by additional information on the standard error port. In *debug* mode, where all input is further explained and in *trace* mode, where all changes in state are encountered.

1. Pipelining:    BATCH (default)
2. Interactive:   PROMPT (sequential lines) MASK (vertical view)
3. Tabular:       TABLE (horiontal records) RECORD (vertical records)
4. Error port:    DEBUG (feedback to stderr) ITER (show iterations) TRACE (messages) SUPPRESS
5. Terminating:   QUIT (default) DUMP (show internal states)

## Command line and arguments (STILL SOME WORK TODO)

### Global flags and short commandline options

Global flags override all other directives within files and at the command line and should be placed at the beginning. Useful for quickly changing output without any changes at other places.

-a absolute error for all output (default and higher precedence)  
-r relative error for all output  
-s short number format with errors suppressed completely  
-z unspecified error is displayed as zero  
-b full number format (irrespective of shown errors)

-b batch mode (noninteractive)
-m always stay in mask mode   
-i read file line by line in batch mode or interactive mode  
-t read table with separated fields  
-d delimiter for tabular input  

-q quiet and restricted output  
-v display version and terminate  
-h display help and terminate  


### Directives on the commandline

Directives given on the command line are evaluated strictly from left to right and it is possible to use switches and file input multiple times. They are started with one or two leading dashes instead of a hash sign to prevent any interference with the shell. A comprehensive list is given below. 

## Domain specific language

### Principles

Notation should rather reflect math instead of code.  
No syntactic sugar.  
Commands to the underlying framework should be clearly distinct.  
Characterset within ASCII and very few optional additions (for +- and ^2).  
All statements are evaluated sequentially.

### Syntax

Whitespace between tokens within lines is not significant and any linebreak will trigger evaluations.

Symbols are case-sensitive and might contain at least one letter as well as digits or dots without any limits in length. They can be further distinguished one or more trailing apostrophes, which is commonly used in formulas. The dots divide symbol names into segments, which allow for simple object-oriented prototype-based inheritance. Settings for local internalization are taken into account for these letters. Symbols are used for variables or (mathematical) functions. 

Values consist of real decimal numbers with or without absolute or relative uncertainty. The decimal separator is always denoted by the decimal point.

Underscores might be used to separate parts of symbols as well as parts of different magnitude in numbers. 

Values and Uncertainties:  
v+-u &emsp; v±u &emsp; v+-u% &emsp; v±u%

Operators:  
\+ - * / 
^2 ^3&emsp; ² &emsp; ³ &emsp; ^0.5 
Order of precedence is as usual and might be modified by brackets

Special functions (one optional space between name and bracket):  
abs(TODO)
exp(x), e^x    
log(x), ln(x)   as in Lua, there is only natural logarithm (easy to remember)
min(a,b) max(a,b)  
argmin(y, trigger)  the result is a value, which minimizes y
partial(y,x)   partial derivative of y regarding x
integral(y,x1,x2) TODO 

Equations:  
a=b+c &emsp; a=b\*c &emsp; a=b\*(c-d) &emsp; ...
b+c = e\*f &emsp; a^2=b\*(c-d) &emsp; ...
a*x^2 + b*x + c = 0

Functions(TODO):  
f(x) = 2 * x + 1

### Units

In many cases, scaled values help to understanding the simulated network of variables. Therefore units can be provided in squared brackets together with an additional scale. These brackets are needed in all cases to distinguish variable names:

[mm]	0.001	(the fraction of the internal value; change to 1000?) 
[kg]	1000	
[h]	3600	

m [kg]	=> declare default unit for this variable
t=1 
t [h] = 3 => this input value is in [h] irrespective of any other declared unit        

TODO: 
At the moment, declarations of units have to be started with the directive #UNIT. Input values with units are not possible so far. But scaled input of course.

### Comments 

Comments might start anywhere in a line with a hash-sign followed by any letter not used for directives and last until end of line.

### Directives on the command line and in files

It is possible to submit special directives following a hash sign at the beginning of a line. They are uppercase an their meaning and coverage is exactly the same in the command line options as in files. In most cases, the first letter is distinctive and sufficient.

Kind of output of uncertainties: #ABSOLUTE(default) #RELATIVE #ZERO #SUPPRESS   
Kind of output and mode of operation: #BATCH(default) #PROMPT #MASK #TABLE #RECORD   
Amount of output: #VERBOSE(default) #MUTE(implied by #TABLE and #MASK)   
Additional information on stderr: #DEBUG #ITER #TRACE   
Way of terminating:  #QUIT (default) #DUMP (show list of network and internal state)   
Additional in- and output: #INCLUDE (lieral inclusion of a file) #PRINT (message line) 

	
## Fields and Records in horizontal and vertical modes

Input is divided into records separated as fields. It might be provided vertically while feeding line after line (with or without prompt) or horizontally in table style. By default, output is formatted alike, but it is possible to trigger the tabulated output of records in vertical mode and the record based output in horizontal mode (TODO).

The current state of connectors might be recorded either by explicitely starting a new record or at any line ending in table mode. Fields within table records might be interpreted as statements with predefined left side. Moreover, full statements are not restricted to the header line but might occur within the table as well. On the other hand in vertical modes several statements might be combined at one line when separated by field delimiters (TODO). 

Backreferences to previous records are a powerful feature for studying simulations. They consist of a symbol name and an index, denoted by an at_sign followed by a valid record number. (TODO: drop again, too much code and too complicated)

## Present Limitations and Future Improvements

Equations with multiple occurrences of variables (s=a*a) will not resolve into both directions, the reason is given as an excercise.   
Encapsulation of constraints into modules to circumvent such problems.   
Formal description of the grammar combined with a perfectly clean parser.   
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


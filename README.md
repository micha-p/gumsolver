gumsolver
=========

constraint-based propagation of uncertainties 


This lua package extends the propagation of constraints to values with uncertainties. Starting with one of the most exciting sections of the wizard book, these algorithms were ported to lua and then adapted to make better use of tables. 

A tool is provided, which can work on files with statements or tables or can be used interactively. In debugging mode, some messages are sent to stderr. 
Look at the example files for proper use of equations. In table mode, columns for absolute or relative uncertainties are filled during output.

Typical Usage
-------------

cat statements.txt | gumsolver
cat tableformula.txt | gumsolver
rlwrap gumsolver -i


Syntax
------

Not sensitive to spacing, names of variables can contain upper- and lowercase letters as well as numbers. 

Notation of uncertainties:
v +- u   v ± u , v+-u% , v±u%

Notation of equations:
a=b+c a=b*c a=b*(c-d), ...

The order of precedence is as usual, otherwise use brackets. varables have to be declared before first usage. 



Further reading
---------------

Structure and Interpretation of Computer Programs (Abelson, Sussman, and Sussman, 1984) Section 3.3



Data Types

Numeric

Int, is a whole number, positive or negative,
	without decimals, of unlimited length.

Complex - numbers are of a real part and an imaginary part. 

Numeric with decimal point:
	Float is a number, positive or negative, containing
	one or more decimals. 

Alphanumeric:
	String 	'Python', "123"

Boolean:
	Boolean	True and False

Lab:
#numeric category
print(type(3))
print(type(4+7j))

#numeric with decimal category
print(type(3.0))

#Alphanumeric category
print(type("Hello World"))

#Boolean Category
print(type(False))


Variables
	- Containers for data
	- The value of the variable can vary throughout the program. 
	- 6 Dimensions - Name, Datatype, Address, Value, Lifetime, Scope. 

Keywords
	- In python, Keywords are reserved words like if, else, elif,
	for, where, break, pass, and continue. 

Identifiers
	- An identifier can start with an uppercase or lowercase character
	or an underscore(_) followed by any number of underscores,  
	letters, and digits. 

Dynamic Typing
	- Dynamic Typing is a technique, where the variables data type is 
	dynamically and aumatically assigned depending on how a value
	is used. 
	- print(type(variable_name))

Static Typing
	- The data type must be declared before a variable is used,
	not supported.

Example:
A = 356
B = 245
C = 100
D = C + A - B 
print("Current number of flights:",D)
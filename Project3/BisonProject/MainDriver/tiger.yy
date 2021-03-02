
%debug
%verbose	/*generate file: tiger.output to check grammar*/
%locations

%{
#include <iostream>
#include <string>
#include "ErrorMsg.h"
#include <FlexLexer.h>

int yylex(void);		/* function prototype */
void yyerror(char *s);	//called by the parser whenever an eror occurs

%}

%union {
	int		ival;	//integer value of INT token
	std::string* sval;	//pointer to name of IDENTIFIER or value of STRING	
					//I have to use pointers since C++ does not support 
					//string object as the union member
}

/* TOKENs and their associated data type */
%token <sval> ID STRING
%token <ival> INT

%token 
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK 
  LBRACE RBRACE DOT 
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF 
  BREAK NIL
  FUNCTION VAR TYPE 

/* add your own predence level of operators here */ 

%start program

%%

/* This is a skeleton grammar file, meant to illustrate what kind of
 * declarations are necessary above the %% mark.  Students are expected
 *  to replace the two dummy productions below with an actual grammar. 
 */

program	:	exp

exp		:	ID


%%
extern yyFlexLexer	lexer;
int yylex(void)
{
	return lexer.yylex();
}

void yyerror(char *s)
{
	extern int	linenum;			//line no of current matched token
	extern int	colnum;
	extern void error(int, int, std::string);

	error(linenum, colnum, s);
}


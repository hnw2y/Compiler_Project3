 /*
 PROGRAMMER: Jessica Wijaya
 ASSIGNMENT: Project 3
 DUE DATE: March 14, 2021
 DESCRIPTION: tiger.yy file containing CFG for Tiger language

  */

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
  FUNCTION VAR TYPE ASSIGN NEWLINE

/* add your own predence level of operators here */ 

%left AND OR
%nonassoc GE LE GT LT EQ NEQ ASSIGN
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS

%right THEN ELSE OF IN 

%start expr

%%


expr	:	STRING					
		|	INT				
		|	NIL				
		|	lvalue				
		|	MINUS expr	%prec UMINUS
		|	expr TIMES expr		
		|	expr DIVIDE expr	
		|	expr PLUS expr		
		|	expr MINUS expr		
		|	expr EQ expr		
		|	expr NEQ expr		
		|	expr GT expr		
		|	expr LT expr		
		|	expr GE expr		
		|	expr LE expr		
		|	expr AND expr		
		|	expr OR expr		
		|	lvalue ASSIGN expr			
		|	ID LPAREN expr-list RPAREN	
		|	ID LPAREN RPAREN
		|	LPAREN RPAREN
		|	LPAREN expr-seq RPAREN
		|	ID LBRACE field-list RBRACE  
		|	ID LBRACE RBRACE
		|	ID LBRACK expr RBRACK OF expr 
		|	IF expr THEN expr			
		|	IF expr THEN expr ELSE expr 
		|	WHILE expr DO expr			
		|	FOR ID ASSIGN expr TO expr DO expr
		|	BREAK						
		|	LET declaration-list IN expr-seq END
		|	LET declaration-list IN END
		|	error
		;

 expr-seq	:	expr
			|	expr-seq SEMICOLON expr
			;
 
 expr-list	:	expr
			|	expr-list COMMA expr
			;

 field-list	:	ID EQ expr
			|	field-list COMMA ID EQ expr
			;

 lvalue	:	ID
		|	lvalue DOT ID
		|	lvalue LBRACK expr RBRACK 
		|   ID LBRACK error SEMICOLON  
		;

 declaration-list :	declaration
				  |	declaration-list declaration
				  | declaration-list error
				  ;

 declaration :	type-declaration
			 |	variable-declaration
			 ;

 type-declaration :	TYPE ID EQ type
				  ;

 type :	ID
	  |	LBRACE type-fields RBRACE
	  | LBRACE RBRACE
	  | ARRAY OF ID
	  ;

 type-fields :	type-field
			 |	type-fields COMMA type-field
			 ;

 type-field :	ID COLON ID
			| error
			;

 variable-declaration :	VAR ID ASSIGN expr
					  |	VAR ID COLON ID ASSIGN expr
					  ;


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


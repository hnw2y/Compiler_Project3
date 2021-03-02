/***
	Copy your own tiger.ll here, and make the following changes:
	1. replace the line 
			#include "tokens.h"
	   by 
	   		#include "tiger.tab.hh"

***/

/*
PROGRAMMER: Hannah Williams
PROGRAM #: Project 2
DUE DATE: Wednesday, 2/17/21
INSTRUCTOR: Dr. Zhijiang Dong
Description: This project generates a scanner for the Tiger language
*/


%option noyywrap
%option never-interactive
%option nounistd
%option c++

%{
// 1st Section
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <fstream>
#include "tiger.tab.hh"
#include "ErrorMsg.h"

using std::string;
using std::stringstream;

ErrorMsg			errormsg;	// error handler

int		comment_depth = 0;	// depth of the nested comment
string	value = "";			// the value of current string

int			beginLine=-1;	//beginning line no of a string or comment
int			beginCol=-1;	//beginning column no of a string or comment
int			x=0, y=0;		//store the beginning position of a comment block

int		linenum = 1;		//beginning line no of the current matched token
int		colnum = 1;			//beginning column no of the current matched token
int		tokenCol = 1;		//column no after the current matched token

//the following defines actions that will be taken automatically after 
//each token match. It is used to update colnum and tokenCol automatically.
#define YY_USER_ACTION {colnum = tokenCol; tokenCol=colnum+yyleng;}

int string2int(string);			//convert a string to integer value
void newline(void);				//trace the line #
void error(int, int, string);	//output the error message referring to the current token
%}

ALPHA		[A-Za-z]
DIGIT		[0-9]
INT			[0-9]+
IDENTIFIER	{ALPHA}(({ALPHA}|{DIGIT}|"_")*)


/* start conditions */
%x	COMMENT
%x	STR




%%

"while"			{ return WHILE; }			/* reserved words in tiger language */
"for"			{ return FOR; }
"to"			{ return TO; }
"break"			{ return BREAK; }
"let"			{ return LET; }
"in"			{ return IN; }
"end"			{ return END; }
"function"		{ return FUNCTION; }
"var"			{ return VAR; }
"type"			{ return TYPE; }
"array"			{ return ARRAY; }
"if"			{ return IF; }
"then"			{ return THEN; }
"else"			{ return ELSE; }
"do"			{ return DO; }
"of"			{ return OF; }
"nil"			{ return NIL; }


","				{ return COMMA; }			/* punctuation symbols in tiger language */ 
":"				{ return COLON; }
";"				{ return SEMICOLON; }
"("				{ return LPAREN; }
")"				{ return RPAREN; }
"["				{ return LBRACK; }
"]"				{ return RBRACK; }
"{"				{ return LBRACE; }
"}"				{ return RBRACE; }
"."				{ return DOT; }
"+"				{ return PLUS; }
"-"				{ return MINUS; }
"*"				{ return TIMES; }
"/"				{ return DIVIDE; }
"="				{ return EQ; }
"<>"			{ return NEQ; }
"<="			{ return LE; }
">="			{ return GE; }
"&"				{ return AND; }
"|"				{ return OR; }
":="			{ return ASSIGN; }
"<" 			{ return LT; }
">" 			{ return GT; }



" "				{}						/* special escape sequence characters */
\t				{}
\b				{}
\n				{newline(); }



"/*"			{	/* entering comment */
					comment_depth++;
					x = linenum;
					y = colnum;
					BEGIN(COMMENT);	
				}
<COMMENT>"/*"	{	/* nested comment */
					comment_depth++;
				}

<COMMENT>[^*/\n]*	{	/*eat anything that's not a '*' */ }

<COMMENT>"/"+[^/*\n]*  {	/*eat anything that's not a '*' */ }

<COMMENT>"*"+[^*/\n]*	{	/* eat up '*'s not followed by '/'s */	}

<COMMENT>\n		{	/* trace line # and reset column related variable */
					newline();
				}

<COMMENT>"*"+"/"	{	/* close of a comment */
						comment_depth--;
						if ( comment_depth == 0 )
						{
							BEGIN(INITIAL);	
						}
					}
<COMMENT><<EOF>>	{	/* unclosed comments */
						error(x, y, "unclosed comments");
						yyterminate();
					}




"\""			{	/* beginning string */
					value = "";
					beginLine = linenum;
					beginCol = colnum;
					BEGIN(STR);
				}
				

<STR>"\""		{	/* closing string */
					yylval.sval = new string(value);
					BEGIN(INITIAL);
					return STRING;
				}


<STR><<EOF>>	{	/* unclosed string */
					error(linenum, colnum, "unclosed string");
					yyterminate();
				}


<STR>[^"\n\t\\]*		{ value += YYText(); }			/* appending anything other than ending string tokens */



<STR>\n			{	/* appending newline then restarting */
					error(beginLine, beginCol, "unclosed string");
					yylval.sval = new string(value);
					newline();
					BEGIN(INITIAL);
					return STRING;
				}


<STR>\\n		{ value += "\n"; }		/* newline */
<STR>\\t		{ value += "\t"; }		/* tab     */
<STR>\\\"		{ value += "\""; }		/* \       */
<STR>\\\\		{ value += "\\"; }		/* \\      */



<STR>\\[^"nt\\]		{ error(linenum, colnum, string(YYText()) + " illegal token"); }		/* checks for illegal tokens */



{IDENTIFIER} 	{ value = YYText(); yylval.sval = new string(value); return ID; }
{INT}		 	{ yylval.ival = string2int(YYText()); return INT; }



<<EOF>>			{	yyterminate(); }
.				{	error(linenum, colnum, string(YYText()) + " illegal token");}


%%

int string2int( string val )
{
	stringstream	ss(val);
	int				retval;

	ss >> retval;

	return retval;
}

void newline()
{
	linenum++;
	colnum = 1;
	tokenCol = 1;
}

void error(int line, int col, string msg)
{
	errormsg.error(line, col, msg);
}
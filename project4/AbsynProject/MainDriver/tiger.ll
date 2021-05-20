

%option noyywrap
%option c++

%{

/*
	Reese Jacob Peltier
	c8089341
	CSCI 4160
	Project 4
*/

#include <iostream>
#include <string>
#include <sstream>
#include "tiger.tab.hh"
#include "ErrorMsg.h"

using std::string;
using std::stringstream;

ErrorMsg			errormsg;	//error handler

string	tempString = "";	// Hold current string 
string	value = "";			// the value of current string

int			beginLine=-1;	//beginning line no of a string or comment
int			beginCol=-1;	//beginning column no of a string or comment

int		linenum = 1;		//beginning line no of the current matched token
int		colnum = 1;			//beginning column no of the current matched token
int		tokenCol = 1;		//column no after the current matched token


//the following defines actions that will be taken automatically after 
//each token match. It is used to update colnum and tokenCol automatically.
#define YY_USER_ACTION {colnum = tokenCol; tokenCol=colnum+yyleng;}

int x = 0, y = 0;
int c_depth = 0;

int string2int(string);			//convert a string to integer value
void newline(void);				//trace the line #
void error(int, int, string);	//output the error message referring to the current token
%}

ALPHA		[A-Za-z]
DIGIT		[0-9]
LETTER		[A-Za-z]
INT			[0-9]+
IDENTIFIER	{ALPHA}(({ALPHA}|{DIGIT}|"_")*)

%x	COMMENT
%x	STRINGT

%%
"while"			{ return WHILE; }
"for"			{ return FOR; }
"to"			{ return TO; }
"break"			{ return BREAK; }
"in"			{ return IN; }
"end"			{ return END; }
"function"		{ return FUNCTION; }
"var"			{ return VAR; }
"type"			{ return TYPE; }
"if"			{ return IF; }
"then"			{ return THEN; }
"else"			{ return ELSE; }
"do"			{ return DO; }
"of"			{ return OF; }
"nil"			{ return NIL; }
"let"			{ return LET; }

","				{ return COMMA; }
":"				{ return COLON; }
";"				{ return SEMICOLON; }
"("				{ return LPAREN; }
")"				{ return RPAREN; }
"."				{ return DOT; }
"+"				{ return PLUS; }
"-"				{ return MINUS; }
"*"				{ return TIMES; }
"/"				{ return DIVIDE; }
"="				{ return EQ; }
"<>"			{ return NEQ; }
"<"				{ return LT; }
"<="			{ return LE; }
">"				{ return GT; }
">="			{ return GE; }
"&"				{ return AND; }
"|"				{ return OR; }
":="			{ return ASSIGN; }


"\""			{	
					value = "";
					beginLine = linenum;
					beginCol = colnum;
					BEGIN(STRINGT);
				}

<STRINGT>"\""		{	
						yylval.sval = new string(value);
						BEGIN(INITIAL);
						return STRING;
					}

<STRINGT><<EOF>>	{	
						// unclosed string
						error(linenum, colnum, "unclosed string");
						yyterminate();
					}


<STRINGT>[^"\n\t\\]*	{	
							value += YYText();
						}

<STRINGT>\n		{	 
					error(beginLine,beginCol,"unclosed string");
					yylval.sval = new string(value);
					newline();
					BEGIN(INITIAL);
					return STRING;
				}

<STRINGT>\\n		{	
						value += "\n";	
					}

<STRINGT>\\t		{	
						value += "\t"; 
					}

<STRINGT>\\\\	{	
					value += "\\"; 
				}

<STRINGT>\\\"	{	
					value += "\""; 
				}

<STRINGT>\\[^"nt\\]	{	
							tempString = YYText();
							error(linenum, colnum, tempString + " illegal token");
						}


"/*"			{	/* entering comment */
					x = linenum;
					y = colnum;
					c_depth ++;
					BEGIN(COMMENT);
				}

<COMMENT>"/*"	{	/* nested comment */
					c_depth ++;
				}

<COMMENT>[^*/\n]*	{	/*anything that's not a '*' */ }

<COMMENT>"/"+[^/*\n]*  {	/*anything that's not a '*' */ }

<COMMENT>"*"+[^*/\n]*	{	/* '*'s not followed by '/'s */	}

<COMMENT>\n		{	/* trace line # and reset column related variable */
					newline();
				}

<COMMENT>"*"+"/"	{	/* close of a comment */
						c_depth --;
						if ( c_depth == 0 )
						{
							BEGIN(INITIAL);
						}
					}

<COMMENT><<EOF>>	{	/* unclosed comments */
						error(x, y, "unclosed comments");
						yyterminate();
					}

" "				{}
\t				{}
\b				{}
\n				{newline(); }

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
	linenum ++;
	colnum = 1;
	tokenCol = 1;
}

void error(int line, int col, string msg)
{
	errormsg.error(line, col, msg);
}

%{ 
#include "utile.h"  
#include "y.tab.h"

%}
D[0-9]
L[a-zA-Z_]
%% 
"+"      {return PLUS;}
"-"      {return MOINS;}
"*"      {return STAR;}
"/"      {return DIV;}
"("      {return PO;}
")"      {return PF;}
"{"      {return AO;}
"}"      {return AF;}
"="      {return EQ;}
"if"     {return IF;}
"else"   {return ELSE;}
","      {return VIR;}
"<"      {return INF;}
">"      {return SUP;}
"=="     {return EQUAL;}
"!="     {return DIFF;}
"&&"     {return AND;}
"||"     {return OR;}
"!"      {return NOT;}
";"      {return PV;}
"do"     {return DO;}
"while"  {return WHILE;}
"until"  {return UNTIL;}
"return" {return RETURN;}
"int"    {return INT;}
"float"  {return FLOAT;}
"void"   {return VOID;}

[$]?{L}({L}|{D})* { yylval.sid=strdup(yytext); return(ID); }
{D}+    	  { yylval.n=atoi(yytext); return(CONSTANTI); }
{D}+"."{D}*       { yylval.f=atof(yytext); return(CONSTANTF); }
\n       {; increment_line_number();}
[ \t]    {/* on avale sans rendre la main */; }

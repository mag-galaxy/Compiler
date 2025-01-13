%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *message);
int yylex();
%}

%union{
    double fval;
}

%token <fval> NUM
%token FFUNC GFUNC HFUNC LP RP COMMA
%type <fval> expr function

%%
//grammar
prog    : function  {printf("%.3f", $1);}
        ;
function: FFUNC LP expr RP  { $$ = 4*$3 -1;}
        | GFUNC LP expr COMMA expr RP   { $$ = 2*$3 + $5 -5;}
        | HFUNC LP expr COMMA expr COMMA expr RP    { $$ = 3*$3 - 5*$5 + $7;}
        ;
expr    : function  { $$ = $1;}
        | NUM       { $$ = $1;}
        ;

%%
//functions
void yyerror(const char *message){
        printf("Invalid");
}

int main(){
        yyparse();
        return 0;
}
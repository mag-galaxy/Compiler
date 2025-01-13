%{
    #include "ba3_1.tab.h"
%}
num -?[0-9]+(.[0-9]+)?
%%
"f" {return(FFUNC);}
"g" {return(GFUNC);}
"h" {return(HFUNC);}
"(" {return(LP);}
")" {return(RP);}
"," {return(COMMA);}
{num} {yylval.fval = atof(yytext); return(NUM);}
\n  {}
.   {}
%%
%{
    #include "ba3_2.tab.h"
%}

%%
[1-9][0-9]*  {yylval.ival = atoi(yytext); return(NUM);}
"0" {return(END);}
\n  {}
.   {}
%%
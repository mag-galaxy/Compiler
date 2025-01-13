%{
%}
eol \n
DIGIT [0-9]
ALPH [a-zA-Z ]
INT {DIGIT}+{eol}
FLOAT {DIGIT}+\.{DIGIT}+{eol}
BOOL ("true"|"false"){eol}
OP "+"|"-"|"*"|"/"
OPR {OP}+{DIGIT}+
OPRAT {DIGIT}+({OP}|{DIGIT})+{eol}
STR \"[^\n"]*\"{eol}
STRR \'[^\n']*\'{eol}
OTHER [^\n\t]+{eol}
INTE {DIGIT}+
FLOATE {DIGIT}+\.{DIGIT}+
BOOLE ("true"|"false")
OPRATE {DIGIT}+({OP}|{DIGIT})+
STRE \"[^\n"]*\"
STRRE \'[^\n']*\'
OTHERE [^\n\t]+
%%
{OP}        {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" INVALID\n");}
{OPR}       {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" INVALID\n");}
{INT}       {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" INTEGER\n");}
{FLOAT}     {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" FLOAT\n");}
{BOOL}      {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" BOOLEAN\n");}
{OPRAT}     {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" OPERATION\n");}
{STR}       {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" STRING\n");}
{STRR}      {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" STRING\n");}
{OTHER}     {
                for(int i = 0; i < yyleng-1; ++i){
                    printf("%c", yytext[i]);}
                printf(" INVALID\n");}
{INTE}       {
                for(int i = 0; i < yyleng; ++i){
                    printf("%c", yytext[i]);}
                printf(" INTEGER\n");}
{FLOATE}     {
                for(int i = 0; i < yyleng; ++i){
                    printf("%c", yytext[i]);}
                printf(" FLOAT\n");}
{BOOLE}      {
                for(int i = 0; i < yyleng; ++i){
                    printf("%c", yytext[i]);}
                printf(" BOOLEAN\n");}
{OPRATE}     {
                for(int i = 0; i < yyleng; ++i){
                    printf("%c", yytext[i]);}
                printf(" OPERATION\n");}
{STRE}       {
                for(int i = 0; i < yyleng; ++i){
                    printf("%c", yytext[i]);}
                printf(" STRING\n");}
{STRRE}      {
                for(int i = 0; i < yyleng; ++i){
                    printf("%c", yytext[i]);}
                printf(" STRING\n");}
{OTHERE}     {
                for(int i = 0; i < yyleng; ++i){
                    printf("%c", yytext[i]);}
                printf(" INVALID\n");}
{eol}       {}
%%
int main(){
    yylex();
    return 0;
}
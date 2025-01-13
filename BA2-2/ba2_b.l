%{
int tabnow = 0;
int tablast = 0;
int inmul = 0;
%}
eol \n
TABLINE {eol}[\t]*
mul "\"\"\""
SINGCOM "# "[^\n]*
STRING \"[^\n"]+\"
PRINT "print("({STRING}|[0-9]+)\)
%%
{mul}       {
                if(inmul){
                    inmul = 0;
                    printf("*/");
                }
                else{
                    inmul = 1;
                    printf("/*");
                }
            }
{TABLINE}   {
                if(inmul)
                    printf("%s", yytext);
                else{
                    printf("\n");
                    for(int i = 1; i < yyleng; ++i)
                        tabnow++;
                    int tabnum = tablast;
                    //printf("%d %d\n", tablast, tabnow);
                    if(tabnow < tablast){
                        for(int i = 0; i < tablast-tabnow; ++i){
                            for(int j = 0; j < tabnum-1; ++j)
                                printf("\t");
                            printf("}\n");
                            tabnum--;
                        }
                    }
                    for(int i = 0; i < tabnow; ++i)
                        printf("\t");
                    //if(tabnow==0)
                    //    printf("\n");
                    tablast = tabnow;
                    tabnow = 0;
                }
            }
{SINGCOM}   {
                printf("// ");
                for(int i = 2; i < yyleng; ++i)
                    printf("%c", yytext[i]);
            }
{PRINT}     {
                if(inmul)
                    printf("%s", yytext);
                else{
                    printf("cout << ");
                    for(int i = 6; i <= yyleng-2; ++i)
                        printf("%c", yytext[i]);
                    printf(" << endl;");
                }
                
            }
"if True:"     {
                if(inmul)
                    printf("%s", yytext);
                else
                    printf("if(true) {");
            }
"if False:"    {
                if(inmul)
                    printf("%s", yytext);
                else
                    printf("if(false) {");
                
            }
.           {
                printf("%s", yytext);
            }
%%
int main(){
    yylex();
    return 0;
}
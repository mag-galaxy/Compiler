%{
// C code=========================================
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// functions======================================
int yylex();
void yyerror(const char* message);

// tree nodes=====================================
struct NODE{
    char type;
    int number; // NUM or BOOL
    char *iden; // ID
    struct NODE *lnode, *rnode, *mnode; //mnode for if-else
};

struct NODE *NewNode(struct NODE *lchild, struct NODE *rchild, char nodetype); // create new node
void Traverse(struct NODE *fnode); // post-order
void FreeTree(struct NODE *fnode);
void AddOp(struct NODE *fnode);
void SubOp(struct NODE *fnode);
void MulOp(struct NODE *fnode);
void DivOp(struct NODE *fnode);
void ModOp(struct NODE *fnode);
void GreaterOp(struct NODE *fnode);
void SmallerOp(struct NODE *fnode);
void EqualOp(struct NODE *fnode);
void AndOp(struct NODE *fnode);
void OrOp(struct NODE *fnode);
void StoreID(struct NODE *fnode);
void BindParam(struct NODE *fnode);
void Postorder(struct NODE *start);

// map liked table to store variable name and its value
#define MAP_SIZE 50
struct MAP{
        char *vName;
        int vValue;
};

// map liked table to store function name and its structure
struct NameFun{
        char *fName;
        struct NODE *fExp;
};

// variables======================================
struct NODE *root = NULL; // initialize root
struct MAP var_map[MAP_SIZE]; // it can store 50 variables
struct MAP par_map[MAP_SIZE]; // it can store 50 parameters
struct NameFun fun_map[MAP_SIZE]; // it can store 50 functions
int rst; // result of any calculation
int first; // flag, first time enter "equal" operation
int enumber; // the number we want to compare with
int Vmaplen = 0; // var_map is empty since which index
int Pmaplen = 0; // par_map is empty since which index
int Pcount = 0; // number of parameters of a function
int Fmaplen = 0; //fun_map is empty since which index
int isFun = 0; // variable is in a function or not
%}

%union{
    int ival, bval; // integer, boolean
    char *sval; // string
    struct NODE *astnode;
}

%token <ival> NUM
%token <bval> BOOL
%token <sval> ID
%token PNUM PBOOL ADD SUB MUL DIV MOD GREATER SMALLER EQUAL
%token AND OR NOT DEF FUN IF LB RB

%type <astnode> prog stmts stmt print_stmt exp exps num_op logical_op
%type <astnode> plus minus multiply divide modulus greater smaller equal
%type <astnode> and_op or_op not_op
%type <astnode> def_stmt variable fun_exp fun_ids ids fun_body fun_call
%type <astnode> param fun_name if_exp test_exp then_exp else_exp

%%
prog    : stmts         { root = $1;}
        ;
stmts   : stmts stmt    { $$ = NewNode($1, $2, 'S');}
        | stmt          { $$ = $1;}
        ;
stmt    : exp           { $$ = $1;}
        | def_stmt      { $$ = $1;}
        | print_stmt    { $$ = $1;}
        ;
print_stmt  : LB PNUM exp RB    { $$ = NewNode($3, NULL, 'P');}
            | LB PBOOL exp RB   { $$ = NewNode($3, NULL, 'p');}
            ;
exp     : BOOL      {
                        $$ = NewNode(NULL, NULL, 'B');
                        $$->number = $1;
                    }
        | NUM       {
                        $$ = NewNode(NULL, NULL, 'N');
                        $$->number = $1;
                    }
        | variable      { $$ = $1;}
        | num_op        { $$ = $1;}
        | logical_op    { $$ = $1;}
        | fun_exp       { $$ = $1;}
        | fun_call      { $$ = $1;}
        | if_exp        { $$ = $1;}
        ;
exps    : exp exps      { $$ = NewNode($1, $2, 'E');}
        | exp           { $$ = $1;}
        ;
num_op  : plus          { $$ = $1;}
        | minus         { $$ = $1;}
        | multiply      { $$ = $1;}
        | divide        { $$ = $1;}
        | modulus       { $$ = $1;}
        | greater       { $$ = $1;}
        | smaller       { $$ = $1;}
        | equal         { $$ = $1;}
        ;
plus    : LB ADD exp exps RB    { $$ = NewNode($3, $4, '+');}
        ;
minus   : LB SUB exp exp RB     { $$ = NewNode($3, $4, '-');}
        ;
multiply: LB MUL exp exps RB    { $$ = NewNode($3, $4, '*');}
        ;
divide  : LB DIV exp exp RB     { $$ = NewNode($3, $4, '/');}
        ;
modulus : LB MOD exp exp RB     { $$ = NewNode($3, $4, '%');}
        ;
greater : LB GREATER exp exp RB { $$ = NewNode($3, $4, '>');}
        ;
smaller : LB SMALLER exp exp RB { $$ = NewNode($3, $4, '<');}
        ;
equal   : LB EQUAL exp exps RB  { $$ = NewNode($3, $4, '=');}
        ;
logical_op  : and_op    { $$ = $1;}
            | or_op     { $$ = $1;}
            | not_op    { $$ = $1;}
            ;
and_op  : LB AND exp exps RB        { $$ = NewNode($3, $4, '&');}
        ;
or_op   : LB OR exp exps RB         { $$ = NewNode($3, $4, '|');}
        ;
not_op  : LB NOT exp RB             { $$ = NewNode($3, NULL, '!');}
        ;
def_stmt    : LB DEF variable exp RB    { $$ = NewNode($3, $4, 'D');}
            ;
variable    : ID    {
                        $$ = NewNode(NULL, NULL, 'V');
                        $$->iden = $1;
                    }
            ;
fun_exp     : LB FUN fun_ids fun_body RB    { $$ = NewNode($3, $4, 'F');}
            ;
fun_ids     : LB ids RB { $$ = $2;}
            ;
ids         : ids variable  { $$ = NewNode($1, $2, 'E');}
            |               { $$ = NewNode(NULL, NULL, 'U');}
            ;
fun_body    : exp       { $$ = $1;}
            ;
fun_call    : LB fun_exp param RB   { $$ = NewNode($2, $3, 'C');}
            | LB fun_name param RB  { $$ = NewNode($2, $3, 'c');}
            ;
param       : exp param { $$ = NewNode($1, $2, 'E');}
            |           { $$ = NewNode(NULL, NULL, 'U');}
            ;
fun_name    : ID    {
                        $$ = NewNode(NULL, NULL, 'f');
                        $$->iden = $1;
                    }
            ;
if_exp      : LB IF test_exp then_exp else_exp RB   {
                                                        $$ = NewNode($3, $5, 'I');
                                                        $$->mnode = $4;
                                                    }
            ;
test_exp    : exp       { $$ = $1;}
            ;
then_exp    : exp       { $$ = $1;}
            ;
else_exp    : exp       { $$ = $1;}
            ;

%%
// C functions===================================
void yyerror(const char *message){
        printf("syntax error\n");
}

int main(){
        yyparse(); // build AST
        Traverse(root); // it will print result of AST
        //Postorder(root);
        FreeTree(root); // avoid memoty leak
        return 0;
}

struct NODE *NewNode(struct NODE *lchild, struct NODE *rchild, char nodetype){
        struct NODE *mynode = (struct NODE *)malloc(sizeof(struct NODE));
        mynode->type = nodetype;
        mynode->number = 0;
        mynode->iden = "";
        mynode->lnode = lchild;
        mynode->rnode = rchild;
        mynode->mnode = NULL;
        return mynode;
}

void Postorder(struct NODE *start){
        if(start != NULL){
                Postorder(start->lnode);
                Postorder(start->mnode);
                Postorder(start->rnode);
                // print myself
                printf("parent: %c\n", start->type);
                if(start->lnode!=NULL)
                        printf("left: %c,", start->lnode->type);
                if(start->rnode!=NULL)
                        printf(" right: %c\n", start->rnode->type);
        }
        return;
}

void Traverse(struct NODE *fnode){ // post-order
        if(fnode == NULL)
                return;
        if(fnode->type == 'P'){ // print number, right node is NULL
                Traverse(fnode->lnode);
                printf("%d\n", fnode->lnode->number);
        }
        else if(fnode->type == 'p'){ // print boolean, right node is NULL
                Traverse(fnode->lnode);
                if(fnode->lnode->number)
                        printf("#t\n");
                else
                        printf("#f\n");
        }
        else if(fnode->type == '+'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                rst = 0;
                AddOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '-'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                SubOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '*'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                rst = 1;
                MulOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '/'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                DivOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '%'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                ModOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '>'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                GreaterOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '<'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                SmallerOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '='){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                first = 1; // first number to compare
                rst = 1;
                EqualOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '&'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                rst = 1;
                AndOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '|'){
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
                rst = 0;
                OrOp(fnode);
                fnode->number = rst;
        }
        else if(fnode->type == '!'){ // right node is NULL
                Traverse(fnode->lnode);
                fnode->number = !fnode->lnode->number;
        }
        else if(fnode->type == 'I'){
                Traverse(fnode->lnode); //test_exp
                Traverse(fnode->mnode); //then_exp
                Traverse(fnode->rnode); //else_exp
                if(fnode->lnode->number) // if condition is true, go to "then", else, go to "else"
                        fnode->number = fnode->mnode->number;
                else
                        fnode->number = fnode->rnode->number;
        }
        else if(fnode->type == 'D'){
                if(fnode->rnode->type == 'F'){ // fun_exp
                        //define a function, lnode is fun name, rnode is fun_exp
                        if(fnode->rnode->lnode->type == 'U'){ // no fun_ids, seen as a variable
                                Traverse(fnode->rnode->rnode); // calculate fun_body
                                var_map[Vmaplen].vName = fnode->lnode->iden;
                                var_map[Vmaplen].vValue = fnode->rnode->rnode->number;
                                Vmaplen++;
                        }
                        else{ // store in fun_map
                                fun_map[Fmaplen].fName = fnode->lnode->iden; // variable
                                fun_map[Fmaplen].fExp = fnode->rnode; // fun_exp
                                Fmaplen++;
                        }
                }
                else{
                        // define a variable, lnode is var name, rnode is var value
                        Traverse(fnode->lnode);
                        Traverse(fnode->rnode);
                        var_map[Vmaplen].vName = fnode->lnode->iden;
                        var_map[Vmaplen].vValue = fnode->rnode->number;
                        Vmaplen++;
                }       
        }
        else if(fnode->type == 'V'){
                // call a variable, search variable map
                int i;
                if(isFun){ // ref. to par_map
                        for(i = 0; i < Pmaplen; ++i){
                                if(strcmp(par_map[i].vName, fnode->iden) == 0){
                                        fnode->number = par_map[i].vValue;
                                        break;
                                }
                        }
                }
                else{ // ref. to var_map
                        for(i = 0; i < Vmaplen; ++i){
                                if(strcmp(var_map[i].vName, fnode->iden) == 0){
                                        fnode->number = var_map[i].vValue;
                                        break;
                                }
                        }
                }
        }
        else if(fnode->type == 'C'){
                // lnode is fun_exp, rnode is param
                // bind fnode->lnode->lnode (fun_ids) to fnode->rnode (param)
                if(fnode->lnode->lnode->type == 'U'){
                        // no ids or parameters
                }
                else{
                        Pcount = 0;
                        StoreID(fnode->lnode->lnode); // fun_ids
                        Pmaplen -= Pcount;
                        BindParam(fnode->rnode); // param
                }
                
                isFun = 1;
                Traverse(fnode->lnode->rnode); // fun_body
                isFun = 0;
                fnode->number = fnode->lnode->rnode->number;
        }
        else if(fnode->type == 'c'){
                // called by function name
                if(fnode->rnode->type == 'U'){
                        // need no parameters, search var_map
                        int i;
                        for(i = 0; i < Vmaplen; ++i){
                                if(strcmp(var_map[i].vName, fnode->lnode->iden) == 0){
                                        fnode->number = var_map[i].vValue;
                                        break;
                                }
                        }
                }
                else{
                        // need to bind parameters
                        struct NODE *temp = NULL;
                        int i;
                        for(i = 0; i < Fmaplen; ++i){ // find fun_exp first
                                if(strcmp(fun_map[i].fName, fnode->lnode->iden) == 0){
                                        temp = fun_map[i].fExp;
                                        break;
                                }
                        }
                        Pcount = 0;
                        StoreID(temp->lnode); // fun_ids
                        Pmaplen -= Pcount;
                        BindParam(fnode->rnode); // param
                        isFun = 1;
                        Traverse(temp->rnode); // fun_body
                        isFun = 0;
                        fnode->number = temp->rnode->number;
                        free(temp);
                }
        }
        else{ // stmts or exps
                Traverse(fnode->lnode);
                Traverse(fnode->rnode);
        }
}

void FreeTree(struct NODE *fnode){ // post-order
        if(fnode != NULL){
                FreeTree(fnode->lnode);
                FreeTree(fnode->mnode);
                FreeTree(fnode->rnode);
                free(fnode);
        }
}

void AddOp(struct NODE *fnode){ // exps is rnode
        if(fnode->lnode != NULL){
                //printf("1. rst is %d\n", rst);
                //printf("2. number is %d\n", fnode->lnode->number);
                if(fnode->lnode->type != 'E')
                        rst = rst + fnode->lnode->number;
                else
                        AddOp(fnode->lnode);
        }
        if(fnode->rnode != NULL){
                //printf("3. rst is %d\n", rst);
                //printf("4. number is %d\n", fnode->rnode->number);
                //printf("type of rnode: %c\n", fnode->rnode->type);
                if(fnode->rnode->type != 'E')
                        rst = rst + fnode->rnode->number;
                else
                        AddOp(fnode->rnode);
        }
}

void SubOp(struct NODE *fnode){
        if(fnode->lnode!=NULL && fnode->rnode!=NULL)
                rst = fnode->lnode->number - fnode->rnode->number;
}

void MulOp(struct NODE *fnode){
        if(fnode->lnode != NULL){
                if(fnode->lnode->type != 'E'){
                        //printf("rst is %d\n", rst);
                        //printf("number of lnode is %d\n", fnode->lnode->number);
                        rst = rst * fnode->lnode->number;
                }  
                else
                        MulOp(fnode->lnode); // recursive operation
        }
        if(fnode->rnode != NULL){
                if(fnode->rnode->type != 'E'){
                        //printf("rst is %d\n", rst);
                        //printf("number of rnode is %d\n", fnode->rnode->number);
                        rst = rst * fnode->rnode->number;
                }
                else
                        MulOp(fnode->rnode); // recursive operation
        }
}

void DivOp(struct NODE *fnode){
        if(fnode->lnode!=NULL && fnode->rnode!=NULL)
                rst = fnode->lnode->number / fnode->rnode->number;
}

void ModOp(struct NODE *fnode){
        if(fnode->lnode!=NULL && fnode->rnode!=NULL)
                rst = fnode->lnode->number % fnode->rnode->number;
}

void GreaterOp(struct NODE *fnode){
        if(fnode->lnode!=NULL && fnode->rnode!=NULL){
                if(fnode->lnode->number > fnode->rnode->number)
                        rst = 1;
                else
                        rst = 0;
        }
}

void SmallerOp(struct NODE *fnode){
        if(fnode->lnode!=NULL && fnode->rnode!=NULL){
                if(fnode->lnode->number < fnode->rnode->number)
                        rst = 1;
                else
                        rst = 0;
        }
}

void EqualOp(struct NODE *fnode){
        if(fnode->lnode != NULL){
                if(fnode->lnode->type != 'E'){
                        if(first == 1){ // first number to compare
                                enumber = fnode->lnode->number;
                                //printf("1. number is %d\n", fnode->lnode->number);
                                first = 0;
                        }
                        else{
                                //printf("2. number is %d\n", fnode->lnode->number);
                                if(fnode->lnode->number != enumber)
                                        rst = 0;
                        }
                }
                else
                        EqualOp(fnode->lnode); // recursive comparison
        }
        if(fnode->rnode != NULL){
                if(fnode->rnode->type != 'E'){
                        if(first == 1){
                                enumber = fnode->rnode->number;
                                //printf("3. number is %d\n", fnode->rnode->number);
                                first = 0;
                        }
                        else{
                                //printf("4. number is %d\n", fnode->rnode->number);
                                if(fnode->rnode->number != enumber)
                                        rst = 0;
                        }
                }
                else
                        EqualOp(fnode->rnode); // recursive comparison
        }
}

void AndOp(struct NODE *fnode){
        if(fnode->lnode != NULL){
                if(fnode->lnode->type != 'E')
                        rst = rst & fnode->lnode->number;
                else
                        AndOp(fnode->lnode); // recursive operation
        }
        if(fnode->rnode != NULL){
                if(fnode->rnode->type != 'E')
                        rst = rst & fnode->rnode->number;
                else
                        AndOp(fnode->rnode); // recursive operation
        }
}

void OrOp(struct NODE *fnode){
        if(fnode->lnode != NULL){
                if(fnode->lnode->type != 'E')
                        rst = rst | fnode->lnode->number;
                else
                        OrOp(fnode->lnode); // recursive operation
        }
        if(fnode->rnode != NULL){
                if(fnode->rnode->type != 'E')
                        rst = rst | fnode->rnode->number;
                else
                        OrOp(fnode->rnode); // recursive operation
        }
}

void StoreID(struct NODE *fnode){
        if(fnode->lnode->type == 'E')
                StoreID(fnode->lnode);
        par_map[Pmaplen].vName = fnode->rnode->iden;
        Pmaplen++;
        Pcount++;
}

void BindParam(struct NODE *fnode){
        Traverse(fnode->lnode);
        par_map[Pmaplen].vValue = fnode->lnode->number;
        Pmaplen++;
        if(fnode->rnode->type == 'E')
                BindParam(fnode->rnode);
}

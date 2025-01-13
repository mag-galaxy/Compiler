%{
#include <stdio.h>
#include <stdlib.h>

// functions=======================================
int yylex();
void yyerror(const char* message);
void errormsg(int sit, int i, int j);

//stack============================================
#define SIZE 20
typedef struct stack {
    int data[SIZE];
    int top;
} STACK;

int train;
int top();
void Push(STACK *ptr, int input);
int Pop(STACK *ptr);
int Empty(STACK *ptr);//return 0 or 1
int Overflow(STACK *ptr);//return 0 or 1
void Dump(STACK *ptr);

// variables=======================================
STACK holdstack, sstack, instack, iistack;
int max = 0;
%}

%union{
    int ival;
}

%token <ival> NUM
%token END

%%
//grammar
prog    : numbers END       
        {
            // initialize input order
            while(!Empty(&instack)){
                Push(&iistack, Pop(&instack));
            }

            // initialize all cars
            int i;
            for(i = max; i >= 1; --i){
                Push(&sstack, i);
            }

            while(!Empty(&iistack)){
                int n1 = Pop(&iistack);

                if(Empty(&sstack)){
                    if(Empty(&holdstack))
                        errormsg(0, 0, 0);
                    else{ // !Empty(&holdstack)
                        if(Top(&holdstack) == n1){
                            int out = Pop(&holdstack);
                            printf("Moving train %d from holding track\n", out);
                            continue;
                        }
                        else{ // Top(&holdstack) != n1
                            errormsg(1, Top(&holdstack), n1);
                        }
                    }
                }
                else{ // !Empty(&sstack)
                    if(Top(&sstack) == n1){
                        int i = Pop(&sstack);
                        printf("Train %d passing through\n", i);
                        continue;
                    }
                    else{ // Top(&sstack) != n1
                        if(!Empty(&holdstack) && Top(&holdstack) == n1){
                            int out = Pop(&holdstack);
                            printf("Moving train %d from holding track\n", out);
                            continue;
                        }
                        else{ // Top(&holdstack) != n1
                            while(!Empty(&sstack) && Top(&sstack) != n1){
                                int out = Pop(&sstack);
                                Push(&holdstack, out);
                                printf("Push train %d to holding track\n", out);
                                Dump(&holdstack);
                            }
                            if(Top(&sstack) == n1){
                                int i = Pop(&sstack);
                                printf("Train %d passing through\n", i);
                                continue;
                            }
                            else{
                                errormsg(2, 0, 0);
                            }
                        }
                    }
                }
            }

            // after go through every input number
            if(!Empty(&holdstack))
                errormsg(2, 0, 0);
            if(Empty(&sstack))
                printf("Success\n");
        }
        ;
numbers : numbers number
        | number
        ;
number  : NUM
        {
            Push(&instack, $1);
            if($1 > max)
                max = $1;
        }
        ;

%%
//functions
void yyerror(const char *message){
        printf("%s\n",message);
}

void errormsg(int sit, int i, int j){
    if(sit == 0){
        printf("Error: Impossible to rearrange\n");
        printf("There is no any train in the holding track\n");
        exit(0);
    }
    else if(sit == 1){
        printf("Error: Impossible to rearrange\n");
        printf("The first train in the holding track is train %d instead of train %d\n", i, j);
        exit(0);
    }
    else if(sit == 2){
        printf("Error: There is still existing trains in the holding track\n");
        exit(0);
    }
}

int main(){
    // initialize original car stack
    sstack.top = -1;
    holdstack.top = -1;
    instack.top = -1;
    iistack.top = -1;
    yyparse();

    return 0;
}

void Dump(STACK *ptr){
        int i;
        printf("Current holding track:");
        for(i=0; i<=ptr->top; ++i)
                printf(" %d", ptr->data[i]);
        printf("\n");
}

int Empty(STACK *ptr){
        if(ptr->top == -1)
                return 1;
        return 0;
}

int Overflow(STACK *ptr){
        if(ptr->top == SIZE-1)
                return 1;
        return 0;
}

void Push(STACK *ptr, int input){
        if(!Overflow(ptr))
                ptr->data[++(ptr->top)] = input;
}

int Pop(STACK *ptr){
        if(!Empty(ptr))
                return (ptr->data[(ptr->top)--]);
}

int Top(STACK *ptr){
    if(!Empty(ptr))
        return (ptr->data[ptr->top]);
}
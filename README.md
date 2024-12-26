# Compiler Final Project
NCU 113-1 Compiler Final Project - Mini LISP interpreter

### Code Description
+ Language: C, Lex, Yacc
+ fp.l for tokenizing input
+ fp.y for building an AST, then traverse the AST and do the action

### Finished

- [x] 1. Syntax Validation
- [x] 2. Print
- [x] 3. Numerical Operations
- [x] 4. Logical Operations
- [x] 5. if Expression
- [x] 6. Variable Definition
- [x] 7. Function
- [x] 8. Named Function
- [ ] b1. Recursion
- [ ] b2. Type Checking
- [ ] b3. Nested Function
- [ ] b4. First-class Function

### How to Run it in Linux system (Virtual Box)
```cpp
bison -d -o y.tab.c fp.y
gcc -c -g -I.. y.tab.c
flex -o lex.yy.c fp.l
gcc -c -g -I.. lex.yy.c
gcc -o fp y.tab.o lex.yy.c -ll -lm
```
```cpp
./fp < <file name>
```

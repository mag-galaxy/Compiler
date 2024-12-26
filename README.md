# Compiler Final Project
NCU 113-1 Compiler Final Project - Mini LISP interpreter

### Finished

- [x] 1. Syntax Validation
- [x] 2. Print
- [x] 3. Numerical Operations
- [x] 4. Logical Operations
- [x] 5. if Expression
- [x] 6. Variable Definition
- [x] 7. Function
- [x] 8. Named Function

### How to Run in Linux system
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

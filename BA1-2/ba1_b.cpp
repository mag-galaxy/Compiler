#include <iostream>
#include <string>
using namespace std;

char Sym[12] = {'+', '-', '*', '/', '=','(', ')', '{','}','<','>',';'};

bool is_digit(char c){
    if(c >= '0' && c <= '9')
        return 1;
    return 0;
}

bool is_letter(char c){
    if((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))
        return 1;
    return 0;
}

bool is_sym(char c){
    for(int i = 0; i < 12; ++i){
        if(c == Sym[i]){
            return 1;
        }
    }
    return 0;
}

void scanner(string str){
    int i = 0;
    while(i < str.length()){
        if(str[i] == ' ' || str[i] == '\n' || str[i] == '\r' || str[i] == '\t'){
            ++i;
            continue;
        }
        else if(is_sym(str[i])){
            cout << "SYMBOL " << '"' << str[i] << '"' << endl;
            ++i;
        }
        else if(is_digit(str[i])){
            string num = "";
            if(str[i] == '0'){
                cout << "NUM " << "\"0\"" << endl;
                ++i;
                continue;
            }
            num.append(1, str[i]);
            ++i;
            while(is_digit(str[i])){
                num.append(1, str[i]);
                ++i;
            }
            cout << "NUM " << '"' << num << '"' << endl;
        }
        else if(is_letter(str[i])){
            string iden = "";
            iden.append(1, str[i]);
            ++i;
            while(is_letter(str[i]) || is_digit(str[i])){
                iden.append(1, str[i]);
                ++i;
            }
            if(iden == "if" || iden == "while"){
                cout << "KEYWORD " << '"' << iden << '"' << endl;
            }
            else{
                cout << "IDENTIFIER " << '"' << iden << '"' << endl;
            }
        }    
        else{
            cout << "Invalid\n";
            ++i;
        }
    }
}

int main(){
    string s = "";
    while(getline(cin, s)){
        scanner(s);
    }
    return 0;
}
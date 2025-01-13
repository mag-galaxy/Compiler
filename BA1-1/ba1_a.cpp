#include <iostream>
#include <string>
#include <vector>
using namespace std;

struct myToken{
   string type;
   string val;
};

int inval = 0;
void stmt(vector <myToken> tokstr, int *index);
void mail(vector <myToken> tokstr, int *index);
void uri(vector <myToken> tokstr, int *index);

myToken create(string t, string v){
    myToken tt;
    tt.type = t;
    tt.val = v;
    return tt;
}

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

vector <myToken> scanner(string str){
    vector <myToken> TS;
    int i = 0;
    while(i < str.length()){
        if(str[i] == ':'){
            TS.push_back(create("COLON", ":"));
            ++i;
        }
        else if(str[i] == '@'){
            TS.push_back(create("AT", "@"));
            ++i;
        }
        else if(str[i] == '.'){
            TS.push_back(create("DOT", "."));
            ++i;
        }
        else if(str[i] == '/'){
            TS.push_back(create("SLASH", "/"));
            ++i;
        }
        else if(is_digit(str[i])){
            string unkown = "";
            unkown.append(1, str[i]);
            ++i;
            while(is_digit(str[i])){
                unkown.append(1, str[i]);
                ++i;
            }
            if(unkown[0] == '0' && unkown[1] == '9' && unkown.length() == 10){
                TS.push_back(create("PHONENUM", unkown));
                continue;
            }
            while(is_digit(str[i]) || is_letter(str[i])){
                unkown.append(1, str[i]);
                ++i;
            }
            TS.push_back(create("PATH", unkown));
        }
        else if(is_letter(str[i])){
            string unkown = "";
            unkown.append(1, str[i]);
            ++i;
            while(is_letter(str[i])){
                unkown.append(1, str[i]);
                ++i;
            }
            if(unkown == "gmail" || unkown == "yahoo" || unkown == "iCloud" || unkown == "outlook"){
                TS.push_back(create("MAILDOMAIN", unkown));
                continue;
            }
            else if(unkown == "org" || unkown == "com"){
                TS.push_back(create("DOMAIN", unkown));
                continue;
            }
            else if(unkown == "https" || unkown == "tel" || unkown == "mailto"){
                TS.push_back(create("SCHEME", unkown));
                continue;
            }
            while(is_digit(str[i]) || is_letter(str[i])){
                unkown.append(1, str[i]);
                ++i;
            }
            TS.push_back(create("PATH", unkown));
        }
        else{
            string inv = "";
            inv.append(1, str[i]);
            TS.push_back(create("INVALID", inv));
            ++i;
            inval = 1;
        }
    }
    return TS;
}

void parser(vector <myToken> tokstr, int *index){
    stmt(tokstr, index);
}

void stmt(vector <myToken> tokstr, int *index){
    if(*index >= tokstr.size()){
        return;
    }
    if(tokstr[*index].type == "PHONENUM"){
        *index = *index + 1;
    }
    else if(tokstr[*index].type == "PATH"){
        mail(tokstr, index);
    }
    else if(tokstr[*index].type == "SCHEME"){
        uri(tokstr, index);
    }
    else{
        inval = 2;
    }
}

void mail(vector <myToken> tokstr, int *index){
    if(*index >= tokstr.size()){
        return;
    }
    if(tokstr[*index].type=="PATH" && tokstr[(*index+1)].type=="AT" && tokstr[(*index+2)].type=="MAILDOMAIN" && tokstr[(*index+3)].type=="DOT" && tokstr[(*index+4)].type=="DOMAIN"){
        *index = *index + 5;
    }
    else{
        inval = 3;
    }
}

void uri(vector <myToken> tokstr, int *index){
    if(*index >= tokstr.size()){
        return;
    }
    if(tokstr[*index].type=="SCHEME" && tokstr[(*index+1)].type=="COLON" && tokstr[(*index+2)].type=="SLASH" && tokstr[(*index+3)].type=="SLASH" && tokstr[(*index+4)].type=="PATH" && tokstr[(*index+5)].type=="DOT" && tokstr[(*index+6)].type=="DOMAIN"){
        *index = *index + 7;
    }
    else if(tokstr[*index].type=="SCHEME" && tokstr[(*index+1)].type=="COLON" && tokstr[(*index+2)].type=="PHONENUM"){
        *index = *index + 3;
    }
    else if(tokstr[*index].type=="SCHEME" && tokstr[(*index+1)].type=="COLON" && tokstr[(*index+2)].type=="PATH"){
        *index = *index + 2;
        mail(tokstr, index);
    }
    else{
        inval = 4;
    }
}

int main(){
    string s = "";
    vector <myToken> stream;
    int ind = 0;

    getline(cin, s);
    stream = scanner(s);
    parser(stream, &ind);
    if(inval != 0){
        cout << "Invalid input\n";
    }
    else{
        for(int i = 0; i < stream.size(); ++i){
            cout << stream[i].val << " " << stream[i].type << endl;
        }
    }
    return 0;
}
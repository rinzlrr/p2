#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pretty.h"

int
main() {
    int tk;

    myInit();
    while(tk = yylex()) {
	printf("got this: %s\n", yytext);
    }
    dumpSymbolTable();
}

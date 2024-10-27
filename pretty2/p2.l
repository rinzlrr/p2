%{


#include <stdio.h>
#include "p2.h"

#define TRUE (1)
#define FALSE (0)

#define INDENT (4)

int line = 0;
int column = 4;
int paren = 0;
int inComment = 0;
int debug = 1;

void write_indent();
void write_html();
void write_html_char(int);
void write_string();
void write_char();
void write_oct();
void write_hex();
void write_int();
void write_fp();
void write_id();
void write_begin();
void write_end();
void write_open();
void write_close();
void write_bopen();
void write_bclose();
void write_sep();
void write_op();
void write_inline();
void write_comment();
void write_directive();

%}

%option	noyywrap
%option	yylineno  

quote	\'
ditto	\"
delim	[ ,;]  
ws	    [ \t\n\r\f\v] 
alpha   [a-zA-Z_] 
digit   [0-9]
oct     0[0-7]+
exp     [eE][-+]?[0-9]+
hex	    0[xX][0-9a-fA-F]+
id	    {alpha}({alpha}|{digit})*
number	{digit}+(\.{digit}+)?({exp})? 

%%


{ws}				{ /* no action and no return */ }
{quote}([^']|\\')*{quote}	write_char();
{ditto}([^"]|\\\")*{ditto}	write_string();
{oct}       		write_oct();            //joshua
{hex}   			write_hex();            //joshua
{digit}+			write_int();            //joshua
{number}	                write_fp();     //joshua
{id}    	                write_id();     //joshua
"{"     			write_begin();
"}"     			write_end();
"("     			write_open();
")"     			write_close();
"["				write_bopen();
"]"				write_bclose();         //JOSHUA WROTE THESE RULES
";" 		    write_sep();
"," 		    write_sep();
"+"				| 
"-"         | 
"+="				|
"&&"            |   
">"            |         //joshua
"<"             |        //joshua
"?"             |    //joshua
":"     |    //joshua
"::"	|		        //joshua
"||" |	                //joshua
"==" |                  //joshua
"!=" |                  //joshua
"!" |
"%" |	
"->" |
"&"  |
"*" |
"=" |                 write_op();     //joshua
"*"    	              write_op();
"//".*     			write_inline(); //joshua
"/*"([^*]|(\*+[^*/]))*\*+"/"      	write_comment(); //joshua
"#"(define|include)[ \t]+.*    	write_directive();   //joshua
.				printf("unrecognized input at line %d", yylineno);

%%


int main() {
    myInit();
    printf("<html><pre>\n");
    yylex();
    printf("\n</pre></html>\n");
    return 0;
}

void write_indent() {
    printf("\n%-*d", column, line++);
}

void write_html_char(int c) {
    switch (c) {
	case '<':
	    printf("&lt;");
	    break;
	case '>':
	    printf("&gt;");
	    break;
	case '"':
	    printf("&quot;"); //joshua
	    break;
	case '&':
	    printf("&amp;"); //joshua
	    break;
	case '\n':
	    if (inComment) {
		printf("\n%-*d", column, line++);
	    }
	    break;
	default:
	    putchar(c);
    }
}

void write_html() {
    char *s = yytext;

    while (*s) {
	write_html_char(*s++);
    }
}

void write_char() {
    if (debug) {
	fprintf(stderr, "write_char: %s\n", yytext);
    }
    printf("<u><font color='brown'>");
    write_html();
    printf("</font></u> ");
}

void write_string() {
      if (debug) {
        fprintf(stderr, "write_string: %s\n", yytext);
    }
    printf("<font color='red'>\"");
    write_html();
    printf("\"</font> ");
    //joshua 
}

void write_oct() {
    if (debug) {
        fprintf(stderr, "write_oct: %s\n", yytext);
    }
    printf("<i><font color='brown'>");
    write_html();
    printf("</font></i> ");
    //joshua
}

void write_hex() {
        if (debug) {
        fprintf(stderr, "write_hex: %s\n", yytext);
    }
    printf("<i><font color='brown'>");
    write_html();
    printf("</font></i> ");
}


void write_int() {
     if (debug) {
        fprintf(stderr, "write_int: %s\n", yytext);
    }
    printf("<font color='brown'>");
    write_html();
    printf("</font> ");
    //joshua
}

void write_fp() {
    if (debug) {
        fprintf(stderr, "write_fp: %s\n", yytext);
    }
    printf("<font color='brown'>");
    write_html();
    printf("</font> ");
    //joshua
}

void write_id() {
    int kw = FALSE;
    int id = lookupVar_index(yytext);

    if (id == -2) {
	// this is the first time we've seen this ID
	installID(yytext, ID, line);
	printf("<a name='%s'>", yytext);
    } else if (id >= 0) {
	printf("<a href='#%s'>", yytext);
    } else {
    	// it's a keyword
	printf("<b>");
	kw = TRUE;
    }
    if (debug) {
	fprintf(stderr, "write_id: %s; kw = %d\n", yytext, kw);
    }

    printf("<font color='blue'>");
    write_html();
    printf("</font>");

    if (kw)  {
	printf("</b> ");
    } else {
	printf("</a>");
    }
}

void
write_begin() {
    putchar(' ');
    write_html();
    write_indent();
    column += INDENT;
    write_indent();
}

void
write_end() {
    column -= INDENT;
    write_indent();
    write_html();
    write_indent();
    //joshua
}

void
write_open() {
    write_html();
    paren++;
}

void
write_close() {
    write_html();
    paren--;
    //joshua
}

void
write_bopen() {
    write_html();
    paren++;
}

void
write_bclose() {
    write_html();  
    paren--;       // Decreases the `paren` counter, if it's used to track nesting
                    //joshua
}

void
write_sep() {
    if (debug) {
	fprintf(stderr, "write_sep: %s\n", yytext);
    }
    write_html();
    if (!paren) {
	write_indent();
    } else  {
	putchar(' ');
    }
}

void
write_op() {
    if (debug) {
	fprintf(stderr, "write_op: %s\n", yytext);
    }
    putchar(' ');
    printf("<b>");
    write_html();
    printf("</b> ");
    putchar(' ');
}

void
write_inline() {
    if (debug) {
        fprintf(stderr, "write_inline: %s\n", yytext);
    }
    printf("<font color='green'>");
    write_html();
    printf("</font>");
    write_indent();
    //joshua
}

void
write_comment() {
    if (debug) {
	fprintf(stderr, "write_comment: %s\n", yytext);
    }
    inComment = TRUE;
    printf("<font color='green'>");
    write_html();
    printf("</font>");
    write_indent();
    inComment = FALSE;
}

void
write_directive() {
    if (debug) {
        fprintf(stderr, "write_directive: %s\n", yytext);
    }
    printf("<b><font color='magenta'>");
    write_html();
    printf("</font></b>");
    write_indent();
    //joshua
}

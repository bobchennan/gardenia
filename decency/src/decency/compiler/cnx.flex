package decency.compiler;

import java.io.*;

%%

%unicode
%line
%column
%cup
%implements Symbols

%{
	private boolean commentCount = false;
	private boolean isString = false;
	private StringBuffer str = new StringBuffer();

	private void err(String message) {
		System.out.println("Scanning error in line " + yyline + ", column " + yycolumn + ": " + message);
	}

	private java_cup.runtime.Symbol tok(int kind) {
		return new java_cup.runtime.Symbol(kind, yyline, yycolumn);
	}

	private java_cup.runtime.Symbol tok(int kind, Object value) {
		return new java_cup.runtime.Symbol(kind, yyline, yycolumn, value);
	}
%}

%eofval{
	{
		if (yystate() == YYCOMMENT) {
			err("Comment symbol do not match (EOF)!");
		}
		return tok(EOF, null);
	}
%eofval}

LineTerm = \n|\r|\r\n
Identifier = [a-zA-Z_$][a-zA-Z0-9_$]*
DecInteger = [0-9]+|0[xX][a-zA-Z0-9]+
Whitespace = {LineTerm}|[ \t\f]

%state	YYCOMMENT
%state  YYPRE

%%

<YYINITIAL> {
	"/*" { commentCount = true; yybegin(YYCOMMENT); }
	"*/" { err("Comment symbol do not match!"); }
	\#   {yybegin(YYPRE);}
	"//" {yybegin(YYPRE);}
	

	"int" { /*System.out.println(yytext());*/return tok(INT); }
	"while" { /*System.out.println(yytext());*/return tok(WHILE); }
	"for" { /*System.out.println(yytext());*/return tok(FOR); }
	"return" { /*System.out.println(yytext());*/return tok(RETURN); }
	
	"(" { /*System.out.println(yytext());*/return tok(LPAREN); }
	")" { /*System.out.println(yytext());*/return tok(RPAREN); }
	";" { /*System.out.println(yytext());*/return tok(SEMICOLON); }
	"," { /*System.out.println(yytext());*/return tok(COMMA); }
	"=" { /*System.out.println(yytext());*/return tok(ASSIGN); }
	"{" { /*System.out.println(yytext());*/return tok(LBRACE); }
	"}" { /*System.out.println(yytext());*/return tok(RBRACE); }
	"[" { /*System.out.println(yytext());*/return tok(LBRACK); }
	"]" { /*System.out.println(yytext());*/return tok(RBRACK); }
	"<"  { /*System.out.println(yytext());*/return tok(LT); }
	">"  { /*System.out.println(yytext());*/return tok(GT); }
	"+" { /*System.out.println(yytext());*/return tok(PLUS); }
	"-" { /*System.out.println(yytext());*/return tok(MINUS);}
	"*" { /*System.out.println(yytext());*/return tok(ASTER); }
	"++" { /*System.out.println(yytext());*/return tok(INC); }
	"--" { /*System.out.println(yytext());*/return tok(DEC); }
	"*=" { /*System.out.println(yytext());*/return tok(MULASS); }
	"+=" { /*System.out.println(yytext());*/return tok(ADDASS); }
    "-=" { /*System.out.println(yytext());*/return tok(SUBASS); }
    {Identifier} 
	{
		return tok(ID,yytext());
	}
	{DecInteger} { /*System.out.println(yytext());*/return tok(NUM, new Integer(yytext())); }
	{Whitespace} { /* skip */ }

	[^] {throw new RuntimeException("Illegal character " + yytext() + " in line " + (yyline + 1) + ", column " + (yycolumn + 1)); }
}

<YYCOMMENT> {
	"/*" { commentCount=true; }
	"*/" { if (commentCount == true) {commentCount=false;yybegin(YYINITIAL);} }
	[^]  {}
}
<YYPRE>{
    \n {yybegin(YYINITIAL);}
    [^] {}
}

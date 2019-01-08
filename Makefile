CC = gcc
PP = g++
LEX = flex
YACC = bison

all: minic Ucodei

minic: parser.y parser.l parser_ast.h minic.c minic.h
			$(YACC) -d parser.y
			$(LEX) parser.l
			$(CC) -o minic lex.yy.c parser.tab.c minic.c

Ucodei: Ucodei.cpp
			$(PP) -o ucode Ucodei.cpp

clean : 
			@rm -rf lex.yy.c *.tab.* minic *.ast *.uco ucode *.lst

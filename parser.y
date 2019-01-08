%{   
    #include <stdio.h>
    #include <string.h>
    #include "parser_ast.h"

    extern FILE *yyin;

    int yylex();
    void yyerror(const char *s);
    Node* root;
	void codeGen(Node *ptr, FILE *ucoFile);
%}

%union {
    struct nodeType *ast;
    int ival;
    char* string;
}

 
%token tconst telse tif tint treturn tvoid twhile tequal
	tnotequ tlesse tgreate tand tor tinc tdec taddAssign
	tsubAssign tmulAssign tdivAssign tmodAssign
%token <string> tident tnumber
%type <ast> function_def translation_unit external_dcl function_name function_header compound_st
    dcl_spec formal_param opt_dcl_list declaration_list declaration dcl_specifiers dcl_specifier
    type_specifier type_qualifier opt_formal_param formal_param_list param_dcl init_dcl_list init_declarator
    declarator opt_number opt_stat_list statement_list statement expression_st opt_expression if_st
    while_st return_st expression assignment_exp actual_param actual_param_list unary_exp postfix_exp primary_exp
    logical_or_exp logical_and_exp equality_exp relational_exp additive_exp multiplicative_exp opt_actual_param

%%

mini_c           : translation_unit			{ root = buildTree(PROGRAM, $1); };

translation_unit : external_dcl				{ $$ = $1; }
                 | translation_unit external_dcl	{ appendNext($1, $2); $$ = $1; };  
       
external_dcl     : function_def				{$$ = $1;}
                 | declaration				{$$ = $1;}; 
         
function_def     : function_header compound_st		{appendNext($1, $2); $$ = buildTree(FUNC_DEF, $1);};

function_header  : dcl_spec function_name formal_param	{appendNext($1, $2); appendNext($2, $3); $$ = buildTree(FUNC_HEAD, $1);};

dcl_spec         : dcl_specifiers 			{$$ = buildTree(DCL_SPEC, $1);};

dcl_specifiers   : dcl_specifier			{$$ = $1;}
                 | dcl_specifiers dcl_specifier		{appendNext($1, $2); $$ = $1;} ;          

dcl_specifier    : type_qualifier			{$$ = $1;}
                 | type_specifier			{$$ = $1;};                           

type_qualifier   : tconst				{$$ = buildTree(CONST_NODE, NULL);};

type_specifier   : tint					{$$ = buildTree(INT_NODE, NULL);}
                 | tvoid				{$$ = buildTree(VOID_NODE, NULL);};

function_name    : tident				{ $$ = buildNode(IDENT, $1); };

formal_param     : '(' opt_formal_param ')'		{$$ = buildTree(FORMAL_PARA, $2);};

opt_formal_param : formal_param_list			{$$ = $1;}
                 |					{ $$ = NULL;};

formal_param_list: param_dcl 				{$$ = $1;}
                 | formal_param_list ',' param_dcl	{appendNext($1, $3);  $$ = $1;};

param_dcl        : dcl_spec declarator			{appendNext($1, $2); $$ = buildTree(PARAM_DCL, $1);} ;

compound_st      : '{' opt_dcl_list opt_stat_list '}'	{appendNext($2, $3); $$ = buildTree(COMPOUND_ST, $2);};

opt_dcl_list     : declaration_list			{$$ = buildTree(DCL_LIST, $1);}
                 |					{$$ = buildTree(DCL_LIST, NULL);};

declaration_list : declaration				{ $$ = $1;}
                 | declaration_list declaration		{appendNext($1, $2); $$ = $1;};

declaration      : dcl_spec init_dcl_list ';'		{appendNext($1, $2); $$ = buildTree(DCL, $1);}; 

init_dcl_list    : init_declarator			{ $$ = $1;}
                 | init_dcl_list ',' init_declarator	{appendNext($1, $3); $$ = $1;};

init_declarator  : declarator				{   $$ = $1;}
                 | declarator '=' tnumber		{appendNext($1->son, buildNode(IDENT, $3)); $$ = $1;};

declarator       : tident				{Node* ptr = buildTree(SIMPLE_VAR, buildNode(IDENT, $1)); $$ = buildTree(DCL_ITEM, ptr);};
                 | tident '[' opt_number ']'		{Node* ptr = buildNode(IDENT, $1); appendNext(ptr, $3); $$ = buildTree(DCL_ITEM, buildTree(ARRAY_VAR, ptr));};

opt_number       : tnumber				{$$ = buildNode(NUMBER, $1);};   
                 |					{$$ = NULL;};

opt_stat_list    : statement_list			{$$ = buildTree(STAT_LIST, $1);}
                 |					{$$ = NULL; };

statement_list   : statement				{ $$ = $1;}
                 | statement_list statement		{appendNext($1, $2); $$ = $1;};

statement        : compound_st				{$$ = $1; }
                 | expression_st			{$$ = $1; }
                 | if_st				{$$ = $1; }
                 | while_st 				{$$ = $1; }
                 | return_st 				{$$ = $1; };

expression_st    : opt_expression ';'			{$$ = buildTree(EXP_ST, $1);} ;

opt_expression   : expression 				{ $$ = $1;}
                 |					{ $$ = NULL;};

if_st            : tif '(' expression ')' statement	{appendNext($3, $5); $$ = buildTree(IF_ST, $3);}
                 | tif '(' expression ')' statement telse statement	{appendNext($3, $5); appendNext($5, $7); $$ = buildTree(IF_ELSE_ST, $3);};

while_st         : twhile '(' expression ')' statement	{appendNext($3, $5); $$ = buildTree(WHILE_ST, $3);};

return_st        : treturn opt_expression ';'		{ $$ = buildTree(RETURN_ST, $2);};

expression       : assignment_exp			{$$ = $1;}; 

assignment_exp   : logical_or_exp			{$$ = $1;}
                 | unary_exp '=' assignment_exp		{appendNext($1, $3); $$ = buildTree(ASSIGN_OP, $1);}  
                 | unary_exp taddAssign assignment_exp	{appendNext($1, $3); $$ = buildTree(ADD_ASSIGN, $1);}
                 | unary_exp tsubAssign assignment_exp	{appendNext($1, $3); $$ = buildTree(SUB_ASSIGN, $1);}
                 | unary_exp tmulAssign assignment_exp	{appendNext($1, $3); $$ = buildTree(MUL_ASSIGN, $1);}
                 | unary_exp tdivAssign assignment_exp	{appendNext($1, $3); $$ = buildTree(DIV_ASSIGN, $1);}
                 | unary_exp tmodAssign assignment_exp	{appendNext($1, $3); $$ = buildTree(MOD_ASSIGN, $1);} ;

logical_or_exp   : logical_and_exp			{$$ = $1;}
                 | logical_or_exp tor logical_and_exp	{appendNext($1, $3); $$ = buildTree(LOGICAL_OR, $1);};

logical_and_exp  : equality_exp 			{$$ = $1; }
                 | logical_and_exp tand equality_exp	{appendNext($1, $3); $$ = buildTree(LOGICAL_AND, $1);};

equality_exp     : relational_exp			{$$ = $1; }
                 | equality_exp tequal relational_exp	{appendNext($1, $3); $$ = buildTree(EQ, $1);}
                 | equality_exp tnotequ relational_exp	{appendNext($1, $3); $$ = buildTree(NE, $1);};

relational_exp   : additive_exp				{$$ = $1; }
                 | relational_exp '>' additive_exp 	{appendNext($1, $3); $$ = buildTree(GT, $1);} 
                 | relational_exp '<' additive_exp	{appendNext($1, $3); $$ = buildTree(LT, $1);}
                 | relational_exp tgreate additive_exp	{appendNext($1, $3); $$ = buildTree(GE, $1);}
                 | relational_exp tlesse additive_exp	{appendNext($1, $3); $$ = buildTree(LE, $1);};
	
additive_exp     : multiplicative_exp          		{$$ = $1; }
                 | additive_exp '+' multiplicative_exp	{appendNext($1, $3); $$ = buildTree(ADD, $1);}
                 | additive_exp '-' multiplicative_exp	{appendNext($1, $3); $$ = buildTree(SUB, $1);};

multiplicative_exp : unary_exp				{$$ = $1;}
                   | multiplicative_exp '*' unary_exp	{appendNext($1, $3); $$ = buildTree(MUL, $1);}
                   | multiplicative_exp '/' unary_exp	{appendNext($1, $3); $$ = buildTree(DIV, $1);}
                   | multiplicative_exp '%' unary_exp	{appendNext($1, $3); $$ = buildTree(MOD, $1);};

unary_exp          : postfix_exp 			{$$ = $1;}
                   | '-' unary_exp			{$$ = buildTree(UNARY_MINUS, $2);}
                   | '!' unary_exp			{$$ = buildTree(LOGICAL_NOT, $2);}
                   | tinc unary_exp 			{$$ = buildTree(PRE_INC, $2);}
                   | tdec unary_exp			{$$ = buildTree(PRE_DEC, $2);};

postfix_exp        : primary_exp			{$$ = $1;}
                   | postfix_exp '[' expression ']'	{appendNext($1, $3); $$ = buildTree(INDEX, $1);}
                   | postfix_exp '(' opt_actual_param ')'	{appendNext($1, $3); $$ = buildTree(CALL, $1);}
                   | postfix_exp tinc 			{$$ = buildTree(POST_INC, $1);}
                   | postfix_exp tdec			{$$ = buildTree(POST_DEC, $1);};

opt_actual_param   : actual_param			{$$ = $1;}
                   |					{$$ = NULL; };

actual_param       : actual_param_list 			{$$ = buildTree(ACTUAL_PARAM, $1);};

actual_param_list  : assignment_exp			{$$ = $1;}
                   | actual_param_list ',' assignment_exp	{appendNext($1, $3); $$ = $1;};

primary_exp        : tident				{$$ = buildNode(IDENT, $1);}
                   | tnumber                            {$$ = buildNode(NUMBER, $1);}
                   | '(' expression ')'			{ $$ = $2;};
%%

void yyerror(const char *s)
{
	printf("%s\n", s);
	exit(1);
}

char* toString(char* string)
{
    char* str;
    str = (char*)malloc(strlen(string) + 1);
    strcpy(str, string);
    return str;
}

Node* parse(FILE *sourceFile)
{
    yyin = sourceFile;
    do{
        yyparse();
    } while(!feof(yyin));

    return root;
}

int main(int argc, char *argv[])
{
	Node * root;
	FILE *mcFile;
	FILE *astFile, *ucoFile;

	char filename[100];
	if(argc != 2) {
		fprintf(stderr, "Arguments not valid!");
		return -1;
	}

	strcpy(filename, argv[1]);
	mcFile = fopen(filename, "r");
	if(!mcFile) {
		fprintf(stderr, "Minic file can't open\n");
		return -1;
	}

	astFile = fopen(strcat(strtok(filename, "."), ".ast"), "w");
	if(!astFile) {
		fprintf(stderr, "Ast file can't open\n");
		return -1;
	}

	ucoFile = fopen(strcat(strtok(filename, "."), ".uco"), "w");
	if(!ucoFile) {
		fprintf(stderr, "Uco file can't open\n");
		return -1;
	}


	printf("=== Start of Parser...\n");
	root = parse(mcFile);
	printTree(root, 0, astFile);
	printf("=== End of Parser! \n Please check ast file.\n");

	printf("=== Start Code Generate...\n");
	codeGen(root, ucoFile);
	printf("=== End Code Generate! \n Please check uco file.\n");

	fclose(mcFile);
	fclose(astFile);
	fclose(ucoFile);

	return 0;

}

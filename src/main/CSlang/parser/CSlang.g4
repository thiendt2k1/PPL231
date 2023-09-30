grammar CSlang;

@lexer::header {
from lexererr import *
}

options{
	language=Python3;
}

program: main EOF ;

main: manyClsDecl;
manyClsDecl: classDecl manyClsDecl | classDecl;
classDecl: ('class' ID | inheritClsDecl) LC memList RC; //nullable
inheritClsDecl:  'class' ID '<-' ID;

memList: attr_methodDecls;
attr_methodDecls: attr_methodDecl attr_methodDecls | ;
attr_methodDecl: attributeDecl | methodDecl;

attributeDecl: ("var" | "const") (idList ":" typ | attrTail) SM;
attrTail: ID attrTail2 expr;
attrTail2: CM ID attrTail expr CM | ":" typ ASSIGN; //non nullable

// The <list of parameters> is an optional comma-separated list of parameter declarations.
// Each parameter declaration follows the format: <identifier>: <type>. When two or more
// consecutive named function parameters share a common type, you can omit the type from all
// except the last parameter in the sequence: <list of identifiers>: <type>.

methodDecl: paramH | paramLess | constructorDecl;
paramH: "func" ID LR paramDecls RR ":" retType blockStm;
paramLess: "func" ID LR RR ":" retType blockStm;

paramDecls: paramDecl CM paramDecls | paramDecl;
paramDecl: idList ":" typ | paramDeclT;
paramDeclT: ID ":" typ paramDeclT2;
paramDeclT2: CM ID ":" typ | paramDeclT; //something not right here

constructorDecl: "func" "constructor" LR paramDecls RR blockStm;
//  In the constructor, class attributes are preferred to be used on the left-hand side of an
// expression. This means that when there are parameters with the same name as the class
// attribute, the class attribute is used as expression on the left-hand side -> not done



LC: '{';
RC: '}';
LB: '[';
RB: ']';
LR: '(';
RR:  ')';
// Each class declaration starts with the keyword class, followed by an optional super part, an
// identifier (which is the class name), and ends with a nullable list of members enclosed within
// a pair of curly parentheses. The super part begins with an identifier (which is the super class
// name of the declared class, followed by



WS : [ \t\r\n]+ -> skip ; // skip spaces, tabs, newlines

BLOCKCMT: '/*' .*? '*/' -> skip;
// LINECMT: '//' .*? EOL -> skip; //something not right here

// skip program comment

//keyword
BREAK_: "break";
CONT: "continue"; 
IF_: "if";
ELSE_: "else";
FOR_: "for";
TRUE_: "true";
FALSE_: "false";
INT_: "int";
FLOAT_: "float"; 
BOOL_: "bool";
STR_: "string";
RET_: "return";
NULL_: "null";
CLASS_: "class";
CONSTRUCTOR_: "constructor";
VAR_: "var";
CONST_: "const";
NEW_: "new";
VOID_: "void";
SELF_: "self";
FUNC_: "func";

ID: [_A-Za-z][_A-Za-z0-9]+;
STATIC_ID: '@' [_A-Za-z][_A-Za-z0-9]+;

ILLEGAL_ESCAPE:
	'"' CHAR* '\\' ~('b' | 'f' | 'r' | 'n' | 't' | '\'' | '\\') {
	raise IllegalEscape(str(self.text[1:]))
};

UNCLOSE_STRING:
	'"' CHAR* ('\b' | '\f' | '\r' | '\n' | '\t' | '\\' | EOF) {
	illegal_escape_list = ['\b', '\f', '\r', '\n', '\t', '\\'];
	target_str = str(self.text)
	if target_str[-1] in illegal_escape_list:
		raise UncloseString(str(self.text[1:-1]))
	else:
		raise UncloseString(str(self.text[1:]))
};

ERROR_CHAR: .{raise ErrorToken(self.text)};
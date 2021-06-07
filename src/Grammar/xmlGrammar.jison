/* description: Parses end executes mathematical expressions. */

%{
    const {Objeto} = require("../xmlAST/Objeto");
    const {Atributo} = require("../xmlAST/Atributo");
    var texto = "";
%}

/* lexical grammar */
%lex
%options case-insensitive


%%
\s+                                         /* skip whitespace */

[<][!][-][-][^-<]*[-][-][>]                 /*skip comments*/

"<"                                         return '<';
">"                                         return '>';
"/"                                         return '/';
"="                                         return '=';
"?"                                         return '?';

(\"([^\"\\])*\")                            return 'dstring';
(\'([^\'\\])*\')                            return 'sstring';
[a-zA-Z_][a-zA-Z0-9_ñÑ]*                    return 'id';
(([0-9]+"."[0-9]+)|("."[0-9]+)|([0-9]+))    return 'number';


[^<> ]+                                     return 'random';

<<EOF>>               return 'EOF';

//error lexico
.                                   {
                                        console.log('Este es un error léxico: ' + yytext + ', en la linea: ' + yylloc.first_line + ', en la columna: ' + yylloc.first_column);
                                    }

/lex

/* operator associations and precedence */

/*%left '+' '-'
%left '*' '/'
%left '^'
%left UMINUS*/

%start init

%% /* language grammar */

init
    :  '<' '?' id LISTAATRIBUTOS '?' '>' INTRO    {texto+="init -> < ? id LISTAATRIBUTOS ? > INTRO\n";return {ast: $7,reporteGramatica: texto};}
    |  INTRO                                      {texto+="init -> INTRO\n";return {ast: $1,reporteGramatica: texto};}
    ;

INTRO   :  INTRO NODO EOF           {texto+="INTRO -> INTRO NODO EOF\n";$1.push($2); $$ = $1; }
        |  NODO CHECK               {texto+="INTRO -> NODO CHECK\n";$$ = [$1]; }
    ;

CHECK
    : EOF               {texto+="CHECK -> EOF\n";}
    |                   {texto+="CHECK -> ε\n";}
    ;

NODO
    :    '<' id LISTAATRIBUTOS '>' LISTANODOS '<' '/' id '>'    {texto+="NODO -> < id LISTAATRIBUTOS > LISTANODOS < / id >\n";$$ = new Objeto($2,'',@1.first_line, @1.first_column,$3,$5);}
    |    '<' id LISTAATRIBUTOS '>' NODOTEXTO '<' '/' id '>'     {texto+="NODO -> < id LISTAATRIBUTOS > NODOTEXTO < / id >\n";$$ = new Objeto($2,$5,@1.first_line, @1.first_column,$3,[]);}
    |    '<' id LISTAATRIBUTOS '/' '>'                          {texto+="NODO -> < id LISTAATRIBUTOS / >\n";$$ = new Objeto($2,'',@1.first_line, @1.first_column,$3,[]);}
    |    '<' id  '>' LISTANODOS '<' '/' id '>'                  {texto+="NODO -> < id > LISTANODOS < / id >\n";$$ = new Objeto($2,'',@1.first_line, @1.first_column,[],$4);}
    |    '<' id  '>' NODOTEXTO '<' '/' id '>'                   {texto+="NODO -> < id > NODOTEXTO < / id >\n";$$ = new Objeto($2,$4,@1.first_line, @1.first_column,[],[]);}
    |    '<' id  '/' '>'                                        {texto+="NODO -> < id / >\n";$$ = new Objeto($2,'',@1.first_line, @1.first_column,[],[]);}
    ;

LISTANODOS
    : LISTANODOS NODO   {texto+="LISTANODOS -> LISTANODOS NODO\n";$1.push($2); $$ = $1;}
    | NODO              {texto+="LISTANODOS -> NODO\n";$$ = [$1]; }
    ;

LISTAATRIBUTOS
    : LISTAATRIBUTOS ATRIBUTO   {texto+="LISTAATRIBUTOS -> LISTAATRIBUTOS ATRIBUTO\n";$1.push($2); $$ = $1;}
    | ATRIBUTO                  {texto+="LISTAATRIBUTOS -> ATRIBUTO\n";$$ = [$1]; }
    ;

ATRIBUTO
    : id '=' sstring    {texto+="ATRIBUTO -> id = sstring\n";$$ = new Atributo($1, $3, @1.first_line, @1.first_column); }
    | id '=' dstring    {texto+="ATRIBUTO -> id = dstring\n";$$ = new Atributo($1, $3, @1.first_line, @1.first_column); }
    ;

NODOTEXTO : NODOTEXTO dstring       {texto+="NODOTEXTO -> NODOTEXTO dstring\n";$$ = $1 +" "+ $2 }
    | NODOTEXTO sstring             {texto+="NODOTEXTO -> NODOTEXTO sstring\n";$$ = $1 +" "+ $2 }
    | NODOTEXTO id                  {texto+="NODOTEXTO -> NODOTEXTO id\n";$$ = $1 +" "+ $2 }
    | NODOTEXTO number              {texto+="NODOTEXTO -> NODOTEXTO number\n";$$ = $1 +" "+ $2 }
    | NODOTEXTO random              {texto+="NODOTEXTO -> NODOTEXTO random\n";$$ = $1 +" "+ $2 }
    | NODOTEXTO '/'                 {texto+="NODOTEXTO -> NODOTEXTO /\n";$$ = $1 +" "+ $2 }
    | NODOTEXTO '='                 {texto+="NODOTEXTO -> NODOTEXTO =\n";$$ = $1 +" "+ $2 }
    | dstring                       {texto+="NODOTEXTO -> dstring\n";$$ = $1 }
    | sstring                       {texto+="NODOTEXTO -> sstring\n";$$ = $1 }
    | id                            {texto+="NODOTEXTO -> id\n";$$ = $1 }
    | number                        {texto+="NODOTEXTO -> number\n";$$ = $1 }
    | random                        {texto+="NODOTEXTO -> random\n";$$ = $1 }
    | '/'                           {texto+="NODOTEXTO -> /\n";$$ = $1 }
    | '='                           {texto+="NODOTEXTO -> =\n";$$ = $1 }
    ;
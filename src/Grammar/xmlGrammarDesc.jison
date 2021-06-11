/* description: Parses end executes mathematical expressions. */

%{
    const {Entorno} = require("../xmlAST/Entorno");
    const {Simbolo} = require("../xmlAST/Simbolo");
    const {ClaseError} = require("../xmlAST/ClaseError");
    var listaErrores = [];
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
([a-zA-Z_]|"á"|"é"|"í"|"ó"|"ú"|"Á"|"É"|"Í"|"Ó"|"Ú")("-"|[a-zA-Z0-9_ñÑ]|"á"|"é"|"í"|"ó"|"ú"|"Á"|"É"|"Í"|"Ó"|"Ú"|"'")*            return 'id';
(([0-9]+"."[0-9]+)|("."[0-9]+)|([0-9]+))    return 'number';

"&""l""t"";"                                return 'lessthan';
"&""g""t"";"                                return 'greaterthan';
"&""a""m""p"";"                             return 'ampersand';
"&""a""p""o""s"";"                          return 'apostrophe';
"&""q""u""o""t"";"                          return 'quotmark';

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
    :  '<' '?' id LISTAATRIBUTOS '?' '>' INTRO    {
                                                    var listaErroresTemp = listaErrores;
                                                    listaErrores = [];
                                                    return {ast: $7, listaErrores : listaErroresTemp};
                                                    }
    |  INTRO                                      {
                                                    var listaErroresTemp = listaErrores;
                                                    listaErrores = [];
                                                    return {ast: $1, listaErrores : listaErroresTemp};
                                                    }
    ;

INTRO   :  NODO INTRO               {$1.push($2); $$ = $1; }
        |  NODO CHECK               {$$ = [$1]; }
    ;

CHECK
    : EOF               {}
    |                   {}
    ;

NODO
    :    '<' id LISTAATRIBUTOS '>' LISTANODOS '<' '/' id '>'    {
                                                                    if($2!==$8){listaErrores.push(new ClaseError('Semantico','La etiqueta '+$2+' no esta cerrada',@1.first_line, @1.first_column));}
                                                                    $$ = new Entorno($2,'',@1.first_line, @1.first_column,$3,$5);
                                                                }
    |    '<' id LISTAATRIBUTOS '>' NODOTEXTO '<' '/' id '>'     {
                                                                    if($2!==$8){listaErrores.push(new ClaseError('Semantico','La etiqueta '+$2+' no esta cerrada',@1.first_line, @1.first_column));}
                                                                    $$ = new Entorno($2,$5,@1.first_line, @1.first_column,$3,[]);
                                                                }
    |    '<' id LISTAATRIBUTOS '/' '>'                          {$$ = new Entorno($2,'',@1.first_line, @1.first_column,$3,[]);}
    |    '<' id  '>' LISTANODOS '<' '/' id '>'                  {
                                                                    if($2!==$7){listaErrores.push(new ClaseError('Semantico','La etiqueta '+$2+' no esta cerrada',@1.first_line, @1.first_column))}
                                                                    $$ = new Entorno($2,'',@1.first_line, @1.first_column,[],$4);
                                                                }
    |    '<' id  '>' NODOTEXTO '<' '/' id '>'                   {
                                                                    if($2!==$7){listaErrores.push(new ClaseError('Semantico','La etiqueta '+$2+' no esta cerrada',@1.first_line, @1.first_column))}
                                                                    $$ = new Entorno($2,$4,@1.first_line, @1.first_column,[],[]);
                                                                }
    |    '<' id  '/' '>'                                        {$$ = new Entorno($2,'',@1.first_line, @1.first_column,[],[]);}
    |    error FINDERROR                                        {listaErrores.push(new ClaseError('Sintactico','Se esperaba la definicion de una etiqueta',@1.first_line, @1.first_column))}
    ;

FINDERROR
    : '>' {}
    ;

LISTANODOS
    : LISTANODOS NODO   {$1.push($2); $$ = $1;}
    | NODO              {$$ = [$1]; }
    ;

LISTAATRIBUTOS
    : ATRIBUTO LISTAATRIBUTOS   {$2.push($1); $$ = $2;}
    | ATRIBUTO                  {$$ = [$1];}
    ;

ATRIBUTO
    : id '=' sstring    {$$ = new Simbolo($1, $3, @1.first_line, @1.first_column); }
    | id '=' dstring    {$$ = new Simbolo($1, $3, @1.first_line, @1.first_column); }
    ;

NODOTEXTO : dstring NODOTEXTO       {$$ = $1 +" "+ $2 }
    | sstring NODOTEXTO             {$$ = $1 +" "+ $2 }
    | id NODOTEXTO                  {$$ = $1 +" "+ $2 }
    | lessthan NODOTEXTO            {$$ = $1 +" "+ "<" }
    | greaterthan NODOTEXTO         {$$ = $1 +" "+ ">" }
    | ampersand NODOTEXTO           {$$ = $1 +" "+ "&" }
    | apostrophe NODOTEXTO          {$$ = $1 +" "+ "\'" }
    | quotmark NODOTEXTO            {$$ = $1 +" "+ "\"" }
    | number NODOTEXTO              {$$ = $1 +" "+ $2 }
    | random NODOTEXTO              {$$ = $1 +" "+ $2 }
    | '/' NODOTEXTO                 {$$ = $1 +" "+ $2 }
    | '=' NODOTEXTO                 {$$ = $1 +" "+ $2 }
    | dstring                       {$$ = $1 }
    | sstring                       {$$ = $1 }
    | id                            {$$ = $1 }
    | number                        {$$ = $1 }
    | lessthan                      {$$ = "<" }
    | greaterthan                   {$$ = ">" }
    | ampersand                     {$$ = "&" }
    | apostrophe                    {$$ = "\'" }
    | quotmark                      {$$ = "\"" }
    | random                        {$$ = $1 }
    | '/'                           {$$ = $1 }
    | '='                           {$$ = $1 }
    ;
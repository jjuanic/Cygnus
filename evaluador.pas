Unit evaluador;
{$codepage utf-8}
{$H+}
interface
uses
    crt,tipos,analizador_sintactico,analizador_lexico,math,sysUtils;
const
    maxVar = 200;
    maxReal = 200;
    maxArreglo = 100;
type
    TElemEstado = record
        lexemaid: string;
        valReal: real;
        tipo: TipoSimboloGramatical;
        valArray: array[1..maxArreglo] of real;
        cantArray: byte;
        tamanio:byte;
    end;
        
    TEstado = record   
        elem: array[1..maxVar] of TElemEstado;
        cant: integer;
    end;
    
procedure eval_programa(arbol: tapuntNodo ; var estado: testado);   
procedure eval_definiciones(arbol: tapuntNodo ; var estado: Testado);
procedure eval_definicion(arbol: TApuntNodo ; var estado: testado);
procedure eval_tipo (arbol: tapuntNodo; var estado: TEstado; var tipo: TipoSimboloGramatical;  var tam: byte);
procedure eval_cuerpo( arbol: tApuntNodo; var estado: testado);
procedure eval_Sec_cuerpo (arbol:tapuntnodo ; var estado: testado);
procedure eval_sent (arbol: tapuntNodo; var estado: TEstado);
procedure eval_asignacion (arbol:tapuntNodo; var estado: Testado);
procedure eval_post_asignacion(arbol:tapuntnodo;var estado: testado; var id: string ;var posicion:byte);
procedure eval_expArit (arbol: tapuntnodo ; var estado: testado; var resultado: real);
procedure eval_sec_ExpArit (arbol: tapuntnodo ; var estado: testado ; var op1, resultado: real);
procedure eval_opArit (arbol: tapuntnodo ; var estado: testado; var simbolo: string);
procedure eval_expArit2 (arbol: tapuntnodo ; var estado: testado; var resultado: real);
procedure eval_sec_ExpArit2 (arbol: tapuntnodo ; var estado: testado ; var op1, resultado: real);
procedure eval_opArit2 (arbol: tapuntnodo ; var estado: testado; var simbolo: string);
procedure eval_expArit3 (arbol: tapuntnodo ; var estado: testado; var resultado: real);
procedure eval_sec_ExpArit3 (arbol: tapuntnodo ; var estado: testado ; var op1, resultado: real);
procedure eval_opArit3 (arbol: tapuntnodo ; var estado: testado; var simbolo: string);
procedure eval_expArit4 (arbol: tapuntnodo ; var estado: testado ; var resultado: real);
procedure eval_indice (arbol:tapuntnodo ; var estado: testado; var posicion:byte);
procedure eval_cteArreglo(arbol: tapuntNodo; var estado: TEstado; var id:string);
procedure eval_arreglo(arbol: tapuntNodo; var estado: TEstado; var id:string; var indice:byte);
procedure eval_post_arreglo (arbol: tapuntNodo; var estado: TEstado; var id:string; var indice:byte);
procedure eval_ciclo(arbol: tapuntNodo; var estado: Testado);
procedure eval_condicional(arbol: tApuntNodo; var estado: TEstado);
procedure eval_else_condicional (arbol: tapuntnodo ; var estado: testado);
Procedure eval_expRel(arbol: TApuntNodo; var estado: TEstado; var resultado: boolean);
Procedure eval_condicion(arbol: tapuntNodo; var estado: TEstado ; var resultado1: boolean);
procedure eval_sec_condicion (arbol: tapuntnodo ; var estado: TEstado; var resultado,resultado1:boolean);
procedure eval_condicionAnidada( arbol: tapuntNodo; var estado: TEstado; var resultado1:boolean);
procedure eval_preCondicionAnidada (arbol: TApuntNodo ; var estado: TEstado; var resultado:boolean);
procedure eval_sec_condicionAnidada (arbol: tapuntnodo; var estado: testado ; var resultado,resultado1: boolean);
procedure eval_lectura(arbol: tapuntNodo; var estado: TEstado);
procedure eval_escritura(arbol: tapuntNodo ; var estado: TEstado);
procedure eval_varEscritura (arbol: tapuntNodo; var estado: TEstado);
procedure eval_post_varEscritura (arbol:tapuntnodo ; var estado: testado);
Procedure InicializarEst(var Estado:TEstado);
procedure AgregarEstado (var Estado: TEstado ; X: TElemEstado);
procedure CrearVariable(var estado: TEstado;  lexema: string; tipo : tipoSimboloGramatical);
function valorDe (var estado: TEstado; lexema:string; indice:byte):real;
procedure asignarValor (lexema:string; var estado: testado; indice:byte; valor:real);
procedure asignarValorUltPosicion (lexema:string ; var estado:testado; var valor:real);
procedure crearArray(var estado: TEstado;  lexema: string; tipo : tipoSimboloGramatical; tam : integer);

implementation
// <programa> ::= “program” “id” “var” <definiciones> “body” “{“ <cuerpo> “}”     
    procedure eval_programa(arbol: tapuntNodo ; var estado: testado);   
    begin
      InicializarEst(estado);
      eval_definiciones(arbol^.hijos.elem[4], estado);
      eval_cuerpo(arbol^.hijos.elem[7],estado);
    end;
        
// <definiciones> ::= <definicion>”;”<definiciones> | epsilon 
    procedure eval_definiciones(arbol: tapuntNodo ; var estado: Testado);
    begin
        if arbol^.hijos.cant <> 0 then // si la prod no es epsilon
          begin
            eval_definicion(arbol^.hijos.elem[1],estado);
            eval_definiciones(arbol^.hijos.elem[3],estado);
        end;
    end;
    
// <definicion> ::= “id” “=” <tipo>
    procedure eval_definicion(arbol: TApuntNodo ; var estado: testado);
    var
    tipo:TipoSimboloGramatical;
    tam:byte;
    begin
        eval_tipo(arbol^.hijos.elem[3], estado, tipo, tam);
        if tipo = tarray then crearArray(estado,arbol^.hijos.elem[1]^.lexema,tipo,tam)
        else crearVariable(estado,arbol^.hijos.elem[1]^.lexema,tipo);
    end;

// <tipo> ::= “real” | “array” ”[“ ”cteReal” ”]” 
    procedure eval_tipo (arbol: tapuntNodo; var estado: TEstado; var tipo: TipoSimboloGramatical;  var tam: byte);
    var
    str: string;
    begin
        if arbol^.Hijos.elem[1]^.Simbolo = treal then
          begin
            tipo:= treal;
            tam:= 0;
          end
          else
          begin
            tipo:= tarray;
            str:= StringReplace(arbol^.hijos.elem[3]^.lexema, '.', ',', [rfReplaceAll]);   
            tam:= Ceil(StrToFloat(str));  
          end;
    end;

// <cuerpo> ::= <sent> <sec_cuerpo>
    procedure eval_cuerpo( arbol: tApuntNodo; var estado: testado);
    begin
        eval_sent(arbol^.hijos.elem[1], estado);
        eval_sec_cuerpo(arbol^.hijos.elem[2], estado);
    end;

// <sec_cuerpo> ::= <sent> <sec_cuerpo> | epsilon
procedure eval_Sec_cuerpo (arbol:tapuntnodo ; var estado: testado);
begin
  if arbol^.hijos.cant <> 0 then
      begin
        eval_sent(arbol^.hijos.elem[1],estado);
        eval_sec_cuerpo(arbol^.hijos.elem[2],estado);
      end;
end;
    
// <sent> ::= <asignacion> ”;” | <ciclo> | <condicional> | <lectura>”;” | <escritura>”;”
procedure eval_sent (arbol: tapuntNodo; var estado: TEstado);
    begin
        case (arbol^.Hijos.elem[1]^.Simbolo) of
        vasignacion : eval_asignacion(arbol^.hijos.elem[1], estado);
        vciclo: eval_ciclo(arbol^.hijos.elem[1], estado);
        vcondicional: eval_condicional(arbol^.hijos.elem[1], estado);
        vlectura: eval_lectura(arbol^.hijos.elem[1], estado);
        vescritura: eval_escritura(arbol^.hijos.elem[1], estado);
        end;
        end;

//<asignacion> ::= “id”<indice> “=” <post_asignacion> 
procedure eval_asignacion (arbol:tapuntNodo; var estado: Testado);
    var
    posicion: byte; 
    begin
        eval_indice(arbol^.hijos.elem[2],estado,posicion);
        eval_post_asignacion(arbol^.hijos.elem[4], estado,arbol^.hijos.elem[1]^.lexema, posicion);
    end;

// <post_asignacion> ::= <expArit> | <cteArreglo>
    procedure eval_post_asignacion(arbol:tapuntnodo;var estado: testado; var id: string ;var posicion:byte);
    var
    resultado:real;
    begin
    if arbol^.hijos.elem[1]^.simbolo = vexpArit then 
    begin
    eval_expArit(arbol^.hijos.elem[1],estado, resultado);
    asignarValor(id,estado,posicion,resultado);
    end
    else
    begin
    eval_cteArreglo(arbol^.hijos.elem[1],estado, id);
    end;
    end;
    
// <ExpArit> ::= <ExpArit2> <sec_ExpArit>
    procedure eval_expArit (arbol: tapuntnodo ; var estado: testado; var resultado: real);
    var
    op: real;
    begin
        eval_expArit2(arbol^.hijos.elem[1],estado,op);
        eval_sec_expArit(arbol^.hijos.elem[2],estado,op,resultado);
    end;

// <sec_ExpArit> ::= <opArit> <ExpArit2> <sec_ExpArit> | epsilon
    procedure eval_sec_ExpArit (arbol: tapuntnodo ; var estado: testado ; var op1, resultado: real);
    var
    op:real;
    simbolo:string;
    begin
        if arbol^.hijos.cant = 0 then resultado := op1
        else begin
        eval_opArit(arbol^.hijos.elem[1],estado,simbolo);
        eval_expArit2(arbol^.hijos.elem[2],estado, op);
        case simbolo Of
        '+': op := op1 + op;
        '-': op := op1 - op;
        end;
        eval_sec_ExpArit(arbol^.hijos.elem[3], estado, op, resultado);
    end;
    end;

// <opArit> ::= “+” | “-”
    procedure eval_opArit (arbol: tapuntnodo ; var estado: testado; var simbolo: string);
    begin
       if Arbol^.Hijos.elem[1]^.Lexema = '+' then Simbolo := '+'
        else Simbolo := '-';
    end;

// <ExpArit2> ::=  <ExpArit3> <sec_ExpArit2>
procedure eval_expArit2 (arbol: tapuntnodo ; var estado: testado; var resultado: real);
    var
    op: real;
    begin
        eval_expArit3(arbol^.hijos.elem[1],estado,op);
        eval_sec_expArit2(arbol^.hijos.elem[2],estado,op,resultado);
    end;

// <sec_ExpArit2> ::= <opArit2> <ExpArit3> <sec_ExpArit2> | epsilon

    procedure eval_sec_ExpArit2 (arbol: tapuntnodo ; var estado: testado ; var op1, resultado: real);
    var
    op:real;
    simbolo: string;
    begin
        if arbol^.hijos.cant = 0 then resultado := op1
        else begin
        eval_opArit2(arbol^.hijos.elem[1],estado,simbolo);
        eval_expArit3(arbol^.hijos.elem[2],estado, op);
        case simbolo Of
        '*': op := op1 * op;
        '/': op := op1 / op;
        end;
        eval_sec_ExpArit2(arbol^.hijos.elem[3], estado, op, resultado);
    end;
    end;

// <opArit2> ::= “*” | “/”
    procedure eval_opArit2 (arbol: tapuntnodo ; var estado: testado; var simbolo: string);
    begin
       if Arbol^.Hijos.elem[1]^.Lexema = '*' then Simbolo := '*'
        else Simbolo := '/';
    end;

// <ExpArit3> ::= <ExpArit4> <sec_ExpArit3>
procedure eval_expArit3 (arbol: tapuntnodo ; var estado: testado; var resultado: real);
    var
    op: real;
    begin
        eval_expArit4(arbol^.hijos.elem[1],estado,op);
        eval_sec_expArit3(arbol^.hijos.elem[2],estado,op,resultado);
    end;


// <sec_ExpArit3> ::= <opArit3> <ExpArit4> <sec_ExpArit3> | epsilon

    procedure eval_sec_ExpArit3 (arbol: tapuntnodo ; var estado: testado ; var op1, resultado: real);
    var
    simbolo:string;
    op: real;
    begin
        if arbol^.hijos.cant = 0 then resultado := op1
        else begin
        eval_opArit3(arbol^.hijos.elem[1],estado,simbolo);
        eval_expArit4(arbol^.hijos.elem[2],estado, op);
        case simbolo Of  
        '^': op := power(op1,op); // Exp(b*Ln(a)) ->  SI ANDA AL REVÉS, INVERTIR OP1 POR OP
        'root': op := Exp((1/op1)*Ln(op)); // Exp((1/b)*Ln(a)) ->  SI ANDA AL REVÉS, INVERTIR OP1 POR OP
        end;
        eval_sec_ExpArit3(arbol^.hijos.elem[3], estado, op, resultado);
    end;
    end;

// <opArit3> ::= “^” | “root”
    procedure eval_opArit3 (arbol: tapuntnodo ; var estado: testado; var simbolo: string);
    begin
       if Arbol^.Hijos.elem[1]^.Lexema = '^' then Simbolo := '^'
        else Simbolo := 'root';
    end;

// <ExpArit4> ::= “id” <indice>| “(“<ExpArit>”)” | “cteReal” | "-"<ExpArit4>
    procedure eval_expArit4 (arbol: tapuntnodo ; var estado: testado ; var resultado: real);
    var
    posicion:byte;
    str:string;
    begin
    case (arbol^.Hijos.elem[1]^.Simbolo) of
        tid: 
        begin
          eval_indice(arbol^.hijos.elem[2],estado,posicion); // si la posición es 0, valorDe devuelve valor de variable
          resultado:= valorDe(estado,arbol^.hijos.elem[1]^.lexema,posicion)
        end;
        tparab: eval_expArit(arbol^.hijos.elem[2], estado,resultado);
        tcteReal: 
        begin
          str:= StringReplace(arbol^.hijos.elem[1]^.lexema, '.', ',', [rfReplaceAll]);   
          resultado:= StrToFloat(str);
        end;
        tresta: 
        begin
          eval_expArit4(arbol^.hijos.elem[2], estado,resultado);
          resultado:= resultado *-1;
        end;
    end;
    end;

// <indice> ::= “[“<expArit>”]” | epsilon 
procedure eval_indice (arbol:tapuntnodo ; var estado: testado; var posicion:byte);
var
resultado:Real;
begin
    if arbol^.hijos.cant <> 0 then
    begin
    eval_exparit(arbol^.hijos.elem[2], estado,resultado);
    posicion:= ceil(resultado);
    end
    else
    begin
      posicion:=0;
    end;
end;

// <cteArreglo> ::= “[“<arreglo>”]”

procedure eval_cteArreglo(arbol: tapuntNodo; var estado: TEstado; var id:string);
var
indice : byte;
    begin
    indice:=0;
    eval_arreglo(arbol^.hijos.elem[2], estado,id,indice);
    end;

// <arreglo> ::= “cteReal” <post_arreglo>   
    procedure eval_arreglo(arbol: tapuntNodo; var estado: TEstado; var id:string; var indice:byte);
    var
    valor:real;
    str:string;
        begin
            str:= StringReplace(arbol^.hijos.elem[1]^.lexema, '.', ',', [rfReplaceAll]);  
            valor:= StrToFloat(str);
            inc(indice);
            asignarValor(id,estado,indice,valor);
            
            eval_post_arreglo(arbol^.hijos.elem[2], estado, id,indice);
        end;
        

// <post_arreglo> := ”,”<arreglo> | epsilon 
    procedure eval_post_arreglo (arbol: tapuntNodo; var estado: TEstado; var id:string; var indice:byte);
        begin
         if arbol^.hijos.cant <> 0 then
         eval_arreglo(arbol^.hijos.elem[2], estado,id,indice);
        end;

// <ciclo> ::= “while” <condicion> “:” “{“ <cuerpo> “}” | “for” “id” “=” <expArit> “to” <expArit> “:” “{“ <cuerpo> “}” 
procedure eval_ciclo(arbol: tapuntNodo; var estado: Testado);
var
resultadoWhile:boolean;
resultado1,resultado2:real;
res1,res2,i: integer;
    begin
        if arbol^.hijos.elem[1]^.Simbolo = twhile then
        begin
            eval_condicion(arbol^.hijos.elem[2], estado,resultadoWhile);
            while resultadoWhile do
            begin
              eval_cuerpo(arbol^.hijos.elem[5], estado);
              eval_condicion(arbol^.hijos.elem[2],estado,resultadoWhile);
            end;
        end
        else
        begin
            eval_expArit(arbol^.hijos.elem[4], estado,resultado1);
            eval_expArit(arbol^.hijos.elem[6], estado,resultado2);
            res1:= ceil(resultado1); res2:= ceil(resultado2);
            for i := res1 to res2 do
            begin
              asignarValor(arbol^.hijos.elem[2]^.lexema,estado,0,i);
              eval_cuerpo(arbol^.hijos.elem[9],estado);
              end;
        end;
    end;

// <condicional>::= “if” <condicion> “:” “{“ <cuerpo> “}” <else_condicional> 
procedure eval_condicional(arbol: tApuntNodo; var estado: TEstado);
var
resultado : boolean;
begin
    eval_condicion(arbol^.hijos.elem[2],estado,resultado);
    if resultado = True then
      eval_cuerpo(arbol^.hijos.elem[5],estado) 
      else eval_else_condicional(arbol^.hijos.elem[7],estado);
    
end;

// <else_condicional> ::= “else” “{“ <cuerpo> ”}” | epsilon
procedure eval_else_condicional (arbol: tapuntnodo ; var estado: testado);
begin
  if arbol^.hijos.cant <> 0 then eval_cuerpo(arbol^.hijos.elem[3],estado);
end;

// <expRel> ::= <expArit> “opRel”  <expArit>
Procedure eval_expRel(arbol: TApuntNodo; var estado: TEstado; var resultado: boolean);
var
resultado1,resultado2:real;
    begin
        eval_expArit(arbol^.hijos.elem[1], estado,resultado1);
        eval_expArit(arbol^.hijos.elem[3], estado,resultado2);

        case (arbol^.Hijos.elem[2]^.lexema) of 
            '<=' : resultado := resultado1 <= resultado2;
            '>=' : resultado := resultado1 >= resultado2;
            '>' : resultado := resultado1 > resultado2;
            '<' : resultado := resultado1 < resultado2;
            '!=' : resultado := resultado1 <> resultado2;
            else // ==
            resultado := resultado1 = resultado2;
            end;
    end;

// <condicion> ::= <condicionAnidada> <sec_condicion>
    Procedure eval_condicion(arbol: tapuntNodo; var estado: TEstado ; var resultado1: boolean);
    var
    resultado:boolean;
    begin
      eval_condicionAnidada(arbol^.hijos.elem[1], estado, resultado);
      eval_sec_condicion(arbol^.hijos.elem[2], estado, resultado, resultado1);
    end;
    
// <sec_condicion> ::= “or” <CondicionAnidada> <sec_condicion> | epsilon
procedure eval_sec_condicion (arbol: tapuntnodo ; var estado: TEstado; var resultado,resultado1:boolean);
var
    res : boolean;
begin
  if arbol^.hijos.cant = 0 then resultado1:= resultado else
  begin
    eval_condicionAnidada(arbol^.hijos.elem[2], estado,res);
    res:= resultado or res;
    eval_sec_condicion(arbol^.hijos.elem[3],estado,res,resultado1);
  end;
    
end;

// <condicionAnidada> ::= <pre_condicionAnidada> <sec_condicionAnidada> 
    procedure eval_condicionAnidada( arbol: tapuntNodo; var estado: TEstado; var resultado1:boolean);
    var
    resultado: boolean;
    begin
        eval_preCondicionAnidada(arbol^.hijos.elem[1], estado, resultado);
        eval_sec_CondicionAnidada(arbol^.hijos.elem[2], estado, resultado, resultado1);
    end;

// <pre_condicionAnidada> ::= <expRel> | “not” <pre_condicionAnidada>  | ”{”<condicion>”}”
    procedure eval_preCondicionAnidada (arbol: TApuntNodo ; var estado: TEstado; var resultado:boolean);
    begin
      if arbol^.hijos.elem[1]^.simbolo = tnot then
      begin
        eval_preCondicionAnidada(arbol^.hijos.elem[2],estado,resultado);
        resultado:= not(resultado);
      end
      else
      begin
        if arbol^.hijos.elem[1]^.simbolo = tllaveab then eval_condicion(arbol^.Hijos.elem[2],estado,resultado)
        else eval_expRel(arbol^.hijos.elem[1],estado,resultado);
      end;
    end;

// <sec_condicionAnidada> ::= “and”  <pre_condicionAnidada> <sec_condicionAnidada> | epsilon
procedure eval_sec_condicionAnidada (arbol: tapuntnodo; var estado: testado ; var resultado,resultado1: boolean);
var
res:boolean;
    begin
      if arbol^.Hijos.cant = 0 then resultado1:= resultado else
      begin
        eval_preCondicionAnidada(arbol^.hijos.elem[2],estado,res);
        res:= resultado and res;
        eval_sec_condicionAnidada(arbol^.hijos.elem[3],estado,res,resultado1);
      end;
    end;

// <lectura> ::= “sysGet” ”(“ ”cteCadena” “,” ”id” ”)”
    procedure eval_lectura(arbol: tapuntNodo; var estado: TEstado);
    var
    id:real;
    begin;
        write(arbol^.hijos.elem[3]^.lexema);
        readln(id);
        asignarValor(arbol^.hijos.elem[5]^.lexema,estado,0,id);
    end;
               

// <escritura> ::= “sysOut” ”(“<varEscritura>”)”
    procedure eval_escritura(arbol: tapuntNodo ; var estado: TEstado);
    begin
       eval_varEscritura(arbol^.hijos.elem[3], estado); 
    end;
       
// <varEscritura> ::= “cteCadena”<post_varEscritura> | <expArit><post_varEscritura>  
procedure eval_varEscritura (arbol: tapuntNodo; var estado: TEstado);
var
resultado:real;
    begin   
        if arbol^.hijos.elem[1]^.simbolo = tctecadena then
        begin
            writeln(arbol^.hijos.elem[1]^.lexema);
            eval_post_varEscritura(arbol^.hijos.elem[2], estado);
        end
        else
        begin
            eval_expArit(arbol^.hijos.elem[1], estado,resultado);
            writeln(resultado:00:2);
            eval_post_varEscritura(arbol^.hijos.elem[2], estado); 
        end;
    end;

// <post_varEscritura> ::= ”,” <varEscritura> | epsilon
    procedure eval_post_varEscritura (arbol:tapuntnodo ; var estado: testado);
    begin
      if arbol^.hijos.cant <> 0 then eval_varEscritura(arbol^.Hijos.elem[2],estado);
    end;
    

Procedure InicializarEst(var Estado:TEstado);
begin
  Estado.cant := 0;
end;

procedure AgregarEstado (var Estado: TEstado ; X: TElemEstado);
var cantidad: Integer;
begin
  cantidad:= Estado.cant + 1 ; 
  Estado.elem[cantidad] := X;
  Estado.cant:= cantidad;

end;

procedure CrearVariable(var estado: TEstado;  lexema: string; tipo : tipoSimboloGramatical); 
VAR X: TElemEstado;
begin

  X.lexemaId:=lexema;
  X.Tipo:=tipo;
  X.ValReal:=0;
  AgregarEstado(estado,X);

end; 

function valorDe (var estado: TEstado; lexema:string; indice:byte):real;
    var
        i: Integer;
        flag: boolean;
begin
flag:= false;
    for i:= 1 to estado.cant do
        begin
          if Estado.elem[i].lexemaid = AnsiLowerCase(lexema) then
            begin
            flag:=true;
                if Estado.elem[i].Tipo= treal then
                        valorDe:= Estado.elem[i].valReal else  
                        valorDe:= Estado.elem[i].valArray[indice];      
              
            end;
        end;
    if not flag then writeln('Variable ', lexema, ' no definida');
end;

procedure asignarValor (lexema:string; var estado: testado; indice:byte; valor:real);
var
    i: integer;
    begin
      for i:=1 to estado.cant do
        begin
        if estado.elem[i].lexemaid = lexema then
          begin
             if Estado.elem[i].tipo = treal then
            estado.elem[i].valreal := valor else
              Estado.elem[i].valarray[indice] := valor;
            
        end;
          end;
       
    end;

procedure asignarValorUltPosicion (lexema:string ; var estado:testado; var valor:real);
var
i: integer;
ultimaPos: byte;
begin
    for i:= 1 to estado.cant do
      begin
        if (Estado.elem[i].lexemaid = lexema) then
        begin
          inc(estado.elem[i].tamanio);
          ultimaPos:=estado.elem[i].tamanio;
          estado.elem[i].valarray[ultimaPos] := valor;
          // necesitamos poder asignar v = [1,2,3]. necesitamos una forma de saber
          // cual es la última posición utilizada, sumarle una, y ahí asignar el valor
        end;
      end;
end;

procedure crearArray(var estado: TEstado;  lexema: string; tipo : tipoSimboloGramatical; tam : integer);
VAR X:TElemEstado; 
Vector:array[1..MaxArreglo]of real;
begin
  x.lexemaId:=lexema;
  x.Tipo:=tarray;
  x.CantArray:=tam;
  x.tamanio:= 0;
  FillChar(Vector,tam, 0);  
  x.ValArray:=Vector;
  AgregarEstado(estado,x); 
end; 
end.
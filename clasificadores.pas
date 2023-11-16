unit clasificadores;

{$mode ObjFPC}{$H+}

interface
  uses tipos,archivos;

function EsIdentificador(VAR Fuente: FileOfChar;VAR Control:Longint ; VAR Lexema:String): boolean;
function EsConstanteReal(VAR Fuente: FileOfChar;VAR Control:Longint ; VAR Lexema:String): boolean;
function EsSimboloEspecial (var Fuente: FileOfChar; var Control: Longint; var Lexema: string; var CompLex: TipoSimboloGramatical):boolean;
function EsCadena(VAR Fuente: FileOfChar;VAR Control:Longint ; VAR Lexema:String): boolean;


implementation

function EsIdentificador(VAR Fuente: FileOfChar;VAR Control:Longint ; VAR Lexema:String): boolean;
Const
  q0=0;
  F=[2];
Type
  Q=0..3;
  Sigma=(Letra, Digito, Otro);
  TipoDelta=Array[Q,Sigma] of Q;
Var
  PS:Longint;
  EstadoActual:Q;
  Delta:TipoDelta;
  car:char;
  {function definida de manera local}
  function CarASimIdem(Car:char): Sigma;
        begin
            Case Car of
            'a'..'z', 'A'..'Z': CarASimIdem:=Letra;
            '0'..'9': CarASimIdem:= Digito;
            else
                CarASimIdem:=Otro;
            end;
        end;
  Begin
    {Cargar la tabla de transiciones}
    Delta[0,Letra]:=1;
    Delta[0,Digito]:=3;
    Delta[0,Otro]:=3;

    Delta[1,Letra]:=1;
    Delta[1,Digito]:=1;
    Delta[1,Otro]:=2;

    EstadoActual:=q0;

    {comenzamos a recorrer}
    PS:=Control;
    Lexema:='';

    while EstadoActual in [0,1] do                        {mientras no estemos en un estado final o muerto formamos el lexema}
    begin
       LeerCar(Fuente,PS,car);
       EstadoActual:=Delta[EstadoActual,CarASimIdem(car)];
       if EstadoActual = 1 then                           {acá volvemos a preguntar si estamos en nodos no finales (no preguntamos por 0 debido a que en ESTE automata, cuando salimos de 0 no podemos volver a el)}
           Lexema:= Lexema + car;                         {concatenamos el caracter}
       PS:=PS+1;
    end;
    if EstadoActual in F then                             {en este punto, el automata habrá salido del estado 1. Nos preguntamos si está en un nodo final o no}
      begin
        EsIdentificador:= true;
        Control:=PS-1;                                    {si es identificador, devolvemos el control parado sobre el ;}
      end
    else
        EsIdentificador:= false;                          {si no es identificador, no modificamos el control, así cuando llamemos otra función, verifique este lexema, por si pudiese llegar a ser otro tipo}
  End;

function EsConstanteReal(VAR Fuente: FileOfChar;VAR Control:Longint ; VAR Lexema:String): boolean;
Const
  q0=0;
  F=[6]; 
Type
  Q=0..6;
  Sigma=(Punto, Digito, Otro);
  TipoDelta=Array[Q,Sigma] of Q;
Var
  EstadoActual:Q;
  Delta:TipoDelta;
  car : Char;
  i : LongInt;

function CarASimb(car:char): Sigma;
Begin
  Case Car of
    '0'..'9':CarASimb:=Digito;
    '.':CarASimb:=Punto;
  else
   CarASimb:=Otro
  End;
End;
Begin

  {Cargar la tabla de transiciones}
  Delta[0,Punto]:=1;
  Delta[0,Digito]:=2;
  Delta[0,Otro]:=1;

  Delta[2,Punto]:=4;
  Delta[2,Digito]:=2;
  Delta[2,Otro]:=6;
 
  Delta[4,Punto]:=1;
  Delta[4,Digito]:=5;
  Delta[4,Otro]:=1;

  Delta[5,Punto]:=6;
  Delta[5,Digito]:=5;
  Delta[5,Otro]:=6;

  EstadoActual:=q0;
  i := Control;
  Lexema := '';
  while ( EstadoActual in [0,2,4,5] )  do begin
    leerCar(Fuente, i, car);
    Inc(i);
      EstadoActual:=Delta[EstadoActual,CarASimb(car)];
    if EstadoActual in [2,4,5] then begin
      Lexema := Lexema + car;
    end;
  end;
  if EstadoActual in F then begin
    Control := i-1;
    EsConstanteReal := True;
  end else EsConstanteReal := False;

End; 

function EsCadena(VAR Fuente: FileOfChar;VAR Control:Longint ; VAR Lexema:String): boolean;
Const
  q0=0;
  F=[3];
Type
  Q=0..3;
  Sigma=(Comillas, Otro);
  TipoDelta=Array[Q,Sigma] of Q;
Var
  EstadoActual:Q;
  Delta:TipoDelta;
	car: char;
	simb:Sigma;
	c:longint;

function CarASimb(car:char): Sigma;
Begin
  Case Car of
    #34:CarASimb:=Comillas;
  else
   CarASimb:=Otro
  End;
End;


Begin
  {Cargar la tabla de transiciones}
  Delta[0,Comillas]:=1;
  Delta[0,Otro]:=2;
  Delta[1,Comillas]:=3;
  Delta[1,Otro]:=1;


  EstadoActual:=q0;
	Lexema:='';
	c:=control;
	LeerCar(fuente,c,car);
  while not(EstadoActual in [2,3]) do
	begin
		EstadoActual:=Delta[EstadoActual,CarASimb(car)];
		if EstadoActual=1 then
		begin
      if car <> #34 then Lexema:= Lexema + car ;
                c:=c+1;
		LeerCar(fuente,c,car);
		end;
	end;
	if EstadoActual in F then
	begin
		EsCadena:=true;
		control:=c+1;
	end
	else EsCadena:=false;

End;
function EsSimboloEspecial (var Fuente: FileOfChar; var Control: Longint; var Lexema: string; var CompLex: TipoSimboloGramatical):boolean;
var
   c:longint;
    car,car2:char;
begin
     c:= control;
     LeerCar(Fuente,c,car);
     lexema:=car;
     EsSimboloEspecial:= true;
     if car = 'root' then Complex:=troot else begin // Error: Constant and Case types do not match, no nos dejaba poner 'root' dentro del case of
     case car of
     '/': CompLex:= tdivision;
     '(': CompLex:= tparab;
     ')': CompLex:= tparcer;
     ',': Complex:= tcoma;
     ';': Complex:= tpuntocoma;
     '=','>','<','!':
      begin
           c:=c+1;
           LeerCar(Fuente,c,car2);
           if car2 = '=' then
            begin
             lexema:= lexema + car2;
             CompLex:= toprel;
             end
             else
              begin
               if car = '=' then Complex:= tasignacion else
                 complex:= toprel;
                c:=c-1;
                 end; 
        end;
        '[': CompLex:= tcorab;
        ']': CompLex:= tcorcer;
        '{': CompLex:= tllaveab;
        '}': CompLex:= tllavecer;
        '+': CompLex:= tsuma;
        '-': CompLex:= tresta;
        '^': CompLex:= tpotencia;
        '*': Complex:= tmultiplicacion;
        ':': Complex:= tdospuntos;
        else
        EsSimboloEspecial:= false;
        end;
        Control:= c + 1;
     end;
     end;

end.

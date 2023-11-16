unit analizador_lexico;

{$mode ObjFPC}{$H+}

interface
uses
  tipos, archivos, clasificadores;
Procedure cargarTS(var l:TablaDeSimbolos);
procedure InstalarEnTS(var Lexema:string; var l: TablaDeSimbolos; var complex:TipoSimboloGramatical);
Procedure ObtenerSiguienteComplex (Var Fuente: FileOfChar;Var Control:Longint;var Complex:TipoSimboloGramatical;var Lexema: string ;Var TS:TablaDeSimbolos);


implementation

Procedure cargarTS(var l:TablaDeSimbolos);
var x:TElemTS;
  begin
       x.complex:=tprogram;
       x.lexema:='program';
       agregar(l,x);

       x.complex:=troot;
       x.lexema:='root';
       agregar(l,x);

       x.complex:=tvar;
       x.lexema:='var';
       agregar(l,x);

       x.complex:=tbody;
       x.lexema:='body';
       agregar(l,x);

       x.complex:=tif;
       x.lexema:='if';
       agregar(l,x);

       x.complex:=telse;
       x.lexema:='else';
       agregar(l,x);

       x.complex:=treal;
       x.lexema:='real';
       agregar(l,x);

       x.complex:=tsysget;
       x.lexema:='sysGet';
       agregar(l,x);

       x.complex:=tsysOut;
       x.lexema:='sysOut';
       agregar(l,x);

       x.complex:=twhile;
       x.lexema:='while';
       agregar(l,x);

       x.complex:=tstring;
       x.lexema:='string';
       agregar(l,x);

       x.complex:=tfor;
       x.lexema:='for';
       agregar(l,x);

       x.complex:=tarray;
       x.lexema:='array';
       agregar(l,x);

       x.complex:=tto;
       x.lexema:= 'to';
       agregar(l,x);

       x.complex:=tor;
       x.lexema:='or';
       agregar(l,x);

       x.complex:=tand;
       x.lexema:='and';
       agregar(l,x);

       x.complex:=tnot;
       x.lexema:='not';
       agregar(l,x);

  end;

procedure InstalarEnTS(var Lexema:string; var l: TablaDeSimbolos; var complex:TipoSimboloGramatical);
var x: TElemTS;
  encontrado:boolean;
  begin
       buscarLista(l,lexema,encontrado);
       if encontrado then
       begin
         recuperar(l,x);
         complex:=x.complex;
       end
       else
       begin
         x.complex:=tid;
         x.lexema:=lexema;
         if not fin(l) then agregar(l,x);
         complex:=x.complex;
         end;
  end;

  Procedure ObtenerSiguienteComplex (Var Fuente: FileOfChar;Var Control:Longint;var Complex:TipoSimboloGramatical;var Lexema: string ;Var TS:TablaDeSimbolos);
Var
 car:char;
Begin
    LeerCar(fuente,control,car);
    While (car in [#1..#32]) do
    begin
  		control:=control+1;
  		LeerCar(fuente,control,car);
    end;
    if car=#0 then 
    begin
      CompLex:=pesos;
      lexema:='';
    end
    
      else
      begin
  		  If EsIdentificador(Fuente,Control,Lexema) then InstalarEnTS(Lexema,TS,CompLex)
  		  else If EsConstanteReal(Fuente,Control,Lexema) then CompLex:=tctereal
  		  else If EsCadena(Fuente,Control,Lexema) then CompLex:=tctecadena
  		  else if Not EsSimboloEspecial(Fuente,Control,Lexema,CompLex) then	CompLex:=errorLexico;
      end;
end;
end.


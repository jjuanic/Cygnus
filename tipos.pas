unit tipos;
{$codepage utf-8}
{$H+}

interface
const
   MaxSim=1000;
   FinArch=#0;
type
  TipoSimboloGramatical=(tprogram,tpuntocoma,tcoma, tasignacion, tmultiplicacion, tsuma, tresta, tdivision, tpotencia, troot,
  tor, tnot, tand, toprel, tparab, tparcer, tllaveab, tllavecer, tcorab, tcorcer, tid, tvar, tbody, tdospuntos,
  tif, telse, treal, tsysGet, tsysOut, twhile, tstring, tfor, tto, tarray, tctereal, tctecadena, errorLexico, pesos,
  vPrograma,vDefiniciones ,vDefinicion, vpost_asignacion ,vTipo ,vCuerpo,vSec_cuerpo,vSent,vAsignacion,vExpArit,vSec_ExpArit,vOpArit,vExpArit2, vSec_exparit2,
  vOpArit2,vExpArit3,vSec_ExpArit3,vOpArit3 ,vExpArit4,vIndice,vCteArreglo,vArreglo,vPost_arreglo,vCiclo,vCondicional,vElse_condicional,
  vExpRel,vCondicion,vSec_condicion,vCondicionAnidada,vPre_condicionAnidada,vSec_condicionAnidada,vLectura,vescritura ,vVarEscritura,
  vPost_varEscritura);

  compLex= tprogram..pesos;
  FileOfChar= file of char;

  TElemTS= record
     compLex:TipoSimboloGramatical;
     Lexema:string;
  end;
  TablaDeSimbolos= record
    cab,act:byte;
    elem:array[1..MaxSim]of TElemTS;
    tamanio:0..maxsim;
  end;

procedure crearlista(var l:TablaDeSimbolos);
procedure agregar (var l:TablaDeSimbolos; x:TElemTS);
function lista_llena (var l:TablaDeSimbolos): boolean;
function lista_vacia (var l:TablaDeSimbolos): boolean;
procedure eliminarlista (var l:TablaDeSimbolos;buscado: string; var x:TElemTS);
procedure siguiente(var l:TablaDeSimbolos);
procedure primero (var l:TablaDeSimbolos);
function fin (l:TablaDeSimbolos): boolean;
function tamanio (var l:TablaDeSimbolos): byte;
procedure recuperar (var l:TablaDeSimbolos; var x:TElemTS);
procedure buscarlista(var l:TablaDeSimbolos; buscado:string; var enc:boolean);

implementation
procedure crearlista(var l:TablaDeSimbolos);
begin
l.cab:=0;
l.tamanio:=0;
end;

function tamanio (var l:TablaDeSimbolos): byte;
begin
tamanio:= l.tamanio;
end;

function lista_llena (var l:TablaDeSimbolos): boolean;
begin
lista_llena:= l.tamanio = MaxSim;
end;

function lista_vacia (var l:TablaDeSimbolos): boolean;
begin
lista_vacia:= l.tamanio = 0;
end;

procedure desplazar_atras(var l:TablaDeSimbolos; posicion:byte);
var
i:byte;
begin
for i:= tamanio(l) downto posicion do
l.elem[i+1]:= l.elem[i] ;
end;

procedure agregar (var l:TablaDeSimbolos; x:TElemTS);
begin
if (l.cab= 0) then
begin
inc(l.cab);
l.elem[l.cab]:=x
end
else
if (l.elem[l.cab].lexema > x.lexema) then
begin
desplazar_atras(l, 1);
l.cab:=1;
l.elem[l.cab]:=x
end
else
begin
l.act:= l.cab+1;
while (l.act <= tamanio(l)) and (l.elem[l.act].lexema < x.lexema) do
begin
inc(l.act)
end;
if l.act <=tamanio(l) then //l.act<= tamanio (l)
desplazar_atras(l,l.act);
l.elem[l.act]:=x
end;
inc(l.tamanio);
end;

procedure desplazar_adelante(var l:TablaDeSimbolos;posicion:byte);
var
i:byte;
begin
for i:=posicion to tamanio(l)-1 do
l.elem[i]:= l.elem[i+1];
end;

procedure eliminarlista (var l:TablaDeSimbolos;buscado: string; var x:TElemTS);
begin
if (l.elem[l.cab].lexema= buscado) then
begin
x:= l.elem[l.cab];
desplazar_adelante(l,1) //si hay un solo elemento en la lista l.cab:=0
end
else
begin
l.act:= l.cab+1;
while (l.elem[l.act].lexema <> buscado) do
begin
inc(l.act);
end;
x:= l.elem[l.act];
desplazar_adelante(l,l.act);
end;
dec(l.tamanio);
if l.tamanio = 0 then l.cab:= 0;
end;

procedure siguiente(var l:TablaDeSimbolos);
begin
l.act:= l.act + 1;
end;

procedure primero (var l:TablaDeSimbolos);
begin
l.act:= l.cab;
end;

procedure recuperar (var l:TablaDeSimbolos; var x:TElemTS);
begin
x:= l.elem[l.act];
end;

function fin (l:TablaDeSimbolos): boolean;
begin
fin:= l.act = tamanio(l)+1;
end;

procedure buscarlista(var l:TablaDeSimbolos; buscado:string; var enc:boolean);
var x:TELEMTS;
begin
 enc:=false;
 primero(l);
 while (not fin(l)) and (not enc) do
 begin
   recuperar(l,x);
   if x.lexema=buscado then enc:=true
   else siguiente(l);
 end;
end;

end.


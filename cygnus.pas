Program cygnus;
{$H+}
{$codepage utf-8}
//uses clasificadores,tipos,archivos, analizador_lexico, analizador_sintactico;
uses clasificadores,tipos,archivos, analizador_lexico, analizador_sintactico, evaluador;
//Probar Analizador Léxico
var
  Fuente:FileOfChar;
  Control:Longint;
  Lexema:String;
  TS:TablaDeSimbolos;
  complex:TipoSimboloGramatical;
  estado: testado;
arbol: tapuntNodo;
error:boolean;
begin

abrirArchivo(Fuente);
crearLista(TS);
cargarTS(TS);
complex:= tid;
while (complex <> pesos) and (complex <> errorLexico) do
begin
obtenerSiguienteComplex(Fuente,Control,complex,lexema,TS);
// writeln(complex,':', lexema);
end;
cerrarArchivo(fuente); 

begin

analizadorpredictivo(ruta,arbol,error);
if not error then 
begin
  guardarArbol('C:\Users\juan-\OneDrive\Escritorio\Facultad\Segundo\CygnusVS\arbol.cyg',arbol);
  eval_programa(arbol,estado);
end;



end;
end. 
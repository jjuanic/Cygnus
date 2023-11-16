Program cygnus;
uses clasificadores,tipos,archivos, analizador_lexico, analizador_sintactico;
//Probar Analizador Léxico
{var
  Fuente:FileOfChar;
  Control:Longint;
  Lexema:String;
  TS:TablaDeSimbolos;
  complex:TipoSimboloGramatical;
begin

abrirArchivo(Fuente);
crearLista(TS);
cargarTS(TS);
complex:= tid;
while (complex <> pesos) and (complex <> errorLexico) do
begin
obtenerSiguienteComplex(Fuente,Control,complex,lexema,TS);
writeln(complex,':', lexema);
end;
readln();
cerrarArchivo(fuente);  }

// probar analizador sintáctico
var
arbol: tapuntNodo;
error:boolean;

begin

analizadorpredictivo(ruta,arbol,error);
if not error then guardarArbol('arbol.txt',arbol);
readln();

end.



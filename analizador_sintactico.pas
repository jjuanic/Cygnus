Unit analizador_sintactico;
{$codepage utf-8}
{$H+}

Interface

Uses tipos,analizador_lexico,clasificadores, archivos;

Const 
  MaxProd = 127;
  N = 300;

Type 
  //Definición de la TAS
  TProduccion = Record
    elem: array[1..MaxProd] Of TipoSimboloGramatical;
    cant: 0..MaxProd;
  End;
  TipoVariable = vPrograma..vPost_varEscritura;
  TipoTerminypesos = tprogram..pesos;
  TipoTAS = array [TipoVariable, TipoTerminypesos] Of ^Tproduccion;

  // Arbol de derivación
  TApuntNodo = ^TNodoArbol;
  TipoHIjos = Record
    elem: array[1..MaxProd] Of TApuntNodo;
    cant: 0..MaxProd;
  End;
  TNodoArbol = Record
    Simbolo: TipoSimboloGramatical;
    lexema: string;
    Hijos: TipoHIjos;
  End;
  // Pila
  TipoElemPila = Record
    Simbolo: TipoSimboloGramatical;
    NodoArbol: TApuntNodo;
  End;

  TipoPila = Record
    elem: array[1..200] Of TipoElemPila;
    tam,tope: 0..200;
  End;



Procedure analizadorPredictivo(rutaFuente : String; Var arbol: TApuntNodo; Var                               error:boolean);
//rutaFuente es un string, no es lo mismo que Fuente
Procedure guardarArbol(ruta: String;Var arbol: tapuntnodo);

Procedure CREARPILA(Var P:TipoPila);
Procedure APILAR (Var P:TipoPila; X:TipoElemPila);
Function PILA_LLENA (Var P:TipoPila): BOOLEAN;
Function PILA_VACIA (Var P:TipoPila): BOOLEAN;
Procedure DESAPILAR (Var P:TipoPila; Var X:TipoElemPila);
Procedure agregarHijo (Var raiz:TApuntNodo; Var hijo:TApuntNodo);
Procedure crearNodo( SG:tipoSimboloGramatical;Var apuntador:TApuntNodo);


Implementation
Procedure CREARPILA(Var P:TipoPila);
Begin
  P.TAM := 0;
  P.TOPE := 0;
End;
Procedure APILAR (Var P:TipoPila; X:TipoElemPila);
Begin
  P.TOPE := P.TOPE+1;
  P.ELEM[P.TOPE] := X;
  INC(P.TAM)
End;
Function PILA_LLENA (Var P:TipoPila): BOOLEAN;
Begin
  PILA_LLENA := P.TAM=N ;
End;
Function PILA_VACIA (Var P:TipoPila): BOOLEAN;
Begin
  PILA_VACIA := P.TAM=0;
End;
Procedure DESAPILAR (Var P:TipoPila;Var X:TipoElemPila);
Begin
  X := P.ELEM[P.TOPE];
  P.TOPE := P.TOPE-1;
  DEC(P.TAM)
End;

Procedure apilartodos(Var celda:tproduccion; Var padre:tapuntnodo; Var pila: tipopila);

Var 
  i: 0..MaxProd;
  epila: TipoElemPila;
Begin
  For i:= celda.cant Downto 1 Do
    Begin
      epila.simbolo := celda.elem[i];
      epila.nodoarbol := padre^.hijos.elem[i];
      apilar(pila,epila);
    End;
End;

Procedure crearNodo(SG:tipoSimboloGramatical; Var apuntador:TApuntNodo);
Begin
  new(apuntador);
  apuntador^.Simbolo := SG;
  apuntador^.lexema := '';
  apuntador^.hijos.cant := 0;
End;

Procedure agregarHijo (Var raiz:TApuntNodo; Var hijo:TApuntNodo);
Begin
  If raiz^.hijos.cant< maxProd Then
    Begin
      inc(raiz^.hijos.cant);
      raiz^.hijos.elem[raiz^.hijos.cant] := hijo;
    End;
End;

Procedure cargarTAS (Var TAS: tipoTAS);

Var 

  i,j: tipoSimboloGramatical;
Begin
  For i:=vPrograma To vPost_varEscritura Do
    For j:= tprogram To pesos Do
      TAS[i,j] := Nil;


//vPrograma -> “program” “id” “var” <definiciones> “body” “{“ <cuerpo> “}”
  New(TAS[vPrograma,tprogram]);
  TAS[vPrograma,tprogram]^.elem[1] := tprogram;
  TAS[vPrograma,tprogram]^.elem[2] := tid;
  TAS[vPrograma,tprogram]^.elem[3] := tvar;
  TAS[vPrograma,tprogram]^.elem[4] := vdefiniciones;
  TAS[vPrograma,tprogram]^.elem[5] := tbody;
  TAS[vPrograma,tprogram]^.elem[6] := tllaveab;
  TAS[vPrograma,tprogram]^.elem[7] := vcuerpo;
  TAS[vPrograma,tprogram]^.elem[8] := tllavecer;
  TAS[vPrograma,tprogram]^.cant := 8;

  // vDefiniciones -> <definicion>”;”<definiciones>
  New(TAS[vDefiniciones,tid]);
  TAS[vDefiniciones,tid]^.elem[1] := vdefinicion;
  TAS[vDefiniciones,tid]^.elem[2] := tpuntocoma;
  TAS[vDefiniciones,tid]^.elem[3] := vdefiniciones;
  TAS[vDefiniciones,tid]^.cant := 3;

  //  vDefiniciones -> epsilon
  New(TAS[vDefiniciones,tbody]);
  TAS[vDefiniciones,tbody]^.cant := 0;

  // vDefinicion -> “id” “=” <tipo>
  New(TAS[vDefinicion,tid]);
  TAS[vDefinicion,tid]^.elem[1] := tid;
  TAS[vDefinicion,tid]^.elem[2] := tasignacion;
  TAS[vDefinicion,tid]^.elem[3] := vtipo;
  TAS[vDefinicion,tid]^.cant := 3;

  //vTipo -> "real"
  New(TAS[vTipo,treal]);
  TAS[vTipo,treal]^.elem[1] := treal;
  TAS[vTipo,treal]^.cant := 1;

  //vTipo -> “array” ”[“ ”cteReal” ”]”
  New(TAS[vTipo,tarray]);
  TAS[vTipo,tarray]^.elem[1] := tarray;
  TAS[vTipo,tarray]^.elem[2] := tcorab;
  TAS[vTipo,tarray]^.elem[3] := tctereal;
  TAS[vTipo,tarray]^.elem[4] := tcorcer;
  TAS[vTipo,tarray]^.cant := 4;

  //vCuerpo -> <sent> <sec_cuerpo>
  New(TAS[vCuerpo,tid]);
  TAS[vCuerpo,tid]^.elem[1] := vsent;
  TAS[vCuerpo,tid]^.elem[2] := vsec_cuerpo;
  TAS[vCuerpo,tid]^.cant := 2;

  //vCuerpo -> <sent> <sec_cuerpo>
  New(TAS[vCuerpo,tSysGet]);
  TAS[vCuerpo,tSysGet]^.elem[1] := vsent;
  TAS[vCuerpo,tSysGet]^.elem[2] := vsec_cuerpo;
  TAS[vCuerpo,tSysGet]^.cant := 2;

  //vCuerpo -> <sent> <sec_cuerpo>
  New(TAS[vCuerpo,tSysOut]);
  TAS[vCuerpo,tSysOut]^.elem[1] := vsent;
  TAS[vCuerpo,tSysOut]^.elem[2] := vsec_cuerpo;
  TAS[vCuerpo,tSysOut]^.cant := 2;

  //vCuerpo -> <sent> <sec_cuerpo>
  New(TAS[vCuerpo,twhile]);
  TAS[vCuerpo,twhile]^.elem[1] := vsent;
  TAS[vCuerpo,twhile]^.elem[2] := vsec_cuerpo;
  TAS[vCuerpo,twhile]^.cant := 2;

  //vCuerpo -> <sent> <sec_cuerpo>
  New(TAS[vCuerpo,tfor]);
  TAS[vCuerpo,tfor]^.elem[1] := vsent;
  TAS[vCuerpo,tfor]^.elem[2] := vsec_cuerpo;
  TAS[vCuerpo,tfor]^.cant := 2;

  //vCuerpo -> <sent> <sec_cuerpo>
  New(TAS[vCuerpo,tif]);
  TAS[vCuerpo,tif]^.elem[1] := vsent;
  TAS[vCuerpo,tif]^.elem[2] := vsec_cuerpo;
  TAS[vCuerpo,tif]^.cant := 2;

  //vSec_cuerpo -> epsilon
  New(TAS[vSec_cuerpo,tllavecer]);
  TAS[vSec_cuerpo,tllavecer]^.cant := 0;

  //vSec_cuerpo -> <sent> <sec_cuerpo>
  New(TAS[vSec_cuerpo,tid]);
  TAS[vSec_cuerpo,tid]^.elem[1] := vsent;
  TAS[vSec_cuerpo,tid]^.elem[2] := vsec_cuerpo;
  TAS[vSec_cuerpo,tid]^.cant := 2;

  //vSec_cuerpo -> <sent> <sec_cuerpo>
  New(TAS[vSec_cuerpo,tSysGet]);
  TAS[vSec_cuerpo,tSysGet]^.elem[1] := vsent;
  TAS[vSec_cuerpo,tSysGet]^.elem[2] := vsec_cuerpo;
  TAS[vSec_cuerpo,tSysGet]^.cant := 2;

  //vSec_cuerpo -> <sent> <sec_cuerpo>
  New(TAS[vSec_cuerpo,tSysOut]);
  TAS[vSec_cuerpo,tSysOut]^.elem[1] := vsent;
  TAS[vSec_cuerpo,tSysOut]^.elem[2] := vsec_cuerpo;
  TAS[vSec_cuerpo,tSysOut]^.cant := 2;

  //vSec_cuerpo -> <sent> <sec_cuerpo>
  New(TAS[vSec_cuerpo,twhile]);
  TAS[vSec_cuerpo,twhile]^.elem[1] := vsent;
  TAS[vSec_cuerpo,twhile]^.elem[2] := vsec_cuerpo;
  TAS[vSec_cuerpo,twhile]^.cant := 2;

  //vSec_cuerpo -> <sent> <sec_cuerpo>
  New(TAS[vSec_cuerpo,tfor]);
  TAS[vSec_cuerpo,tfor]^.elem[1] := vsent;
  TAS[vSec_cuerpo,tfor]^.elem[2] := vsec_cuerpo;
  TAS[vSec_cuerpo,tfor]^.cant := 2;

  //vSec_cuerpo -> <sent> <sec_cuerpo>
  New(TAS[vSec_cuerpo,tif]);
  TAS[vSec_cuerpo,tif]^.elem[1] := vsent;
  TAS[vSec_cuerpo,tif]^.elem[2] := vsec_cuerpo;
  TAS[vSec_cuerpo,tif]^.cant := 2;

  //vSent -> <asignacion> ”;”
  New(TAS[vSent,tid]);
  TAS[vSent,tid]^.elem[1] := vasignacion;
  TAS[vSent,tid]^.elem[2] := tpuntocoma;
  TAS[vSent,tid]^.cant := 2;

  //vSent -> <lectura>”;”
  New(TAS[vSent,tSysGet]);
  TAS[vSent,tSysGet]^.elem[1] := vlectura;
  TAS[vSent,tSysGet]^.elem[2] := tpuntocoma;
  TAS[vSent,tSysGet]^.cant := 2;

  //vSent -> <escritura>”;”
  New(TAS[vSent,tSysOut]);
  TAS[vSent,tSysOut]^.elem[1] := vescritura;
  TAS[vSent,tSysOut]^.elem[2] := tpuntocoma;
  TAS[vSent,tSysOut]^.cant := 2;

  //vSent -> <ciclo>
  New(TAS[vSent,twhile]);
  TAS[vSent,twhile]^.elem[1] := vciclo;
  TAS[vSent,twhile]^.cant := 1;

  //vSent -> <ciclo>
  New(TAS[vSent,tfor]);
  TAS[vSent,tfor]^.elem[1] := vciclo;
  TAS[vSent,tfor]^.cant := 1;

  //vSent -> <condicional>
  New(TAS[vSent,tif]);
  TAS[vSent,tif]^.elem[1] := vcondicional;
  TAS[vSent,tif]^.cant := 1;

  //vAsignacion -> “id” <indice> “=” <post_asignacion>
  New(TAS[vAsignacion,tid]);
  TAS[vAsignacion,tid]^.elem[1] := tid;
  TAS[vAsignacion,tid]^.elem[2] := vIndice;
  TAS[vAsignacion,tid]^.elem[3] := tasignacion;
  TAS[vAsignacion,tid]^.elem[4] := vpost_asignacion;
  TAS[vAsignacion,tid]^.cant := 4;

  //vpost_asignacion -> <cteArreglo>
  New(TAS[vpost_asignacion,tcorab]);
  TAS[vpost_asignacion,tcorab]^.elem[1] := vCteArreglo;
  TAS[vpost_asignacion,tcorab]^.cant := 1;

  //vpost_asignacin -> <expArit> primero(expArit) = “id”, “(”, “cteReal”, “-”
  New(TAS[vpost_asignacion,tid]);
  TAS[vpost_asignacion,tid]^.elem[1] := vExpArit;
  TAS[vpost_asignacion,tid]^.cant := 1;
  
  New(TAS[vpost_asignacion,tparab]);
  TAS[vpost_asignacion,tparab]^.elem[1] := vExpArit;
  TAS[vpost_asignacion,tparab]^.cant := 1;

  New(TAS[vpost_asignacion,tctereal]);
  TAS[vpost_asignacion,tctereal]^.elem[1] := vExpArit;
  TAS[vpost_asignacion,tctereal]^.cant := 1;

  New(TAS[vpost_asignacion,tresta]);
  TAS[vpost_asignacion,tresta]^.elem[1] := vExpArit;
  TAS[vpost_asignacion,tresta]^.cant := 1;
  


  //vExparit -> <ExpArit2> <sec_ExpArit>
  New(TAS[vExparit,tresta]);
  TAS[vExparit,tresta]^.elem[1] := vexparit2;
  TAS[vExparit,tresta]^.elem[2] := vsec_exparit;
  TAS[vExparit,tresta]^.cant := 2;

  //vExparit -> <ExpArit2> <sec_ExpArit>
  New(TAS[vExparit,tparab]);
  TAS[vExparit,tparab]^.elem[1] := vexparit2;
  TAS[vExparit,tparab]^.elem[2] := vsec_exparit;
  TAS[vExparit,tparab]^.cant := 2;

  //vExparit -> <ExpArit2> <sec_ExpArit>
  New(TAS[vExparit,tid]);
  TAS[vExparit,tid]^.elem[1] := vexparit2;
  TAS[vExparit,tid]^.elem[2] := vsec_exparit;
  TAS[vExparit,tid]^.cant := 2;

  //vExparit -> <ExpArit2> <sec_ExpArit>
  New(TAS[vExparit,tctereal]);
  TAS[vExparit,tctereal]^.elem[1] := vexparit2;
  TAS[vExparit,tctereal]^.elem[2] := vsec_exparit;
  TAS[vExparit,tctereal]^.cant := 2;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tpuntocoma]);
  TAS[vSec_ExpArit,tpuntocoma]^.cant := 0;


  //vSec_ExpArit -> <opArit> <ExpArit2> <sec_ExpArit>
  New(TAS[vSec_ExpArit,tsuma]);
  TAS[vSec_ExpArit,tsuma]^.elem[1] := vopArit;
  TAS[vSec_ExpArit,tsuma]^.elem[2] := vexparit2;
  TAS[vSec_ExpArit,tsuma]^.elem[3] := vsec_exparit;
  TAS[vSec_ExpArit,tsuma]^.cant := 3;

  //vSec_ExpArit -> <opArit> <ExpArit2> <sec_ExpArit>
  New(TAS[vSec_ExpArit,tresta]);
  TAS[vSec_ExpArit,tresta]^.elem[1] := vopArit;
  TAS[vSec_ExpArit,tresta]^.elem[2] := vexparit2;
  TAS[vSec_ExpArit,tresta]^.elem[3] := vsec_exparit;
  TAS[vSec_ExpArit,tresta]^.cant := 3;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tor]);
  TAS[vSec_ExpArit,tor]^.cant := 0;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tand]);
  TAS[vSec_ExpArit,tand]^.cant := 0;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tparcer]);
  TAS[vSec_ExpArit,tparcer]^.cant := 0;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tllavecer]);
  TAS[vSec_ExpArit,tllavecer]^.cant := 0;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tcorcer]);
  TAS[vSec_ExpArit,tcorcer]^.cant := 0;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tdospuntos]);
  TAS[vSec_ExpArit,tdospuntos]^.cant := 0;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,tto]);
  TAS[vSec_ExpArit,tto]^.cant := 0;

  //vSec_ExpArit -> epsilon
  New(TAS[vSec_ExpArit,toprel]);
  TAS[vSec_ExpArit,toprel]^.cant := 0;

  //vOpArit -> "+"
  New(TAS[vOpArit,tsuma]);
  TAS[vOpArit,tsuma]^.elem[1] := tsuma;
  TAS[vOpArit,tsuma]^.cant := 1;

  //vOpArit -> "-"
  New(TAS[vOpArit,tresta]);
  TAS[vOpArit,tresta]^.elem[1] := tresta;
  TAS[vOpArit,tresta]^.cant := 1;


  //vExpArit2 -> <ExpArit3> <sec_ExpArit2>
  New(TAS[vExpArit2,tresta]);
  TAS[vExpArit2,tresta]^.elem[1] := vExpArit3;
  TAS[vExpArit2,tresta]^.elem[2] := vSec_exparit2;
  TAS[vExpArit2,tresta]^.cant := 2;

  New(TAS[vExpArit2,tparab]);
  TAS[vExpArit2,tparab]^.elem[1] := vExpArit3;
  TAS[vExpArit2,tparab]^.elem[2] := vSec_exparit2;
  TAS[vExpArit2,tparab]^.cant := 2;

  New(TAS[vExpArit2,tid]);
  TAS[vExpArit2,tid]^.elem[1] := vExpArit3;
  TAS[vExpArit2,tid]^.elem[2] := vSec_exparit2;
  TAS[vExpArit2,tid]^.cant := 2;

  New(TAS[vExpArit2,tctereal]);
  TAS[vExpArit2,tctereal]^.elem[1] := vExpArit3;
  TAS[vExpArit2,tctereal]^.elem[2] := vsec_ExpArit2;
  TAS[vExpArit2,tctereal]^.cant := 2;


  //vOpArit2 -> “*”
  New(TAS[vOpArit2,tmultiplicacion]);
  TAS[vOpArit2,tmultiplicacion]^.elem[1] := tmultiplicacion;
  TAS[vOpArit2,tmultiplicacion]^.cant := 1;

  //vOpArit2 -> “/”
  New(TAS[vOpArit2,tdivision]);
  TAS[vOpArit2,tdivision]^.elem[1] := tdivision;
  TAS[vOpArit2,tdivision]^.cant := 1;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tpuntocoma]);
  TAS[vSec_ExpArit2,tpuntocoma]^.cant := 0;

  //vSec_ExpArit2 -> <opArit2> <ExpArit3> <vSec_ExpArit2>
  New(TAS[vSec_ExpArit2,tmultiplicacion]);
  TAS[vSec_ExpArit2,tmultiplicacion]^.elem[1] := vopArit2;
  TAS[vSec_ExpArit2,tmultiplicacion]^.elem[2] := vexparit3;
  TAS[vSec_ExpArit2,tmultiplicacion]^.elem[3] := vSec_ExpArit2;
  TAS[vSec_ExpArit2,tmultiplicacion]^.cant := 3;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tsuma]);
  TAS[vSec_ExpArit2,tsuma]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tresta]);
  TAS[vSec_ExpArit2,tresta]^.cant := 0;

  //vSec_ExpArit2 -> <opArit2> <ExpArit3> <vSec_ExpArit2>
  New(TAS[vSec_ExpArit2,tdivision]);
  TAS[vSec_ExpArit2,tdivision]^.elem[1] := vopArit2;
  TAS[vSec_ExpArit2,tdivision]^.elem[2] := vexparit3;
  TAS[vSec_ExpArit2,tdivision]^.elem[3] := vSec_ExpArit2;
  TAS[vSec_ExpArit2,tdivision]^.cant := 3;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tor]);
  TAS[vSec_ExpArit2,tor]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tand]);
  TAS[vSec_ExpArit2,tand]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tparcer]);
  TAS[vSec_ExpArit2,tparcer]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tllavecer]);
  TAS[vSec_ExpArit2,tllavecer]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tcorcer]);
  TAS[vSec_ExpArit2,tcorcer]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tdospuntos]);
  TAS[vSec_ExpArit2,tdospuntos]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,tto]);
  TAS[vSec_ExpArit2,tto]^.cant := 0;

  //vSec_ExpArit2 -> epsilon
  New(TAS[vSec_ExpArit2,toprel]);
  TAS[vSec_ExpArit2,toprel]^.cant := 0;


  //vExpArit3 -> <ExpArit4> <sec_ExpArit3>
  New(TAS[vExpArit3,tresta]);
  TAS[vExpArit3,tresta]^.elem[1] := vExpArit4;
  TAS[vExpArit3,tresta]^.elem[2] := vsec_ExpArit3;
  TAS[vExpArit3,tresta]^.cant := 2;


  //vExpArit3 -> <ExpArit4> <sec_ExpArit3>
  New(TAS[vExpArit3,tparab]);
  TAS[vExpArit3,tparab]^.elem[1] := vExpArit4;
  TAS[vExpArit3,tparab]^.elem[2] := vsec_ExpArit3;
  TAS[vExpArit3,tparab]^.cant := 2;


  //vExpArit3 -> <ExpArit4> <sec_ExpArit3>
  New(TAS[vExpArit3,tid]);
  TAS[vExpArit3,tid]^.elem[1] := vExpArit4;
  TAS[vExpArit3,tid]^.elem[2] := vsec_ExpArit3;
  TAS[vExpArit3,tid]^.cant := 2;

  //vExpArit3 -> <ExpArit4> <sec_ExpArit3>
  New(TAS[vExpArit3,tctereal]);
  TAS[vExpArit3,tctereal]^.elem[1] := vExpArit4;
  TAS[vExpArit3,tctereal]^.elem[2] := vsec_ExpArit3;
  TAS[vExpArit3,tctereal]^.cant := 2;


  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tsuma]);
  TAS[vSec_ExpArit3,tsuma]^.cant := 0;

  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tresta]);
  TAS[vSec_ExpArit3,tresta]^.cant := 0;

  //vSec_ExpArit3 -> <opArit3> <ExpArit4> <sec_ExpArit3>
  New(TAS[vSec_ExpArit3,tpotencia]);
  TAS[vSec_ExpArit3,tpotencia]^.elem[1] := vopArit3;
  TAS[vSec_ExpArit3,tpotencia]^.elem[2] := vExpArit4;
  TAS[vSec_ExpArit3,tpotencia]^.elem[3] := vsec_ExpArit3;
  TAS[vSec_ExpArit3,tpotencia]^.cant := 3;

  //vSec_ExpArit3 -> <opArit3> <ExpArit4> <sec_ExpArit3>
  New(TAS[vSec_ExpArit3,troot]);
  TAS[vSec_ExpArit3,troot]^.elem[1] := vopArit3;
  TAS[vSec_ExpArit3,troot]^.elem[2] := vExpArit4;
  TAS[vSec_ExpArit3,troot]^.elem[3] := vsec_ExpArit3;
  TAS[vSec_ExpArit3,troot]^.cant := 3;

  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tor]);
  TAS[vSec_ExpArit3,tor]^.cant := 0;

  New(TAS[vSec_ExpArit3,tmultiplicacion]);
  TAS[vSec_ExpArit3,tor]^.cant := 0;

  New(TAS[vSec_ExpArit3,tdivision]);
  TAS[vSec_ExpArit3,tor]^.cant := 0;

  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tand]);
  TAS[vSec_ExpArit3,tand]^.cant := 0;


  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,toprel]);
  TAS[vSec_ExpArit3,toprel]^.cant := 0;

  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tparcer]);
  TAS[vSec_ExpArit3,tparcer]^.cant := 0;


  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tcorcer]);
  TAS[vSec_ExpArit3,tcorcer]^.cant := 0;


  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tllavecer]);
  TAS[vSec_ExpArit3,tllavecer]^.cant := 0;


  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tdospuntos]);
  TAS[vSec_ExpArit3,tdospuntos]^.cant := 0;

  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tpuntocoma]);
  TAS[vSec_ExpArit3,tpuntocoma]^.cant := 0;

  //vSec_ExpArit3 -> epsilon
  New(TAS[vSec_ExpArit3,tto]);
  TAS[vSec_ExpArit3,tto]^.cant := 0;

  //vOpArit3  “^”
  New(TAS[vOpArit3,tpotencia]);
  TAS[vOpArit3,tpotencia]^.elem[1] := tpotencia;
  TAS[vOpArit3,tpotencia]^.cant := 1;

  //vOpArit3  “root”
  New(TAS[vOpArit3,troot]);
  TAS[vOpArit3,troot]^.elem[1] := troot;
  TAS[vOpArit3,troot]^.cant := 1;

  //vExpArit4 -> "-"<ExpArit4>
  New(TAS[vExpArit4,tresta]);
  TAS[vExpArit4,tresta]^.elem[1] := tresta;
  TAS[vExpArit4,tresta]^.elem[2] := vexparit4;
  TAS[vExpArit4,tresta]^.cant := 2;

  //vExpArit4 -> “(“<ExpArit>”)”
  New(TAS[vExpArit4,tparab]);
  TAS[vExpArit4,tparab]^.elem[1] := tparab;
  TAS[vExpArit4,tparab]^.elem[2] := vexparit;
  TAS[vExpArit4,tparab]^.elem[3] := tparcer;
  TAS[vExpArit4,tparab]^.cant := 3;

  //vExpArit4 -> “id” <indice>
  New(TAS[vExpArit4,tid]);
  TAS[vExpArit4,tid]^.elem[1] := tid;
  TAS[vExpArit4,tid]^.elem[2] := vindice;
  TAS[vExpArit4,tid]^.cant := 2;

  //vExpArit4 -> “cteReal”
  New(TAS[vExpArit4,tctereal]);
  TAS[vExpArit4,tctereal]^.elem[1] := tcteReal;
  TAS[vExpArit4,tctereal]^.cant := 1;


  // and,or,},;,),],to,:,opRel,  +,-,*,/,^,root
  //vIndice -> epsilon
  New(TAS[vIndice,tand]);
  TAS[vIndice,tand]^.cant := 0;

  New(TAS[vIndice,tasignacion]);
  TAS[vIndice,tasignacion]^.cant := 0;

  New(TAS[vIndice,tor]);
  TAS[vIndice,tor]^.cant := 0;

  New(TAS[vIndice,tllavecer]);
  TAS[vIndice,tllavecer]^.cant := 0;

  New(TAS[vIndice,tpuntocoma]);
  TAS[vIndice,tpuntocoma]^.cant := 0;

  New(TAS[vIndice,tparcer]);
  TAS[vIndice,tparcer]^.cant := 0;

  New(TAS[vIndice,tcorcer]);
  TAS[vIndice,tcorcer]^.cant := 0;

  New(TAS[vIndice,tto]);
  TAS[vIndice,tto]^.cant := 0;

  New(TAS[vIndice,tdospuntos]);
  TAS[vIndice,tdospuntos]^.cant := 0;


  New(TAS[vIndice,toprel]);
  TAS[vIndice,toprel]^.cant := 0;

  New(TAS[vIndice,tsuma]);
  TAS[vIndice,tsuma]^.cant := 0;

  New(TAS[vIndice,tresta]);
  TAS[vIndice,tresta]^.cant := 0;

  New(TAS[vIndice,tmultiplicacion]);
  TAS[vIndice,tmultiplicacion]^.cant := 0;

  New(TAS[vIndice,tdivision]);
  TAS[vIndice,tdivision]^.cant := 0;

  New(TAS[vIndice,tpotencia]);
  TAS[vIndice,tpotencia]^.cant := 0;

  New(TAS[vIndice,troot]);
  TAS[vIndice,troot]^.cant := 0;

  //vIndice -> “[“<expArit>”]”
  New(TAS[vIndice,tcorab]);
  TAS[vIndice,tcorab]^.elem[1] := tcorab;
  TAS[vIndice,tcorab]^.elem[2] := vExpArit;
  TAS[vIndice,tcorab]^.elem[3] := tcorcer;
  TAS[vIndice,tcorab]^.cant := 3;



  // vcteArreglo-> [<arreglo>]
  New(Tas[vcteArreglo,tcorab]);
  Tas[vcteArreglo,tcorab]^.elem[1] := tcorab;
  Tas[vcteArreglo,tcorab]^.elem[2] := varreglo;
  Tas[vcteArreglo,tcorab]^.elem[3] := tcorcer;
  Tas[vcteArreglo,tcorab]^.cant := 3;

  //varreglo-> tctereal <post_arreglo>
  New(Tas[varreglo,tctereal]);
  Tas[varreglo,tctereal]^.elem[1] := tctereal;
  Tas[varreglo,tctereal]^.elem[2] := vpost_arreglo;
  Tas[varreglo,tctereal]^.cant := 2;

  //vpost_arreglo-> "," <arreglo>

  New(Tas[vpost_arreglo,tcoma]);
  Tas[vpost_arreglo,tcoma]^.elem[1] := tcoma;
  Tas[vpost_arreglo,tcoma]^.elem[2] := varreglo;
  Tas[vpost_arreglo,tcoma]^.cant := 2;

  //vpost_arreglo-> epsilon
  New(Tas[vpost_arreglo,tcorcer]);
  Tas[vpost_arreglo,tcorcer]^.cant := 0;

  //vciclo -> "while" <condicion> ":" "{"<cuerpo>"}"

  New(Tas[vciclo,twhile]);
  Tas[vciclo, twhile]^.elem[1] := twhile;
  Tas[vciclo, twhile]^.elem[2] := vcondicion;
  Tas[vciclo, twhile]^.elem[3] := tdospuntos;
  Tas[vciclo, twhile]^.elem[4] := tllaveab;
  Tas[vciclo, twhile]^.elem[5] := vcuerpo;
  Tas[vciclo, twhile]^.elem[6] := tllavecer;
  Tas[vciclo, twhile]^.cant := 6;

  //vciclo -> for" "id" "=" <expArit> "to" <expArit> ":" "{" <cuerpo> "}"
  New(Tas[vciclo,tfor]);
  Tas[vciclo, tfor]^.elem[1] := tfor;
  Tas[vciclo, tfor]^.elem[2] := tid;
  Tas[vciclo, tfor]^.elem[3] := tasignacion;
  Tas[vciclo, tfor]^.elem[4] := vexpArit;
  Tas[vciclo, tfor]^.elem[5] := tto;
  Tas[vciclo, tfor]^.elem[6] := vexpArit;
  Tas[vciclo, tfor]^.elem[7] := tdospuntos;
  Tas[vciclo, tfor]^.elem[8] := tllaveab;
  Tas[vciclo, tfor]^.elem[9] := vcuerpo;
  Tas[vciclo, tfor]^.elem[10] := tllavecer;
  Tas[vciclo, tfor]^.cant := 10;

  //vcondicional -> "if" <condicion> ":" "{" <cuerpo> "}" <else_condicional>
  New(Tas[vcondicional,tif]);
  Tas[vcondicional, tif]^.elem[1] := tif;
  Tas[vcondicional, tif]^.elem[2] := vcondicion;
  Tas[vcondicional, tif]^.elem[3] := tdospuntos;
  Tas[vcondicional, tif]^.elem[4] := tllaveab;
  Tas[vcondicional, tif]^.elem[5] := vcuerpo;
  Tas[vcondicional, tif]^.elem[6] := tllavecer;
  Tas[vcondicional, tif]^.elem[7] := velse_condicional;
  Tas[vcondicional, tif]^.cant := 7;

  //velse_condicional-> "else" "{" <cuerpo> "}"
  New(Tas[velse_condicional,telse]);
  Tas[velse_condicional, telse]^.elem[1] := telse;
  Tas[velse_condicional, telse]^.elem[2] := tllaveab;
  Tas[velse_condicional, telse]^.elem[3] := vcuerpo;
  Tas[velse_condicional, telse]^.elem[4] := tllavecer;
  Tas[velse_condicional, telse]^.cant := 4;

  //velse_condicional-> epsilon
  New(Tas[velse_condicional,tif]);
  Tas[velse_condicional,tif]^.cant := 0;
  New(Tas[velse_condicional,twhile]);
  Tas[velse_condicional,twhile]^.cant := 0;
  New(Tas[velse_condicional,tfor]);
  Tas[velse_condicional,tfor]^.cant := 0;
  New(Tas[velse_condicional,tsysOut]);
  Tas[velse_condicional,tsysOut]^.cant := 0;
  New(Tas[velse_condicional,tsysGet]);
  Tas[velse_condicional,tsysGet]^.cant := 0;
  New(Tas[velse_condicional,tid]);
  Tas[velse_condicional,tid]^.cant := 0;
  New(Tas[velse_condicional,tllavecer]);
  Tas[velse_condicional,tllavecer]^.cant := 0;


  //vexpRel -> <expArit> "opRel" <expArit>
  New(Tas[vexpRel,tresta]);
  Tas[vexpRel,tresta]^.elem[1] := vexpArit;
  Tas[vexpRel,tresta]^.elem[2] := topRel;
  Tas[vexpRel,tresta]^.elem[3] := vexpArit;
  Tas[vexpRel,tresta]^.cant := 3;


  New(Tas[vexpRel,tparab]);
  Tas[vexpRel,tparab]^.elem[1] := vexpArit;
  Tas[vexpRel,tparab]^.elem[2] := topRel;
  Tas[vexpRel,tparab]^.elem[3] := vexpArit;
  Tas[vexpRel,tparab]^.cant := 3;


  New(Tas[vexpRel,tid]);
  Tas[vexpRel,tid]^.elem[1] := vexpArit;
  Tas[vexpRel,tid]^.elem[2] := topRel;
  Tas[vexpRel,tid]^.elem[3] := vexpArit;
  Tas[vexpRel,tid]^.cant := 3;

  New(Tas[vexpRel,tcteReal]);
  Tas[vexpRel,tcteReal]^.elem[1] := vexpArit;
  Tas[vexpRel,tcteReal]^.elem[2] := topRel;
  Tas[vexpRel,tcteReal]^.elem[3] := vexpArit;
  Tas[vexpRel,tcteReal]^.cant := 3;

  // <condicion> -> <condicionAnidada> <sec_condicion>
  New(Tas[vcondicion, tresta]);
  Tas[vcondicion, tresta]^.elem[1] := vcondicionAnidada;
  Tas[vcondicion, tresta]^.elem[2] := vsec_condicion;
  Tas[vcondicion, tresta]^.cant := 2;

  New(Tas[vcondicion, tnot]);
  Tas[vcondicion, tnot]^.elem[1] := vcondicionAnidada;
  Tas[vcondicion, tnot]^.elem[2] := vsec_condicion;
  Tas[vcondicion, tnot]^.cant := 2;

  New(Tas[vcondicion, tparab]);
  Tas[vcondicion, tparab]^.elem[1] := vcondicionAnidada;
  Tas[vcondicion, tparab]^.elem[2] := vsec_condicion;
  Tas[vcondicion, tparab]^.cant := 2;


  New(Tas[vcondicion, tllaveab]);
  Tas[vcondicion, tllaveab]^.elem[1] := vcondicionAnidada;
  Tas[vcondicion, tllaveab]^.elem[2] := vsec_condicion;
  Tas[vcondicion, tllaveab]^.cant := 2;


  New(Tas[vcondicion, tid]);
  Tas[vcondicion, tid]^.elem[1] := vcondicionAnidada;
  Tas[vcondicion, tid]^.elem[2] := vsec_condicion;
  Tas[vcondicion, tid]^.cant := 2;


  New(Tas[vcondicion, tctereal]);
  Tas[vcondicion, tctereal]^.elem[1] := vcondicionAnidada;
  Tas[vcondicion, tctereal]^.elem[2] := vsec_condicion;
  Tas[vcondicion, tctereal]^.cant := 2;


  //vSec_condicion -> “or” <CondicionAnidada> <sec_condicion>
  New(TAS[vSec_condicion,tor]);
  TAS[vSec_condicion,tor]^.elem[1] := tor;
  TAS[vSec_condicion,tor]^.elem[2] := vCondicionAnidada;
  TAS[vSec_condicion,tor]^.elem[3] := vSec_condicion;
  TAS[vSec_condicion,tor]^.cant := 3;

  //vSec_condicion -> epsilon
  New(TAS[vSec_condicion,tllavecer]);
  TAS[vSec_condicion, tllavecer]^.cant := 0;

  //vSec_condicion -> epsilon
  New(TAS[vSec_condicion,tdospuntos]);
  TAS[vSec_condicion, tdospuntos]^.cant := 0;

  //vCondicionAnidada -> <pre_condicionAnidada> <sec_condicionAnidada>
  New(TAS[vCondicionAnidada, tresta]);
  TAS[vCondicionAnidada, tresta]^.elem[1] := vPre_condicionAnidada;
  TAS[vCondicionAnidada, tresta]^.elem[2] := vSec_condicionAnidada;
  TAS[vCondicionAnidada, tresta]^.cant := 2;


  //vCondicionAnidada -> <pre_condicionAnidada> <sec_condicionAnidada>
  New(TAS[vCondicionAnidada, tnot]);
  TAS[vCondicionAnidada, tnot]^.elem[1] := vPre_condicionAnidada;
  TAS[vCondicionAnidada, tnot]^.elem[2] := vSec_condicionAnidada;
  TAS[vCondicionAnidada, tnot]^.cant := 2;

  //vCondicionAnidada -> <pre_condicionAnidada> <sec_condicionAnidada>
  New(TAS[vCondicionAnidada, tparab]);
  TAS[vCondicionAnidada, tparab]^.elem[1] := vPre_condicionAnidada;
  TAS[vCondicionAnidada, tparab]^.elem[2] := vSec_condicionAnidada;
  TAS[vCondicionAnidada, tparab]^.cant := 2;

  New(TAS[vCondicionAnidada, tllaveab]);
  TAS[vCondicionAnidada, tllaveab]^.elem[1] := vPre_condicionAnidada;
  TAS[vCondicionAnidada, tllaveab]^.elem[2] := vSec_condicionAnidada;
  TAS[vCondicionAnidada, tllaveab]^.cant := 2;


  //vCondicionAnidada -> <pre_condicionAnidada> <sec_condicionAnidada>
  New(TAS[vCondicionAnidada, tcorab]);
  TAS[vCondicionAnidada, tcorab]^.elem[1] := vPre_condicionAnidada;
  TAS[vCondicionAnidada, tcorab]^.elem[2] := vSec_condicionAnidada;
  TAS[vCondicionAnidada, tcorab]^.cant := 2;

  //vCondicionAnidada -> <pre_condicionAnidada> <sec_condicionAnidada>
  New(TAS[vCondicionAnidada, tid]);
  TAS[vCondicionAnidada, tid]^.elem[1] := vPre_condicionAnidada;
  TAS[vCondicionAnidada, tid]^.elem[2] := vSec_condicionAnidada;
  TAS[vCondicionAnidada, tid]^.cant := 2;


  //vCondicionAnidada -> <pre_condicionAnidada> <sec_condicionAnidada>
  New(TAS[vCondicionAnidada, tctereal]);
  TAS[vCondicionAnidada, tctereal]^.elem[1] := vPre_condicionAnidada;
  TAS[vCondicionAnidada, tctereal]^.elem[2] := vSec_condicionAnidada;
  TAS[vCondicionAnidada, tctereal]^.cant := 2;

  //vPre_condicionAnidada -> <expRel>
  New(TAS[vPre_condicionAnidada, tresta]);
  TAS[vPre_condicionAnidada, tresta]^.elem[1] := vExpRel;
  TAS[vPre_condicionAnidada, tresta]^.cant := 1;

  //vPre_condicionAnidada -> “not” <pre_condicionAnidada>
  New(TAS[vPre_condicionAnidada, tnot]);
  TAS[vPre_condicionAnidada, tnot]^.elem[1] := tnot;
  TAS[vPre_condicionAnidada, tnot]^.elem[2] := vPre_condicionAnidada;
  TAS[vPre_condicionAnidada, tnot]^.cant := 2;

  //vPre_condicionAnidada -> <expRel>
  New(TAS[vPre_condicionAnidada, tparab]);
  TAS[vPre_condicionAnidada, tparab]^.elem[1] := vExpRel;
  TAS[vPre_condicionAnidada, tparab]^.cant := 1;


  //vPre_condicionAnidada -> ”{”<condicion>”}”
  New(TAS[vPre_condicionAnidada, tllaveab]);
  TAS[vPre_condicionAnidada, tllaveab]^.elem[1] := tllaveab;
  TAS[vPre_condicionAnidada, tllaveab]^.elem[2] := vCondicion;
  TAS[vPre_condicionAnidada, tllaveab]^.elem[3] := tllavecer;
  TAS[vPre_condicionAnidada, tllaveab]^.cant := 3;


  //vPre_condicionAnidada -> <expRel>
  New(TAS[vPre_condicionAnidada, tid]);
  TAS[vPre_condicionAnidada, tid]^.elem[1] := vExpRel;
  TAS[vPre_condicionAnidada, tid]^.cant := 1;

  //vPre_condicionAnidada -> <expRel>
  New(TAS[vPre_condicionAnidada, tctereal]);
  TAS[vPre_condicionAnidada, tctereal]^.elem[1] := vExpRel;
  TAS[vPre_condicionAnidada, tctereal]^.cant := 1;

  //vSec_condicionAnidada -> epsilon
  New(TAS[vSec_condicionAnidada, tor]);
  TAS[vSec_condicionAnidada, tor]^.cant := 0;


//vSec_condicionAnidada -> “and” <pre_condicionAnidada> <sec_condicionAnidada>
  New(TAS[vSec_condicionAnidada, tand]);
  TAS[vSec_condicionAnidada, tand]^.elem[1] := tand;
  TAS[vSec_condicionAnidada, tand]^.elem[2] := vPre_condicionAnidada;
  TAS[vSec_condicionAnidada, tand]^.elem[3] := vSec_condicionAnidada;
  TAS[vSec_condicionAnidada, tand]^.cant := 3;

  //vSec_condicionAnidada -> epsilon
  New(TAS[vSec_condicionAnidada, tllavecer]);
  TAS[vSec_condicionAnidada, tllavecer]^.cant := 0;

  //vSec_condicionAnidada -> epsilon
  New(TAS[vSec_condicionAnidada, tdospuntos]);
  TAS[vSec_condicionAnidada, tdospuntos]^.cant := 0;

  //vLectura -> “sysGet” ”(“ ”cteCadena” “,” ”id” ”)”
  New(TAS[vLectura,tsysGet]);
  TAS[vLectura, tsysGet]^.elem[1] := tsysGet;
  TAS[vLectura, tsysGet]^.elem[2] := tparab;
  TAS[vLectura, tsysGet]^.elem[3] := tctecadena;
  TAS[vLectura, tsysGet]^.elem[4] := tcoma;
  TAS[vLectura, tsysGet]^.elem[5] := tid;
  TAS[vLectura, tsysGet]^.elem[6] := tparcer;
  TAS[vLectura, tsysGet]^.cant := 6;

  //vescritura-> “sysOut” ”(“<varEscritura>”)”
  New(TAS[vescritura, tsysOut]);
  TAS[vescritura, tsysOut]^.elem[1] := tsysOut;
  TAS[vescritura, tsysOut]^.elem[2] := tparab;
  TAS[vescritura, tsysOut]^.elem[3] := vVarEscritura;
  TAS[vescritura, tsysOut]^.elem[4] := tparcer;
  TAS[vescritura, tsysOut]^.cant := 4;

  // //vVarEscritura -> <cteArreglo><post_varEscritura> -> producción eliminada
  // New(TAS[vVarEscritura, tcorab]);
  // TAS[vVarEscritura, tcorab]^.elem[1] := vCteArreglo;
  // TAS[vVarEscritura, tcorab]^.elem[2] := vPost_varEscritura;
  // TAS[vVarEscritura, tcorab]^.cant := 2;

  //vVarEscritura -> <expArit><post_varEscritura>
  New(TAS[vVarEscritura, tresta]);
  TAS[vVarEscritura, tresta]^.elem[1] := vExpArit;
  TAS[vVarEscritura, tresta]^.elem[2] := vPost_varEscritura;
  TAS[vVarEscritura, tresta]^.cant := 2;

  //vVarEscritura -> <expArit><post_varEscritura>
  New(TAS[vVarEscritura, tparab]);
  TAS[vVarEscritura, tparab]^.elem[1] := vExpArit;
  TAS[vVarEscritura, tparab]^.elem[2] := vPost_varEscritura;
  TAS[vVarEscritura, tparab]^.cant := 2;

  //vVarEscritura -> <expArit><post_varEscritura>
  New(TAS[vVarEscritura, tid]);
  TAS[vVarEscritura, tid]^.elem[1] := vExpArit;
  TAS[vVarEscritura, tid]^.elem[2] := vPost_varEscritura;
  TAS[vVarEscritura, tid]^.cant := 2;
  //vVarEscritura -> <expArit><post_varEscritura>
  New(TAS[vVarEscritura, tctereal]);
  TAS[vVarEscritura, tctereal]^.elem[1] := vExpArit;
  TAS[vVarEscritura, tctereal]^.elem[2] := vPost_varEscritura;
  TAS[vVarEscritura, tctereal]^.cant := 2;

  //vVarEscritura -> “cteCadena”<post_varEscritura>
  New(TAS[vVarEscritura, tctecadena]);
  TAS[vVarEscritura, tctecadena]^.elem[1] := tctecadena;
  TAS[vVarEscritura, tctecadena]^.elem[2] := vPost_varEscritura;
  TAS[vVarEscritura, tctecadena]^.cant := 2;

  //vPost_varEscritura-> ”,” <varEscritura>
  New(TAS[vPost_varEscritura, tcoma]);
  TAS[vPost_varEscritura, tcoma]^.elem[1] := tcoma;
  TAS[vPost_varEscritura, tcoma]^.elem[2] := vVarEscritura;
  TAS[vPost_varEscritura, tcoma]^.cant := 2;

  //vPost_varEscritura-> epsilon
  New(TAS[vPost_varEscritura, tparcer]);
  TAS[vPost_varEscritura, tparcer]^.cant := 0;

End;

Procedure mostrarTAS(TAS: TipoTAS);

Var i,j: tipoSimboloGramatical;
  h: Byte;
Begin

  cargarTAS(TAS);
  For i:=vPrograma To vPost_varEscritura Do
    Begin
      writeln;
      Write(i, '-> ');
      For j:=tprogram To pesos Do
        Begin
          If TAS[i,j] <> Nil Then
            Begin
              write (j, ' ( ');
              If TAS[i,j]^.cant <> 0 Then
                Begin
                  For h:= 1 To TAS[i,j]^.cant Do
                    Begin
                      write(TAS[i,j]^.elem[h], ' ');
                    End;
                End
              Else write('Ɛ ');
              //Write(j, ' (', TAS[i,j]^.cant, ') ', '| ');
              write (') | ');
              //matriz[i, j]^.elem[3]);
            End;
        End;
      writeln;
    End;

End;

Procedure analizadorPredictivo(rutaFuente : String; Var arbol: TApuntNodo; Var error:boolean);
Var 
  control: longint;
  TS: TablaDeSimbolos;
  TAS: TipoTAS;
  Pila: TipoPila;
  Estado: (enproceso, errorSintactico, Exito);
  EPila: TipoElemPila;
  Fuente: FileOfChar;
  Complex: TipoSimboloGramatical;
  Lexema: string;
  I: 0..MaxProd;
  Auxiliar: TipoSimboloGramatical;
  Auxiliar2: TapuntNodo;
Begin
  assign(fuente,rutaFuente);
  reset(fuente);
  //creamos y cargamos tanto TS como TAS y pila
  crearLista(TS);
  cargarTS(TS);
  cargarTAS(TAS);
  //iniciamos pila
  crearPila(Pila);
  //iniciamos arbol
  crearNodo(VPrograma,arbol);

  //apilamos $
  Epila.simbolo := pesos;
  epila.nodoarbol := Nil;
  apilar(pila,epila);

  //apilamos primer símbolo
  epila.simbolo := vprograma;
  epila.nodoarbol := arbol;
  apilar(pila,epila);


  //obtenemos complex
  control := 0;
  obtenerSiguienteComplex(fuente,control,complex,lexema,TS);

  estado := enproceso;
  While (estado=enproceso) Do
    Begin
      desapilar(pila,epila);

      If epila.simbolo In [tprogram..tctecadena] Then   // x es terminal?
        Begin
          If epila.simbolo = complex Then
            Begin
              epila.Nodoarbol^.lexema := lexema;
              ObtenerSiguienteComplex(fuente,control,complex,lexema,TS);
            End
          Else
            Begin
              Estado := errorSintactico;
              writeln('error sintáctico: se esperaba ', epila.Simbolo,
                      ' y se encontró ',complex);
              writeln(control);
              error := true;
            End;
        End;
      If epila.simbolo In [vprograma..vPost_varEscritura] Then
        Begin
          If TAS[epila.simbolo,complex] = Nil Then
            Begin
              estado := errorSintactico;
              writeln('error sintáctico: se esperaba ',epila.simbolo,
                      ' y se encontró ', complex);
              writeln(control);
              error := true;
            End
          Else
            Begin
              For i:= 1 To TAS[epila.Simbolo, complex]^.cant Do
                Begin
                  auxiliar := TAS[epila.Simbolo,complex]^.elem[i];
                  crearNodo(Auxiliar,auxiliar2);
                  agregarHijo(epila.NodoArbol,auxiliar2);
                End;
              apilarTodos(TAS[epila.Simbolo,complex]^, epila.NodoArbol,Pila);
            End;
        End
      Else
        Begin
          If (complex = pesos) And (epila.Simbolo = pesos) Then
            Begin
              estado := exito;
              error := false;
            End;
        End;
    End;

End;

Procedure guardarNodo(Var arch:text ; Var arbol: tapuntnodo; desplazamiento: String);

Var 
  i: byte;
Begin
 // writeln(desplazamiento,arbol^.simbolo,' (',arbol^.lexema,')');
  For i:=1 To arbol^.hijos.cant Do
    guardarNodo(arch,arbol^.hijos.elem[i],desplazamiento+'  ');
End;

Procedure guardarArbol(ruta: String;Var arbol: tapuntnodo);

Var 
  arch: text;
Begin
  assign(arch,ruta);
  rewrite(arch);
  guardarNodo(arch,arbol,'');
  close(arch);
End;
End.
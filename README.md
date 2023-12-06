# Cygnus 🦢
Cygnus es un interprete hecho en pascal para un lenguaje de programación con características específicas. Tiene un analizador léxico, un analizador semántico y un analizador sintáctico

## Estructura general

Un programa consiste de una secuencia de sentencias, la cual comienza por un program id, donde id es el nombre del programa.
Luego de declarar la id, declararemos las variables necesarias para utilizar en el programa, para posteriormente comenzar con el cuerpo del programa. Esto lo hacemos mediante la palabra reservada body seguida de {}, que delimitan el contenido del cuerpo del programa.

## Tipos de sentencia

Declaración: Para declarar una variable previo al cuerpo del programa, utilizamos la palabra reservada var, para posteriormente declarar las variables de la forma id = real; en caso de querer declarar un número, o id = array[n]; en caso de querer declarar un vector siendo n un número real transformado mediante la funcion techo a un número entero

Asignación: Para asignarle un valor a una variable ya declarada, debe realizarse dentro del cuerpo “body” y se escribe id = “constante real”. En el caso de querer tratarse con arrays, tenemos dos tipos de asignación posible, una donde asignamos en una posición específica del array: id[n]= “constante real” (con n siendo un número real transformado mediante la funcion techo a un número entero) u otra donde podemos asignar los elementos de un array directamente: id = [“constante real_1”, “constante real_2”, …, “constante real_m”];.

Lectura: Para almacenar un dato ingresado en pantalla en una variable indicada, utilizamos sysGet(“cadenaDeTexto”, id);. De esta manera, almacenamos el contenido de “cadenaDeTexto” en la variable id. Aclarar que este id debe de ser declarado previo al comienzo del body.

Escritura: Para imprimir por pantalla, utilizamos sysOut(“cadenaDeTexto”, id);, siendo id el valor que deseamos imprimir concatenado a la “cadenaDeTexto”.

Ciclo: Contamos con dos ciclos diferentes, los cuales son for y while. 
Utilizamos el for lo utilizamos de la siguiente manera: for i = m to n : {}. m es un número, y n es una variable real declarada previamente al comienzo del ciclo. Dentro de las llaves se encuentra la secuencia a ejecutar. En cuanto al while, lo utilizamos de la siguiente manera: while “condicion” : {}. El funcionamiento es que, al cumplirse la condición, se ejecutan las líneas de código dentro de las llaves.

Condicional: La estructura del condicional es definida por if “condición” : {}, donde, si se cumple la condición, procederemos a ejecutar la secuencia dentro de las llaves.
Ej:
 if max < num : {
            max = num;
 }}

## Expresiones aritméticas, lógicas y relacionales

Expresiones lógicas: Las expresiones lógicas son and (y), or (o) y not (negación).

Expresiones aritméticas:	 
Los operadores aritméticos son * (multiplicación), / (división), + (suma), - (resta), ^ (potencia) y root (raíz). El uso de ^ es : “constanteReal”^“constanteReal”.
El uso de root es: “exponente” root “constanteReal”.
Ej de root: Si se quiere realizar la raíz quinta de 10, lo que haremos es: 5 root 10. 

Operadores relacionales: Los operadores relacionales son < (menor), > (mayor), <= (menos o igual), >= (mayor o igual), != (distinto que) y == (comparación). Mencionar que “=” es distinto que “==”, ya que “=” lo usamos para la asignación y “==” para la comparación.

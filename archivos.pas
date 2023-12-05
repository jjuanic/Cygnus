unit archivos;
interface
uses tipos;
const
  ruta='C:\Users\juan-\OneDrive\Escritorio\Facultad\Segundo\CygnusGIT\Cygnus\codigo.cyg';
Procedure LeerCar (var fuente: FileOfChar; var control: Longint ; var Car:char);
Procedure abrirArchivo(var arch: FileOfChar);
Procedure cerrarArchivo(var arch:FileOfChar);

implementation
Procedure abrirArchivo(var arch: FileOfChar);
begin
     assign(arch,ruta);
     reset(arch);
     end;
Procedure cerrarArchivo(var arch:FileOfChar);
begin
     close(arch);
     end;
Procedure LeerCar (var fuente: FileOfChar; var control: Longint ; var Car:char);
begin
     seek(fuente,control);
     if not Eof(fuente) then read(fuente,car) else car:=#0;
end;

end.


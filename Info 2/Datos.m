%% Ecuación de transeferencia
% Se hace inicialmente de manera simbolica para comprobar la ecuación
syms s F Fo cs cp R x1 x
%Se inician las ecuaciones
eqn1=R*s*(x1-x)+(1/cs)*x1==Fo;
eqn2=R*s*(x-x1)+(1/cp)*x==F-Fo;
sol=solve([eqn1,eqn2],[x,x1]); %Se soluciona el sistema
xsol=sol.x %Se muestra la solución con respecto a x
%% Variables normales
%Se inician las variables iniciales del problema
R=0.5;
cs=0.2;
cp=2;
t=0.1:0.1:20; %Se inicia el tiempo
%Se inician los impulsos
F=(0<t)*90;
Fo=(0<t)*90;
simin=[t.' F.' Fo.'];
%% Simular con circuito electrico
% Se simula contra el circuito electrico correspondiente para comprobar la
% validez de la ecuación encontrada teoricamente.
out=simular(R,cs,cp,max(t));
%% Condiciones iniciales de pruebas
%Para mayor control desde el codigo se decide por ingresar los datos desde
%aqui
t=0.1:0.1:20; %Se inicia el tiempo
%Se inician las fuerzas como impulsos de la forma que se pueda variar si se
%requiere
p=10; %Peso del objeto
g=9.81; %Gravedad
c=0.8; %Proporcionalidad dependiendo de la elongación de los sarcomeros
F=((0<t) & (t<5))*p*g;
Fo=((0<t) & (t<5))*p*g*c;
%Se crea el vector de entrada a la simulación
simin=[t.' F.' Fo.'];
%% comparar datos 2 subplots
a=[0.5 0.2 2];
b=[0.75 0.314 3.14];
[out,out2]=comparedata(a,b,10);

%% Comparar datos legend
a=[0.5 0.2 2];
b=[0.75 0.314 3.14];
[out,out2]=comparedata2(a,b,15);
%% Funciones
%Para hacer el proceso más eficiente se crean varias funciones debido a que
%se va a realizar las mismas operaciones constantemente
function out=simular(R,cs,cp,time)
out=sim("Modelo_Circuito.slx","StopTime",num2str(time)); %Se simula el sistema y se guarda su out
figure(1)
%Desde simulik se le da la orden al diagrama de bode de enviarse al
%workspace este lo envia como un ss así que usando la misma función se
%puede graficar de la misma manera
bode(out.bodegraf.values) 
grid on
figure(2)
% Se extraen los valores de simulink
x=out.simout.signals.values(:,2);
y=out.simout.time;
%Se grafican los valores de su respectivo bloque conociendo la extructura
%del mux
subplot(2,1,1)
plot(y,x)
title("Respuesta x circuito electrico")
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
subplot(2,1,2)
x2=out.simout.signals.values(:,1);
plot(y,x2)
title("Respuesta x función de transferencia")
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
end
function [out,out2] =comparedata(a,b,time)
%Para comparar inicialmente se crean los subtitulos para cada paciente
sub1="R: "+num2str(a(1))+" cs: "+num2str(a(2))+" cp: "+num2str(a(3));
sub2="R: "+num2str(b(1))+" cs: "+num2str(b(2))+" cp: "+num2str(b(3));
%Se evaluan los valores en el workspace
evaluator(a(1),a(2),a(3))
%Se simula el modelo con las primeras variables
out=sim("Modelo_Circuito.slx","StopTime",num2str(time));
%Se grafica el diagrama de bode
figure(1)
bode(out.bodegraf.values)
title(["Diagrama de Bode paciente 1",sub1])
grid on
%Se evaluan las segundas condiciones en el workspace
evaluator(b(1),b(2),b(3))
out2=sim("Modelo_Circuito.slx","StopTime",num2str(time));
%Se grafica el diagrama de bode para el segundo set de variables
figure(2)
bode(out2.bodegraf.values)
title(["Diagrama de Bode paciente 2",sub2])
grid on
%Se extraen los valores
x=out.simout.signals.values(:,1);
y=out.simout.time;
%Se grafican los datos en un subplot 
figure()
subplot(2,1,1)
plot(y,x)
title("Respuesta x paciente")
subtitle(sub1) %Se le agreaga un subtitulo para mejor identificación
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
subplot(2,1,2)
x2=out2.simout.signals.values(:,1);
y2=out2.simout.time;
plot(y2,x2)
title("Respuesta x paciente")
subtitle(sub2)
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
end
function [out,out2] =comparedata2(a,b,time)
%En este caso esta función es similar a la anterior
sub1="R: "+num2str(a(1))+" cs: "+num2str(a(2))+" cp: "+num2str(a(3));
sub2="R: "+num2str(b(1))+" cs: "+num2str(b(2))+" cp: "+num2str(b(3));
evaluator(a(1),a(2),a(3))
out=sim("Modelo_Circuito.slx","StopTime",num2str(time));
figure(1)
bode(out.bodegraf.values)
title(["Diagrama de Bode paciente 1",sub1])
grid on
evaluator(b(1),b(2),b(3))
out2=sim("Modelo_Circuito.slx","StopTime",num2str(time));
figure(2)
bode(out2.bodegraf.values)
title(["Diagrama de Bode paciente 2",sub2])
grid on
x=out.simout.signals.values(:,1);
y=out.simout.time;
%En este caso la diferencia es que se hace un solo grafico para una mejor
%comparación de la grafica
figure()
plot(y,x)
hold on
title("Respuesta x paciente")
xlabel("tiempo(s)")
ylabel("Desplazamiento (m)")
x2=out2.simout.signals.values(:,1);
y2=out2.simout.time;
plot(y2,x2,"--r")
title("Respuesta x paciente")
legend(sub1,sub2)
end
function evaluator(R,cs,cp)
%Esta función permite evaluar las constantes en el workspace, debido a que
%cuando se simula este toma los valores que esten en este, en si se envia
%una linea de codigo para escribirla en la command window, así garatizando
%que aun dentro de las funciones las variables cambien.
evalin("base","R="+num2str(R)+";"+"cs="+num2str(cs)+";"+"cp="+num2str(cp)+";");
end

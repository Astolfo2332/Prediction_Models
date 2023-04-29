clc;clear vars;close all;clear all;
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
F=(0<t)*1;
Fo=(0<t)*1;
f = 1;
f0 = 1;
simin=[t.' F.' Fo.'];
%% Simular con circuito electrico
% Se simula contra el circuito electrico correspondiente para comprobar la
% validez de la ecuación encontrada teoricamente.
out=simular(R,cs,cp,f,f0,max(t));
%% Comparar diferentes fuerzas
% F=F0
outFi=sim("Modelo_Circuito.slx","StopTime",num2str(max(t)));
xFi=outFi.simout.signals.values(:,1);
yFi=outFi.simout.time;
figure()
plot(yFi,xFi,'LineWidth',2)
hold on

% F<F0
F=(0<t)*0.8;
Fo=(0<t)*1;
simin=[t.' F.' Fo.'];
outF=sim("Modelo_Circuito.slx","StopTime",num2str(max(t)));
xF=outF.simout.signals.values(:,1);
yF=outF.simout.time;
plot(yF,xF,'LineWidth',2)
hold on

% F>F0
F=(0<t)*1;
Fo=(0<t)*0.8;
simin=[t.' F.' Fo.'];
outF2=sim("Modelo_Circuito.slx","StopTime",num2str(max(t)));
xF2=outF2.simout.signals.values(:,1);
yF2=outF2.simout.time;
plot(yF2,xF2,'LineWidth',2)
title("Respuesta según la relación entre F y Fo")
xlabel("Tiempo(s)")
ylabel("Desplazamiento (m)")
legend("F=F0","F<F0","F>F0")
xlim([0,10])
ylim([-0.5 0.5])
grid on
hold off

%% Comparar datos legend
% Escogiendo F=F0 para comparar con las diferentes patologías
F=(0<t)*1;
Fo=(0<t)*1;
simin=[t.' F.' Fo.'];

a=[0.5 0.2 2]; % Sano
b=[0.8 0.2 2]; % Fibromialgia
[out,out2]=comparedata2(a,b,max(t),"Fibromialgia");
c=[0.75 0.314 3.14]; % Fatiga
[out3,out4]=comparedata2(a,c,max(t),"Fatiga");
%% Funciones
%Para hacer el proceso más eficiente se crean varias funciones debido a que
%se va a realizar las mismas operaciones constantemente
function out=simular(R,cs,cp,f,f0,time)
out=sim("Modelo_Circuito.slx","StopTime",num2str(time)); %Se simula el sistema y se guarda su out
figure()
%Desde simulik se le da la orden al diagrama de bode de enviarse al
%workspace este lo envia como un ss así que usando la misma función se
%puede graficar de la misma manera
bode(out.bodegraf.values) 
h = findobj(gcf, 'type', 'line');
set(h, 'LineWidth', 2); % Establecer grosor de línea a 2
title("Diagrama de Bode persona sana")
grid on
figure()
% Se extraen los valores de simulink
x=out.simout.signals.values(:,2);
y=out.simout.time;
%Se grafican los valores de su respectivo bloque conociendo la extructura
%del mux
subplot(2,1,1)
plot(y,x,'LineWidth',2)
title("Respuesta obtenida del circuito electrico")
xlabel("Tiempo(s)")
ylabel("Desplazamiento (m)")
xlim([0,10]);
subplot(2,1,2)
x2=out.simout.signals.values(:,1);
plot(y,x2,'LineWidth',2)
title("Respuesta obtenida con función de transferencia")
xlabel("Tiempo(s)")
ylabel("Desplazamiento (m)")
xlim([0,10]);

end

function [out,out2] =comparedata2(a,b,time,patologia)
sub1="Sano ";
sub2=patologia+" ";
evaluator(a(1),a(2),a(3))
out=sim("Modelo_Circuito.slx","StopTime",num2str(time));
evaluator(b(1),b(2),b(3))
out2=sim("Modelo_Circuito.slx","StopTime",num2str(time));
figure()
bode(out2.bodegraf.values)
h = findobj(gcf, 'type', 'line');
set(h, 'LineWidth', 2); % Establecer grosor de línea a 2
title(["Diagrama de Bode ",sub2])
grid on
x=out.simout.signals.values(:,1);
y=out.simout.time;
% Comparación entre sano y patología
figure()
plot(y,x,'LineWidth',2)
hold on
xlabel("Tiempo(s)")
ylabel("Desplazamiento (m)")
x2=out2.simout.signals.values(:,1);
y2=out2.simout.time;
plot(y2,x2,"k",'LineWidth',2)
title("Comparación de respuesta")
legend(sub1,sub2)
xlim([0,15])
hold off
end
function evaluator(R,cs,cp)
%Esta función permite evaluar las constantes en el workspace, debido a que
%cuando se simula este toma los valores que esten en este, en si se envia
%una linea de codigo para escribirla en la command window, así garatizando
%que aun dentro de las funciones las variables cambien.
evalin("base","R="+num2str(R)+";"+"cs="+num2str(cs)+";"+"cp="+num2str(cp)+";");
end

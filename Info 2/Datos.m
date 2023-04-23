%% No me juzgen no sé algebra tampoco
syms s F Fo cs cp R x1 x
eqn1=R*s*(x1-x)+(cs)*x1==Fo;
eqn2=R*s*(x-x1)+(cp)*x==F-Fo;
sol=solve([eqn1,eqn2],[x,x1]);
xsol=sol.x
%% Variables normales
R=0.5;
cs=0.2;
cp=2;

%% Simular
t=0.1:0.1:20;
F=(0<t)*1;
Fo=(0<t)*1;
simin=[t.' F.' Fo.'];
out=simular(R,cs,cp,max(t));


%% Funciones 
function out=simular(R,cs,cp,time)
out=sim("Modelo_Circuito.slx","StopTime",num2str(time));
figure(1)
bode(out.bodegraf.values)
grid on
figure(2)
x=out.simout.signals.values(:,2);
y=out.simout.time;
subplot(2,1,1)
plot(y,x)
title("Respuesta x circuito electrico")
xlabel("tiempo(s)")
ylabel("Velocidad")
%xlim([0,1e-7])
subplot(2,1,2)
x2=out.simout.signals.values(:,1);
plot(y,x2)
title("Respuesta x funcion transferencia")
xlabel("tiempo(s)")
ylabel("Velocidad")

end



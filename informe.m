clc;clear all;close all;
load 'DataE1.mat'
%pasar todo a vectores fila
t=t';
U1=U1';Y1=Y1';Y2=Y2';
%%
%graficar los datos Validación

figure(1)
subplot(211)
plot(t,U1)
title('Entrada evaluación')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('U1')
%salida
subplot(212)
plot(t,Y1)
title('Salida evalución')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('Y1')

%graficar los datos evaluación
figure(2)
subplot(211)
plot(t,U2)
title('Entrada validación')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('U2')

%salida
subplot(212)
plot(t,Y2)
title('Salida evalución')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('Y2')

%% Procesamiento de la señal
%duplico en vector t para poder filtrar las dos señales por separado
t1=t;
t2=t;
Pos_ini=find(t1>=3.168);
t1=t1(Pos_ini)-t1(Pos_ini(1)); %para que el tiempo comience en cero
U1=U1(Pos_ini);
Y1=Y1(Pos_ini);
figure(3)
subplot(211)
graficar(t1,U1,'Señal entrada evaluación recortada','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida evaluación recortada','Tiempo (s)','Amplitud')
legend('Y1')

%Ahora para validación
t2=t2(Pos_ini)-t2(Pos_ini(1)); %para que el tiempo comience en cero
U2=U2(Pos_ini);
Y2=Y2(Pos_ini);
figure(4)
subplot(211)
graficar(t2,U2,'Señal entrada validación recortada','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2,'Señal salida validación recortada','Tiempo (s)','Amplitud')
legend('Y2')

%% Eliminar el offset

pos_off=find(t1<=12.44);
U1_=U1-ones(size(U1,1),1)*mean(U1(pos_off));
Y1_=Y1-ones(size(U1,1),1)*mean(Y1(pos_off));
%validación
U2_=U2-ones(size(U2,1),1)*mean(U2); %NO  se donde comienza a ser constante entonces solo con el promedio de si misma
Y2_=Y2-ones(size(U2,1),1)*mean(Y2);
figure(5)
subplot(211)
graficar(t1,U1_,'Señal entrada evaluación sin offset','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1_,'Señal salida evaluación recortada','Tiempo (s)','Amplitud')
legend('Y1')

figure(6)
subplot(211)
graficar(t2,U2_,'Señal entrada validación sin offser','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2_,'Señal salida validación recortada','Tiempo (s)','Amplitud')
legend('Y2')
%%
!git config --global core.longpaths true
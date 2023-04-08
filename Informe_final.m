clc;clear all;close all;
load 'DataE1.mat'
%%
%pasar todo a vectores fila
t=t';
U1=U1';Y1=Y1';Y2=Y2';
t1=t;
t2=t;
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
title('Salida validación')
xlabel('Tiempo (s)')
ylabel('Amplitud')
legend('Y2')
%% Eliminar el offset

U1=U1-ones(size(U1,1),1)*7; %A ojo lo puse en 7 solo para ver como cambian los modelos
Y1=Y1-ones(size(U1,1),1)*7; 
%validación
U2=U2-ones(size(U2,1),1)*mean(U2); %NO  se donde comienza a ser constante entonces solo con el promedio de si misma
Y2=Y2-ones(size(U2,1),1)*mean(Y2);
figure(5)
subplot(211)
graficar(t1,U1,'Señal entrada evaluación sin offset','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida evaluación sin offseet','Tiempo (s)','Amplitud')
legend('Y1')

figure(6)
subplot(211)
graficar(t2,U2,'Señal entrada validación sin offset','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2,'Señal salida validación sin offset','Tiempo (s)','Amplitud')
legend('Y2')
%% recortar un periodo
recorte=find((12.5<=t1)&(t1<=37.5));
t1=t(recorte);
U1=U1(recorte);
Y1=Y1(recorte);
%% Análisis de frecuencia
ts=min(diff(t));
n=1; %Cambiar dependiendo de la necesidad

t1=downsample(t1,n);
t2=downsample(t2,n);
U1=downsample(U1,n);
U2=downsample(U2,n);
Y1=downsample(Y1,n);
Y2=downsample(Y2,n);
%%

figure(7)
subplot(211)
graficar(t1,U1,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y1')

figure(8)
subplot(211)
graficar(t2,U2,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y2')
%% Parametricas 
U1=U1';Y1=Y1';Y2=Y2';U2=U2'; % Se arreglan los vectores
%Se crea el iddata
fsn1=min(diff(t1));
data_1=iddata(Y1,U1,1/fsn1);
data_2=iddata(Y2,U2,1/fsn1); 
% Busqueda del retardo
nk=delayest(data_1)
nk2=delayest(data_2)
%% Busqueda del modelo
%Empezamos por ARX
NN=struc(1:3,1:3,1:3);
%Estimando el modelo
v=arxstruc(data_1,data_2,NN);
%Para error y orden a partir de los coeficientes
[orden_arx,vmod]=selstruc(v,"AIC");
%Ya conociendo los coeficientes se construye el modelo
M_ARX=arx(data_1,orden_arx);
present(M_ARX)
%%
%Comparamos el modelo con los datos reales
comparedata(M_ARX,data_1,data_2)
%% Error de las salidas
[salida_arx,fit_arx0,x_arx]=compare(data_2,M_ARX);
e_arx=errorr(salida_arx.y,data_2.y) %Se compara el error con el modelo encontrado
%% ARMAX
%Se crean las estructuras
na = 1:3;
nb = 1:3;
nc = 1:3;
nk= 0:3;
NN = struc(na,nb,nc,nk); 
%Se inicia un campo de celdas del tamaño de la estructura
modelsarmax = cell(size(NN,1),1);
for ct = 1:size(NN,1)
   modelsarmax{ct} = armax(data_1, NN(ct,:)); %Se almacena la información de cada modelo con los diferentes coeficientes en cada celda para su mejor comparación
end
%% AIC
V = aic(modelsarmax{:},'AIC');
[Vmin_armax,I] = min(V);
M_armax=modelsarmax{I};
present(M_armax)
%%
comparedata(M_armax,data_1,data_2)
%% Oe
nf = 1:3;
nb = 1:3;
nk = 0:3;
NN = struc(nf,nb,nk); 
modelsoe = cell(size(NN,1),1);
for ct = 1:size(NN,1)
   modelsoe{ct} = oe(data_1, NN(ct,:));
end
%% AIC
V = aic(modelsoe{:},'AIC');
[Vmin_Oe,I] = min(V);
M_oe=modelsoe{I};
present(M_oe)
%%
comparedata(M_oe,data_1,data_2)
%% Mejor forma de bj
nb = 1:3;
nc = 1:3;
nd = 1:3;
nf= 0:3;
nk=0:3;
NN = struc(nb,nc,nd,nf,nk); 
modelsbj = cell(size(NN,1),1);
for ct = 1:size(NN,1)
   modelsbj{ct} = bj(data_1, NN(ct,:));
end
%% AIC
V = aic(modelsbj{:},'AIC');
[Vmin_Bj,I] = min(V);
M_bj=modelsbj{I};
present(M_bj)
%%
comparedata(M_bj,data_1,data_2)
function comparedata(modelo,data_1cop,data_2cop)
    subplot(2,1,1)
    compare(data_1cop,modelo)
    title("Datos evaluación")
    subplot(2,1,2)
    compare(data_2cop,modelo)
    [yse_mod,fit_e_mod,x0e_mod]=compare(data_2cop,modelo);
    Error=errorr(yse_mod.y,data_2cop.y)
    title("Datos validación")
end
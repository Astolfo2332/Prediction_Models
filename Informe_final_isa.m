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
title('Salida evaluación')
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
pos_off=find(t1<=12.44);
U1=U1-ones(size(U1,1),1)*mean(U1(pos_off)); 
Y1=Y1-ones(size(Y1,1),1)*mean(Y1(pos_off)); 
%validación
U2=U2-ones(size(U2,1),1)*mean(U2); %NO  sé donde comienza a ser constante entonces solo con el promedio de si misma
Y2=Y2-ones(size(Y2,1),1)*mean(Y2);
figure(3)
subplot(211)
graficar(t1,U1,'Señal entrada evaluación sin offset','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida evaluación sin offseet','Tiempo (s)','Amplitud')
legend('Y1')

figure(4)
subplot(211)
graficar(t2,U2,'Señal entrada validación sin offset','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2,'Señal salida validación sin offset','Tiempo (s)','Amplitud')
legend('Y2')
%% recortar un periodo
recorte=find((12.5<=t1)&(t1<=37.5)); %Se establecen los valores del recorte a ojo
%Se hace el recorte 
t1=t(recorte);
U1=U1(recorte);
Y1=Y1(recorte);

figure(5)
subplot(211)
graficar(t1,U1,'Señal entrada evaluación sin offset','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida evaluación sin offseet','Tiempo (s)','Amplitud')
legend('Y1')
%% Análisis de frecuencia
ts=min(diff(t)); %Se ecuentra la frecuencia de muestreo
fs=1/ts; %Se establece el periodo 
%Se establecen varios valores de prueba para elegir un downsample adecuado
fsn1 = 1000; 
fsn2 = 500;
fsn3 = 100;
% dado que fs=1000. La relación fs/fsn1=1 (no hay disminución en la tasa de
% muestreo), fs/fsn2=2 y fs/fsn3 = 10

n=round(fs/fsn1); %Cambiar dependiendo de la necesidad

t1=downsample(t1,n);
t2=downsample(t2,n);
U1=downsample(U1,n);
U2=downsample(U2,n);
Y1=downsample(Y1,n);
Y2=downsample(Y2,n);
%%
%Se grafiacan los resultados del downsample
figure(6)
subplot(211)
graficar(t1,U1,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,Y1,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y1')

figure(7)
subplot(211)
graficar(t2,U2,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,Y2,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y2')
%% Parametricas 
U1=U1';Y1=Y1';Y2=Y2';U2=U2'; % Se arreglan los vectores
%Se crea el iddata
data_1=iddata(Y1,U1,1/fsn1);
data_2=iddata(Y2,U2,1/fsn1); 

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
figure(8)
[yarx,fit_ev_arx,xarx,yarx2,fit_val_arx,xarx2,e_]=comparedata(M_ARX,data_1,data_2,"(ARX)")
%% Error de las salidas
e_arx=errorr(yarx2.y,data_2.y); %Se compara el error con el modelo encontrado
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
   modelsarmax{ct,2} = NN(ct,:); %Se almacena el orden de los coeficientes para su posterior comparación
   modelsarmax{ct} = armax(data_1, NN(ct,:)); %Se almacena la información de cada modelo con los diferentes coeficientes en cada celda para su mejor comparación
end
%% AIC
V = aic(modelsarmax{:,1},'AIC'); %Se evaluan todos los modelos mediante el criterio de información de acaike y se almacena en V
[Vmin_armax,I1] = min(V); %Se toma la fila del minimo valor de V, lo cual extrae tanto el mejor modelo por el criterio de información como el orden de los coeficientes
M_armax=modelsarmax{I1,1}; %Se establece una variable individual para el modelo
present(M_armax) %Se muestra el modelo
%%
figure(9)
[yarmax,fit_ev_armax,xarmax,yarmax2,fit_val_armax,xarmax2,e_armax]=comparedata(M_armax,data_1,data_2,"(ARMAX)") %Se compara el modelo y se imprime la información pertinente
%% Oe
%En este caso los siguentes modelos siguen el mismo orden que ARMAX solo
%que  en estos casos cambian el numero de coeficientes a encontrar
nf = 1:3;
nb = 1:3;
nk = 0:3;
NN = struc(nf,nb,nk); 
modelsoe = cell(size(NN,1),1);
for ct = 1:size(NN,1)
   modelsoe{ct,2} = NN(ct,:);
   modelsoe{ct} = oe(data_1, NN(ct,:));
end
%% AIC
V = aic(modelsoe{:,1},'AIC');
[Vmin_Oe,I2] = min(V);
M_oe=modelsoe{I2,1};
present(M_oe)
%%
figure(10)
[yoe,fit_ev_oe,xoe,yoe2,fit_val_oe,xoe2,e_oe]=comparedata(M_oe,data_1,data_2,"(OE)")
%% Mejor forma de bj
nb = 1:3;
nc = 1:3;
nd = 1:3;
nf= 0:3;
nk=0:3;
NN = struc(nb,nc,nd,nf,nk); 
modelsbj = cell(size(NN,1),1);
for ct = 1:size(NN,1)
   modelsbj{ct,2} = NN(ct,:);
   modelsbj{ct} = bj(data_1, NN(ct,:));
end
%% AIC
V = aic(modelsbj{:,1},'AIC');
[Vmin_Bj,I3] = min(V);
M_bj=modelsbj{I3,1};
present(M_bj)
%%
figure(11)
[ybj,fit_ev_bj,xbj,ybj2,fit_val_bj,xbj2,e_bj]=comparedata(M_bj,data_1,data_2,"(BJ)")
%%
%save Datosn1.mat
%% Discreto a continuo
%Mediante el metodo de tustin para no tener problemas con los polos
%cercanos a 0
M_arx_c = d2c(M_ARX,'tustin');
M_armax_c = d2c(M_armax,'tustin');
M_oe_c = d2c(M_oe,'tustin');
M_bj_c = d2c(M_bj,'tustin');

%% LSIM
% arx
%Ya conociendo la función en tiempo continuo se procede a graficar tanto
%los datos de validación como los de evaluación
y_pred_arx = lsim(M_arx_c,U1,t1); %Se gebera las y mediante los entradas
y_pred_arx_v = lsim(M_arx_c,U2,t2);
figure(22)
subplot(211)
plot(t1,Y1,t1,y_pred_arx)
legend('Y','Y predicha por ARX')
title('Salida real Vs. predicha (evaluación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
subplot(212)
plot(t2,Y2,t2,y_pred_arx_v)
legend('Y','Y predicha por ARX')
title('Salida real Vs. predicha (validación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')


%armax
y_pred_armax = lsim(M_armax_c,U1,t1);
y_pred_armax_v = lsim(M_armax_c,U2,t2);
figure(23)
subplot(211)
plot(t1,Y1,t1,y_pred_armax,"--m")
legend('Y','Y predicha por ARMAX')
title('Salida real Vs. predicha (evaluación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
subplot(212)
plot(t2,Y2,t2,y_pred_armax_v,"--m")
legend('Y','Y predicha por ARMAX')
title('Salida real Vs. predicha (validación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')

%oe
y_pred_oe = lsim(M_oe_c,U1,t1);
y_pred_oe_v = lsim(M_oe_c,U2,t2);
figure(24)
subplot(211)
plot(t1,Y1,t1,y_pred_oe)
legend('Y','Y predicha por OE')
title('Salida real Vs. predicha (evaluación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
subplot(212)
plot(t2,Y2,t2,y_pred_oe_v)
legend('Y','Y predicha por OE')
title('Salida real Vs. predicha (validación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')

% bj
y_pred_bj = lsim(M_bj_c,U1,t1);
y_pred_bj_v = lsim(M_bj_c,U2,t2);
figure(25)
subplot(211)
plot(t1,Y1,t1,y_pred_bj)
legend('Y','Y predicha por BJ')
title('Salida real Vs. predicha (evaluación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
subplot(212)
plot(t2,Y2,t2,y_pred_bj_v)
legend('Y','Y predicha por BJ')
title('Salida real Vs. predicha (validación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
%%
%armax
y_pred_armax = lsim(M_armax_c,U1,t1);
y_pred_armax_v = lsim(M_armax_c,U2,t2);
figure(26)
subplot(211)
graficar(t1,U1,'Señal entrada evaluación procesado','Tiempo (s)','Amplitud')
legend('U1')
xlim([12.2,37.5])
subplot(212)
plot(t1,Y1,t1,y_pred_armax,"--r")
legend('Y1','Y1 predicha por ARMAX')
title('Salida real Vs. predicha (evaluación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
xlim([12.2,37.5])
figure(27)
subplot(212)
plot(t2,Y2,t2,y_pred_armax_v,"--r")
legend('Y2','Y2 predicha por ARMAX')
title('Salida real Vs. predicha (validación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')

subplot(211)
graficar(t2,U2,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U2')

%% Tabla

modelos = ["ARX";"ARMAX";"OE";"BJ"];
fit_e = [fit_ev_arx;fit_ev_armax;fit_ev_oe;fit_ev_bj]; % Evaluacion
fit_v = [fit_val_arx;fit_val_armax;fit_val_oe;fit_val_bj]; % Validación

e_arxAIC = min(vmod(1,:));
error_AIC = [e_arxAIC;Vmin_armax;Vmin_Oe; Vmin_Bj]; % Errores AIC
error_funcion = [e_arx;e_armax;e_oe; e_bj];
% mejor orden
orden_f_arx_s = string(orden_arx);
orden_f_arx_s = join(orden_f_arx_s);
orden_f_armax_s = string(modelsarmax{I1,2});
orden_f_armax_s = join(orden_f_armax_s);
orden_f_oe_s = string(modelsoe{I2,2});
orden_f_oe_s = join(orden_f_oe_s);
orden_f_bj_s = string(modelsbj{I3,2});
orden_f_bj_s = join(orden_f_bj_s);

% matriz de ordenes
ordenes = [orden_f_arx_s;orden_f_armax_s;orden_f_oe_s;orden_f_bj_s];

% tabla
tabla = table(modelos,fit_e,fit_v,error_AIC,error_funcion,ordenes);
present(tabla)
%%
function [yy,fitt,xx,yy2,fitt2,xx2,Error]=comparedata(modelo,data_1cop,data_2cop,titulo)
    subplot(2,1,1)
    [yy,fitt,xx]=compare(data_1cop,modelo); %para guardar el fit
    compare(data_1cop,modelo)  %para graficar
    title("Datos evaluación "+titulo)
    subplot(2,1,2)
    [yy2,fitt2,xx2]=compare(data_2cop,modelo);
    compare(data_2cop,modelo)
    Error=errorr(yy2.y,data_2cop.y); % Error calculado con función propia
    title("Datos validación "+titulo)
end
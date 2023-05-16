%% Carga
clc; clear all; close all;
load("Experimento_A.mat")
t1=t1.';
t2=t2.';
%% 0.1 Exploración de los datos
figure()
subplot(2,2,1)
plot(t1,u1)
title("Entrada 1")
subplot(2,2,2)
plot(t1,y1)
title("Salida 1")
subplot(2,2,3)
plot(t2,u2)
title("Entrada 2")
subplot(2,2,4)
plot(t2,y2)
title("Salida 2")
%% 
figure()
subplot(1,2,1)
plot(tv,uv)
title("Entrada de validación")
subplot(1,2,2)
plot(tv,yv)
title("Salida Validacióm")
%% 1 Filtrados iniciales
%% Recorte offset
pos_off=find(t1<=1.33);
u1=u1-ones(size(u1,1),1)*mean(u1(pos_off)); 
%No se alcanza a ver claramente el punto estable
y1=y1-ones(size(y1,1),1)*mean(y1); 
yv=yv-ones(size(yv,1),1)*mean(yv); 
%No se le hacen cambios a uv ya que parece no tener offset aparente
%% Grafica
figure()
subplot(2,2,1)
plot(t1,u1)
title("Entrada 1")
subplot(2,2,2)
plot(t1,y1)
title("Salida 1")
subplot(2,2,3)
plot(tv,uv)
title("Entrada de validación")
subplot(2,2,4)
plot(tv,yv)
title("Salida Validación")
%% Recorte de los perdiodos de la señal
% para la primera a travez del grafico y con data tips se puede observar el
% periodo en el intervalo de 1.3 a 5.3
recorte=find((1.33<=t1)&(t1<=6.8));

t1=t1(recorte);
u1=u1(recorte);
y1=y1(recorte);
%% Grafica
figure()
subplot(1,2,1)
plot(t1,u1)
title("Entrada 1")
subplot(1,2,2)
plot(t1,y1)
title("Salida 1")
%% Filtrado
% En este caso la señal de entrada de prueba tiene bastante ruido, así que
% utilizaremos un filtrado por fourier
[T,f,p1] = No_Aprendi_nada_en_fourier(u1,t1);
%% Grafica
figure()
plot(f,p1)
%% Aplicación del filtro
u1 = fn_filtro(T,u1,2,[119,122]); % Frecuencias raras vistas en la grafica anterior
u1 = fn_filtro(T,u1,2,[59,61]);

%% Grafica
figure()
subplot(1,2,1)
plot(t1,u1)
title("Entrada 1")
subplot(1,2,2)
plot(t1,y1)
title("Salida 1")
%En este casi ya no encontramos tanto ruido en la grafica
%% Downsample 
ts=min(diff(t1)); %Se ecuentra la frecuencia de muestreo
fs=1/ts; %Se establece el periodo 
%Se establecen varios valores de prueba para elegir un downsample adecuado
fsn1 = fs; 
fsn2 = fs/2;
fsn3 = fs/3;
%%
n=round(fs/fsn1); %Cambiar dependiendo de la necesidad

t1=downsample(t1,n);
u1=downsample(u1,n);
uv=downsample(uv,n);
y1=downsample(y1,n);
yv=downsample(yv,n);
%% 
%Se grafiacan los resultados del downsample
figure()
subplot(211)
graficar(t1,u1,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U1')
subplot(212)
graficar(t1,y1,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y1')

figure(7)
subplot(211)
graficar(t2,u2,'Señal entrada validación procesado','Tiempo (s)','Amplitud')
legend('U2')
subplot(212)
graficar(t2,y2,'Señal salida validación procesado','Tiempo (s)','Amplitud')
legend('Y2')
%% 2 Parametricas  
%Iniciamos los data
data_1=iddata(y1,u1,1/fsn1);
data_2=iddata(yv,uv,1/fsn1);
%% 2.1 ARX
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
figure()
[yarx,fit_ev_arx,xarx,yarx2,fit_val_arx,xarx2,e_]=comparedata(M_ARX,data_1,data_2,"(ARX)")
%% Error de las salidas
e_arx=errorr(yarx2.y,data_2.y); %Se compara el error con el modelo encontrado
%% AIC por funcion directa
Vmin_arx=aic(M_ARX,"AIC") %Se hace para así tener valores similares debido a la diferencia de como calcula el Acaike el selstruc y la función aic
%% 2.2 ARMAX
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
figure()
[yarmax,fit_ev_armax,xarmax,yarmax2,fit_val_armax,xarmax2,e_armax]=comparedata(M_armax,data_1,data_2,"(ARMAX)") %Se compara el modelo y se imprime la información pertinente
%% 2.3 Oe
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
figure()
[yoe,fit_ev_oe,xoe,yoe2,fit_val_oe,xoe2,e_oe]=comparedata(M_oe,data_1,data_2,"(OE)")
%% 2.4 Bj
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
figure()
[ybj,fit_ev_bj,xbj,ybj2,fit_val_bj,xbj2,e_bj]=comparedata(M_bj,data_1,data_2,"(BJ)")
%% 3 Analisis de sensibilidad
M_oe_c = d2c(M_oe,'tustin');
%oe
y_pred_oe = lsim(M_oe_c,u1,t1);
y_pred_oe_v = lsim(M_oe_c,uv,tv);
figure()
subplot(211)
plot(t1,y1,t1,y_pred_oe)
legend('Y','Y predicha por OE')
title('Salida real Vs. predicha (evaluación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
subplot(212)
plot(tv,yv,tv,y_pred_oe_v)
legend('Y','Y predicha por OE')
title('Salida real Vs. predicha (validación)')
xlabel('Tiempo(s)')
ylabel('Amplitud')
%% funciones

function [T,f,p1] = No_Aprendi_nada_en_fourier(in_r,t)
Y=fft(in_r); %Transoformada rapida
L=length(in_r); %N puntos de la función
p2=abs(Y/L); 
p1=p2(1:((L/2)+1)); %Ajuste del largo 
p1(2:end-1)=2*p1(2:end-1);
T=diff(t);%Frecuencia de muestreo, da un vector entonces por eso solo se toma el primer valor
f=1/T(1)*(0:(L/2))/L;%X en terminos de frecuencia
end
function in_filt = fn_filtro(T,in_r,orden,rango)
Fs=(1/T(1))/2; 
[num,dem]=butter(orden,rango./Fs,"stop"); %Primer factor es el orden, el segundo es la frecuencia que se desea filtrar, y como sabemos la frecuencia tenemos que pasarla a numeros de muestras por eso se divide punto a punto con Fs
in_filt=filtfilt(num,dem,in_r); % aca se esta aplicando el filtro
end
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
function err = errorr(x1,x2)
L1=length(x1);
E=x1-x2;
err=sqrt(sum(E.^2,"omitnan"))/L1;
end
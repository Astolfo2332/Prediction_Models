%% Carga
%Se limpia el espacio y se carga la información
clc; clear all; close all;
load("Experimento_A.mat")
%Se establecen variables globales que se utilizaran luego
global u2 y2 t2
%Se organizan los vectores de tiempo
t1=t1.';
t2=t2.';
%% 0.1 Exploración de los datos
% inicialmente graficamos los datos para empezar la parte de
% preprocesamiento
figure()
% Sujeto 1
subplot(2,2,1)
plot(t1,u1,'k')
xlim([0 17.5])
xlabel('Tiempo (s)')
ylabel('Flujo (L/min)')
title("Flujo en la vía aérea (Sujeto 1)")
subplot(2,2,2)
plot(t1,y1,'k')
xlim([0 17.5])
xlabel('Tiempo (s)')
ylabel('Volumen (mL)')
title("Volumen (Sujeto 1)")
% Sujeto 2
subplot(2,2,3)
plot(t2,u2,'k')
xlim([0 17.5])
xlabel('Tiempo (s)')
ylabel('Flujo (L/min)')
title("Flujo en la vía aérea (Sujeto 2)")
subplot(2,2,4)
plot(t2,y2,'k')
xlim([0 17.5])
xlabel('Tiempo (s)')
ylabel('Volumen (mL)')
title("Volumen (Sujeto 2)")
%% 
figure()
subplot(1,2,1)
plot(tv,uv)
title("Entrada de validación")
subplot(1,2,2)
plot(tv,yv)
title("Salida de validación")
%% 1 Preprocesamiento
%% Recorte offset 
%Se toma un promedio del punto estable para hacer el recorte del offset
pos_off=find(t1<=1.33);
offu1=mean(u1(pos_off));
offu2=mean(u2(pos_off));
u1=u1-ones(size(u1,1),1)*offu1; 
u2=u2-ones(size(u2,1),1)*offu2; 
uv=uv-ones(size(uv,1),1)*4;
% No se alcanza a ver claramente el punto estable
offy1=mean(y1);
offy2=mean(y2);
offyv=mean(yv);
y1=y1-ones(size(y1,1),1)*offy1; 
yv=yv-ones(size(yv,1),1)*offyv;
y2=y2-ones(size(y2,1),1)*offy2; 
%% Grafica
%Se grafican como van quedando las graficas
figure()
subplot(3,2,1)
plot(t1,u1)
title("Entrada 1")
subplot(3,2,2)
plot(t1,y1)
title("Salida 1")
subplot(3,2,3)
plot(tv,uv)
title("Entrada de validación")
subplot(3,2,4)
plot(tv,yv)
title("Salida Validación")
subplot(3,2,5)
plot(t2,u2)
title("Entrada 2")
subplot(3,2,6)
plot(t2,y2)
title("Salida 2")
%% Recorte de inicio
%Se hace un recorte inicial de la seccion de la señal que no presenta un
%comportamiento perdiodico
recorte=find((1.33<=t1));

t1=t1(recorte)-1.33;
u1=u1(recorte);
y1=y1(recorte);
recorte=find(1.33<=t2);
t2=t2(recorte)-1.33;
u2=u2(recorte);
y2=y2(recorte);
%% Eliminación de la tendencia polinomial
% Se elimina utilizando la función dtrend en este caso de grado 2 para
% todas las señales
n=2;
u1=detrend(u1,n);
y1=detrend(y1,n);
u2=detrend(u2,n);
y2=detrend(y2,n);
uv=detrend(uv,n);
yv=detrend(yv,n);

%% Grafica
figure()
subplot(3,2,1)
plot(t1,u1)
title("Entrada 1")
subplot(3,2,2)
plot(t1,y1)
title("Salida 1")
subplot(3,2,3)
plot(tv,uv)
title("Entrada de validación")
subplot(3,2,4)
plot(tv,yv)
title("Salida Validación")
subplot(3,2,5)
plot(t2,u2)
title("Entrada 2")
subplot(3,2,6)
plot(t2,y2)
title("Salida 2")
%% Filtrado
% En este caso la señal de entrada de prueba tiene bastante ruido, así que
% utilizaremos un filtrado por fourier
[T,f,p1] = No_Aprendi_nada_en_fourier(u1,t1);
[T2,f2,p12] = No_Aprendi_nada_en_fourier(u2,t2);
%% Grafica
figure()
plot(f,p1)
figure()
plot(f2,p12)
%% Aplicación del filtro
fs=(1/T(1))/2; %Niquist
fs2=(1/T2(1))/2;
% Frecuencias raras vistas en la grafica anterior
u1 = fn_filtro(T,u1,2,[59,61]); %Se realiza un filtro notch a 60 Hz para asegurarnos de eliminar el ruido electrico
[num,dem]=butter(2,59/fs,"low"); %Se hace un pasa bajas, debido a la recurrencia del ruido electrico y que no tenemos información importante en estos rangos
u1=filtfilt(num,dem,u1);
%Se grafica la respuesta del filtro en terminos de freciencia
figure()
freqz(num,dem,4000,fs)
%Mismo proceso para la otra señal
u2 = fn_filtro(T2,u2,2,[59,61]);
[num,dem]=butter(2,59/fs2,"low"); 
u2=filtfilt(num,dem,u2);
figure()
freqz(num,dem,4000,fs)
%% Grafica
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
%En este casi ya no encontramos tanto ruido en la grafica
%% Downsample 
ts=min(diff(t1)); %Se ecuentra la frecuencia de muestreo
fs=1/ts; %Se establece el periodo 
%Se establecen varios valores de prueba para elegir un downsample adecuado
fsn1 = fs; 
fsn2 = fs/2;
fsn3 = fs/3;
%%
n=round(fs/fsn2); %Cambiar dependiendo de la necesidad

t1=downsample(t1,n);
u1=downsample(u1,n);
uv=downsample(uv,n);
y1=downsample(y1,n);
yv=downsample(yv,n);
tv=downsample(tv,n);
%% 
%Se grafiacan los resultados del downsample
% Sujeto 1

subplot(2,3,1)
plot(t1,u1,'k',linewidth=2)
grid on;
xlabel('Tiempo (s)')
ylabel('Flujo (L/min)')
title("Flujo en la vía aérea (Sujeto 1, evaluación)")
subplot(2,3,4)
offset1=min(y1);
plot(t1,y1-offset1,'k',linewidth=2) % para que volumen sea positivo como es fisiologicamente lógico
grid on;
xlabel('Tiempo (s)')
ylabel('Volumen (mL)')
title("Volumen (Sujeto 1, evaluación)")
% Sujeto 1 validación
subplot(2,3,2)
plot(tv,uv,'k',linewidth=2)
grid on;
xlabel('Tiempo (s)')
ylabel('Flujo (L/min)')
title("Flujo en la vía aérea (Sujeto 1, validación)")
subplot(2,3,5)
offset2=min(yv);
plot(tv,yv-offset2,'k',linewidth=2)
grid on;
xlabel('Tiempo (s)')
ylabel('Volumen (mL)')
title("Volumen (Sujeto 1, validación)")
% Sujeto 2
subplot(2,3,3)
plot(t2,u2,'k',linewidth=2)
grid on;
xlabel('Tiempo (s)')
ylabel('Flujo (L/min)')
title("Flujo en la vía aérea (Sujeto 2)")
subplot(2,3,6)
offset3=min(y2);
plot(t2,y2-offset3,'k',linewidth=2)
grid on;
xlabel('Tiempo (s)')
ylabel('Volumen (mL)')
title("Volumen (Sujeto 2)")
%% 2 Parametricas  
%Iniciamos los data
data_1=iddata(y1,u1,1/fsn2);
data_2=iddata(yv,uv,1/fsn2);
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
%% TABLA
modelos_r=[M_ARX ;M_armax; M_oe; M_bj];
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
%% Selección del mejor modelo
N=length(t1);
i=0;
vecto_vmin_tabla=[];
for a=1:1:4 %Porque consideramos una buena variacion de 1 hasta 4 en pasos de 1 ya que empleamos 4 modelos
    orden_P_aic=str2num(ordenes(i+1,1));
    %Se utiliza la función creada de aic, para ver el menor valor de error 
    d4 = sum(orden_P_aic);
    [vmin_tabla]=aic_(error_funcion(i+1,1),d4,N);
    %Se genera un vector con el Vmin
    vecto_vmin_tabla=[vecto_vmin_tabla;vmin_tabla];
    i=i+1;
end
%Se encuentra el menor valor de vmin y se presenta su valor 
vecto_vmin_tabla_f=min(vecto_vmin_tabla)
best=find(vecto_vmin_tabla==vecto_vmin_tabla_f);
best=modelos_r(best);
present(best) % Se muestra el mejor modelo y con este se trabaja
%% 3 Analisis de sensibilidad
% Validación del modelo encontrado en tiempo
M_ARX_c = d2c(best,'tustin')
y_pred_ARX = lsim(M_ARX_c,u1,t1);
y_pred_v_ARX = lsim(M_ARX_c,uv,tv);
figure()
subplot(211)
off=min(y1);
plot(t1, y1 - off, 'k-', 'LineWidth', 2); hold on
plot(t1, y_pred_ARX - off, 'color',[0.3 0.7 0.81], 'LineWidth', 2);
legend('Volumen real','Volumen predicho')
title('Salida real Vs. predicha con ARX (evaluación)')
xlabel('Tiempo(s)')
ylabel('Volumen (mL)')
subplot(212)
plot(tv, yv + ones(size(yv, 1), 1) * offyv, 'k-', 'LineWidth', 2); hold on
plot(tv, y_pred_v_ARX + ones(size(yv, 1), 1) * offyv, 'color',[0.3 0.7 0.81], 'LineWidth', 2);
legend('Y','Y predicha por ARX')
title('Salida real Vs. predicha con ARX (validación)')
xlabel('Tiempo(s)')
ylabel('Volumen (mL)')
%% extración de coeficientes 
%Funcion transferencia
H=tf(M_ARX_c)
[num,dem]=tfdata(H,"v");
pararef=[num(1) num(2) num(3) num(4) dem(1) dem(2) dem(3) dem(4)];
step=2;
%Rango de estimación de sensibilidad
range=[-50 50];
%Busqueda de parametros más sensibles
[J,para_change]= fn_sensible(pararef,step,range); 
%% Graf sensible
figure()
for i=1:length(pararef)
    plot(para_change,J(:,i), LineWidth=2)
    hold on
end
title('Análisis de sensibilidad')
xlabel('Variación parámetro (%)')
ylabel('Función de coste J')
grid on
legend("A","B","C","D","E","F","G","H")

%% Optimización 
D=pararef(4);
G=pararef(7);

theta_ini=[D G]; %Aplicamos un valor semilla a partir de los coeficiente de referencia y como estos interactuan con la ecuación
%Recordar cambiar el Thetha ini
%Cambiar los parametros en la de coste también
[thetha,Fval,exitflag,output]=fminsearch("fn_coste",theta_ini); %Buscanos el minimo error con esos valores
disp(' ')
disp(' Final parameter values: ')
disp(thetha);
disp(output)
%% Graficar Volumen real Vs. Volumen predicho (Sujeto 2)
figure()
%se extraen los mejores coeficientes de los parametros encontrados
num(4)=thetha(1);
dem(3)=thetha(2);

Hs=tf(num,dem); %Se genera la función de trasnferencia adecuada
ypred=lsim(Hs,u2,t2); %Se grafica con la función entrada del paciente 2
offset=min(y2); %Se le agrega el offset eliminado en la parte de preprocesamiento
graf_ypred=ypred-offset;
graf_y2=y2-offset;
plot(t2,graf_ypred,'k-', 'LineWidth', 2); hold on
plot(t2,graf_y2, 'color',[0.3 0.7 0.81], 'LineWidth', 2);
errorr(ypred,y2) % Se estima el error
corrcoef(ypred,y2) %Se estima la correlación
grid on;
legend("Predicha", "Real")
title('Volumen real Vs. Volumen predicho (Sujeto 2)')
xlabel('Tiempo(s)')
ylabel('Volumen (mL)')
%% bode (para análisis en frecuencia)
figure()
bode(H,Hs)
h = findobj(gcf, 'type', 'line');
set(h, 'LineWidth', 2); % Establecer grosor de línea a 2
title("Diagrama de Bode")
legend('Modelo sujeto 1','Modelo sujeto 2')
grid on
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
function [vmin] = aic_(V,d,N)
    %V = LSE
    %d = Sum coef
    %N = #Muestras
    vmin = log10(V)+(2*d/N);
end
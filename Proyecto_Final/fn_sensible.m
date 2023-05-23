function [J,para_change] = fn_sensible(pararef,step,range)
global u2 y2 t2
Np=length(pararef); %Numero de iteraciones (corresponde al largo de para ref)
para=zeros(size(pararef)); %Los valores que vamos a evaluar
num_steps=2*(range(2)/step)+1; %El numero de saltos
J=zeros(num_steps,Np); %Donde vamos a almacenar el coste
para_change=range(1):step:range(2); %El rango de cambio de parametros
for i = 1:Np %Se recorre las iteraciones (corresponde al largo de para ref)
    for k=1:num_steps %Se recorre el numero de pasos
        para=pararef; %Se guarda el parametro a evaluar 
        para(i)=pararef(i)*(1+para_change(k)/100); %Se va cambiando el parametro con cada iteración para evaluar su coste a medida de que cambia para_change
        %if para_change(k)==0 %Si el coeficiente es 0 va a dar una dar 0 entonces se hace de una vez el cambio
        %    J(k,i)=0;
        %else
            ypred=fn_sys(para,u2,t2); %Se evalua la nueva funcion con los nuevos paramentros
            e=ypred-y2; 
            J(k,i)=sum(e.^2); %Se busca el error y se guarda en la posicion de k e i
        %end
    end
end
%Cambiar esta función con la ecuación que estamos buscando
function ypred=fn_sys(params,in,t)
A=params(1);
B=params(2);
C=params(3);
D=params(4);
E=params(5);
F=params(6);
G=params(7);
H=params(8);
den=[E F G H];
num=[A B C D];
Hs=tf(num,den);
ypred=lsim(Hs,in,t);
end
end


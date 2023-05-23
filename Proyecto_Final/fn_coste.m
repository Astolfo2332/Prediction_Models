function J=fn_coste(theta)
    global u2 y2 t2
    %Recordar cambiar la ecuación
    num=[-1.55 -80.6 102097.94 theta(1)];
    den=[1 11155.13 theta(2) 18076.15];%Se especifica la forma de la ecuacion a buscar
    Hs=tf(num,den); %Se crea la funcion de transferencia
    ypred=lsim(Hs,u2,t2);
    e=y2-ypred;
    J=sum(e.^2);
end


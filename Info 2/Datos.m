%% Variables normales
R=0.5;
cs=0.2;
cp=2;
out=simular(R,cs,cp);


%% Funciones 
function out=simular(R,cs,cp)
out=sim("Modelo_Circuito.slx");
grid on
bode(out.bodegraf.values)
end



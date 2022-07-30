% Taratura del regolatore P/PI/PID secondo le formule di Ziegler-Nichols
% metodo ad anello chiuso in base alla valutazione 
% del guadagno critico K_cr e del periodo delle oscillazioni T_cr

function [Kp,Ti,Td] = taratura_k_critico(K_cr,T_cr,string);

fprintf('\nTaratura del regolatore %s\n',string)
Kp=0;
Ti=0;
Td=0;

if strcmp(string,'P')==1
    Kp=0.50*K_cr;
    fprintf(' 1)Kp=%3.3f \n',Kp)
    return
end

if strcmp(string,'PI')==1
    Kp=0.45*K_cr;
    fprintf(' 1)Kp=%3.3f \n',Kp)
    Ti=0.75*T_cr;
    fprintf(' 2)Ti=%3.3f \n',Ti)
    return
end

if strcmp(string,'PID')==1
    Kp=0.60*K_cr;
    fprintf(' 1)Kp=%3.3f \n',Kp)
    Ti=0.50*T_cr;
    fprintf(' 2)Ti=%3.3f \n',Ti)
    Td=0.12*T_cr;
    fprintf(' 3)Td=%3.3f \n',Td)
    return
end




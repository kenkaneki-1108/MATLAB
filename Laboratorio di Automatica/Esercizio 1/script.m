clear 
close all

%               4
% G(s) = --------------
%         s(s+0.2)(s+3)

s=zpk('s');
G=4/(s*(s+0.2)*(s+3));

figure(1)
step(G)
grid
legend('Risposta al gradino dell ''impianto','Location','north')

figure(2)
T=feedback(G,1);
step(T);
grid
legend('Risposta al gradino del sistema','Location','north')

pause
close all

% Ampiezza del gradino
r=1;

%% Metodo del K-Critico
fprintf('\nMetodo del K critico con:\n')

Kcr=0.480;
fprintf('#Kcr: %5.2f \n',Kcr)

[num,den]=tfdata(feedback(Kcr*G,1));
figure(1)
rlocus(num,den)
legend('Luogo dei poli e zeri')
grid

pause

Tcr=8.105;
fprintf('#Tcr: %5.2f \n',Tcr)

pause

fprintf('\nValori di primo tentativo')
[Kp,Ti,Td] = taratura_k_critico(Kcr,Tcr,'PID');

if Ti~=0 
    I=1/Ti;
else
    I=0;
end
D=Td;
N=3;

pause
close all


%% Metodo del K-Critico con relay
fprintf('\nMetodo del K critico + Relay con:\n')
a=2.782;
T=7.328;
h=r;

Kcr_relay=(4*h)/(a*pi);
fprintf('#Kcr: %5.2f \n',Kcr_relay)

Tcr_relay=T;
fprintf('#Tcr: %5.2f \n',Tcr_relay)

pause

[Kp_relay,Ti_relay,Td_relay] = taratura_k_critico(Kcr_relay,Tcr_relay,'PID');

if Ti_relay~=0
    I_relay=1/Ti_relay;
else
    I_relay=0;
end
D_relay=Td;
N_relay=3;

return 
pause 

% parametri tuned per il 'PID'
P_tuned=0.07;
I_tuned=0.003;
D_tuned=0.25;
N_tuned=3.746;

pause

% confronto tra P,PI,PID e PID tuned
P=0; TI=0; TD=0;
str=["P","PI","PID"];
figure(1)
hold on
for i=1:3
    if strcmp(str(:,i),'PI')==1 % PI tuned
        P=0.3;
        I=1/100;   
    else
        [P,TI,TD] = taratura_k_critico(Kcr_relay,Tcr_relay,str(:,i));
    end
    C=regolatore(P,TI,TD,N_relay);
    T=feedback(series(C,G),1);
    step(T)
end
C=regolatore(P_tuned,(1/(I_tuned*P_tuned)),D_tuned/P_tuned,N_tuned);
T=feedback(series(C,G),1);
step(T)
legend('P','PI','PID','PID_tuned','Location','NorthEast')
grid

pause
close all

%% Discretizzazione
fprintf('\nValori tuned:\n')
fprintf('  P=%3.4f\n',P_tuned)
fprintf('  I=%3.4f\n',I_tuned)
fprintf('  D=%3.4f\n',D_tuned)
fprintf('  N=%3.4f\n',N_tuned)

fprintf('\nControllore a tempo continuo\n')
C=regolatore(P_tuned,(1/(I_tuned*P_tuned)),D_tuned/P_tuned,N_tuned)

T=feedback(series(C,G),1);

figure(1)
step(T)
title('Valutazione grafica del tempo di salita')
grid

pause

info=stepinfo(T);
tr=info.RiseTime;
fprintf('Tempo di salita tr=%3.3f\n',tr)

pause
close all

fprintf('\nIl tempo di campionamento è un valore compreso tra: %3.3f e %3.3f\n',(tr/20),(tr/10))
Tc=0.20;
fprintf('Si è scelto Tc=%3.3f\n',Tc)

pause 

fprintf('\nDiscretizzazione del regolatore\n')
C_z=c2d(C,Tc,'tustin')
C_z=tf(C_z);
[numer,denom]=tfdata(C_z);

return






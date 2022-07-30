close all; clear;

s=zpk('s');

fprintf('La f.d.t del processo è: \n');

G=10/(s^2+10*s+100)

pause

%% Quesito 1.
ev_dato=10; % percento
R=1;
fprintf('Per un riferimento a rampa r(t)=R*t*1(t) con pendenza R = %d \n',R);

K_cr=100;
% Scelgo K>=K_cr
K=102;
fprintf('Si è scelta un azione proporzionale K>=%d, in questo caso K=%d \n',K_cr,K);

pause

% controllo se la f.d.t. dell'impianto presenta fattori integrali
r=0;
G_poles=pole(G);
if ismember(0,G_poles)==0
    r=1; 
end
fprintf('\nOttenendo cosi un regolatore "parziale": \n');
C_s=K/s^r

pause

ev_perc=(10*R/K)*100; % errore di inseguimento in percentuale
if ev_perc<=ev_dato
    fprintf('Precisione statica di circa %2.1f perc. \n',ev_perc);
else
    fprintf('Precisione statica maggiore di %d. \n',ev_dato);
end

pause

fprintf('\nAnalisi di Stabilità con L(s)=C_s(s)G(s):');
L=series(C_s,G)

% applico il criterio di Nyquist
[L_p,L_z]=pzmap(L);
nz=0; % numero di zeri nel semipiano dx compreso jw
for i=1:length(L_z)
    if real(L_z(i))>=0
        nz=nz+1; 
    end
end

np=0;  % numero di poli nel semipiano dx compreso jw
for i=1:length(L_p)
    if real(L_p(i))>=0
        np=np+1;
    end
end

pause

figure(1)
nyquist(L)
N=input('Numero di giri attorno al punto critico (-1,0)='); 

if nz==N+np & nz==0
    fprintf('L(s) è bibo stabile secondo il criterio di Nyquist \n');
    figure(2)
    margin(L);
else 
    fprintf('L(s) non è bibo stabile secondo il criterio di Nyquist \n');
end

pause
close all;

%% Quesito 3. Mrdb <= 3db and 6 <= wbw <= 20 rad/sec

Mr_ub=3; % upper-bound picco di risonanza in db

delta_cr=smorz_Mr(Mr_ub); % smorzamento critico
if delta_cr > 0.7071 | delta_cr < 0
    fprintf('Errore sullo smorzamento critico, %1.2f',delta_cr);
    return
end
fprintf('\nLo smorzamento critico è pari a %1.2f \n',delta_cr);

pause

% phim > 38°, vista la relazione tra Mr e phim, scelto un margine di fase 
% campione un pò più alto
% wc deve appartenere all'intervallo [6,20] rad/sec

% Obiettivi
phim_ob=51; % °
wc_ob=6.5; % rad/sec

fprintf('Per la pulsazione di attraversamento obiettivo %2.1f rad/sec \n',wc_ob);
[modulo,argomento]=bode(L,wc_ob);
if modulo>1 
    fprintf(' 1) Modulo: %5.2f  > 1\n',modulo);
else 
    fprintf(' 1) Modulo: %5.2f <= 1 \n',modulo);
end

sfasamento=180-(abs(argomento));
if sfasamento>phim_ob
    fprintf(' 2) Sfasamento: %3.2f ° > %3.2f ° obiettivo \n',sfasamento,phim_ob);
else 
    fprintf(' 2) Sfasamento: %3.2f ° < o = %3.2f ° obiettivo \n',sfasamento,phim_ob);
end

pause

fprintf('\n*** Rete Attenuatrice ***\n');
m=1/modulo;
fprintf(' 1) m: %5.2f \n',m);
theta=-5; %°
fprintf(' 2) theta: %3.2f \n',theta);

[tz,tp]=generica(wc_ob,m,theta);
if tz < 0 | tp < 0 | tp < tz
   fprintf('Errore sulle costanti di tempo tz=%d e tp=%d \n',tz,tp);
   return
end
fprintf('Le costanti di tempo sono tz=%5.2f e tp=%5.2f \n',tz,tp);

pause

fprintf('\nCostruisco la rete \n');
C_lag=(1+s*tz)/(1+s*tp)

pause

fprintf('\nFunzione di anello con C_lag(s)\n');
L_lag=series(series(C_s,C_lag),G)

figure(1)
hold on
margin(L)
bode(C_lag)
margin(L_lag)

[modulo,argomento]=bode(L_lag,wc_ob);
fprintf('* Modulo attenuato: %5.2f \n',modulo);

pause

wc_ob=7;
fprintf('\nIncremento la pulsazione di attraversamento obiettivo: %2.1f rad/sec \n',wc_ob);

fprintf('\nPer la nuova pulsazione di attraversamento obiettivo %2.1f rad/sec \n',wc_ob);
[modulo,argomento]=bode(L_lag,wc_ob);
if modulo>1 
    fprintf(' 1) Modulo: %5.2f  > 1\n',modulo);
else 
    fprintf(' 1) Modulo: %5.2f <= 1 \n',modulo);
end

sfasamento=180-(abs(argomento));
if sfasamento>phim_ob
    fprintf(' 2) Sfasamento: %3.2f ° > %3.2f ° obiettivo \n',sfasamento,phim_ob);
else 
    fprintf(' 2) Sfasamento: %3.2f ° < o = %3.2f ° obiettivo \n',sfasamento,phim_ob);
end

pause

fprintf('\n*** Rete Anticipatrice ***\n');
m=1/modulo;
fprintf(' 1) m: %5.2f \n',m);
theta=phim_ob-sfasamento; % °
fprintf(' 2) theta: %3.2f \n',theta);

[tz,tp]=generica(wc_ob,m,theta);
if tz < 0 | tp < 0 | tz < tp
   fprintf('Errore sulle costanti di tempo tz=%d e tp=%d \n',tz,tp);
   return
end
fprintf('Le costanti di tempo sono tz=%5.2f e tp=%5.2f \n',tz,tp);

pause

fprintf('Costruisco la rete \n');
C_lead=(1+s*tz)/(1+s*tp)

pause

fprintf('Funzione di anello con C_lag_lead(s)\n');
L_lag_lead=series(series(series(C_s,C_lag),C_lead),G)

figure(2)
hold on
margin(L)
bode(C_lead)
margin(L_lag_lead)

[modulo,argomento]=bode(L_lag_lead,wc_ob);
fprintf('* Modulo attenuato: %5.2f \n',modulo);
sfasamento=180-abs(argomento);
fprintf('* Sfasamento anticipato: %3.2f °\n',sfasamento);

pause
close all

% T(s)=L(s)/1+L(s) con naturalmente L(s)=L_lag_lead(s) 
T=feedback(L_lag_lead,1)
grid
bodemag(T);

% primo test con phim_ob = 45°
% secondo test con phim_ob = 51°

return















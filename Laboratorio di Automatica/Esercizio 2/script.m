clear
close all

Ts=0.01; %fixed-step size

%% test di linearità & tempo invarianza
fprintf('\nTest di LTI\n')
A=[1 2];
a=1;
b=2;

tau=2;

pause
%% costruzione del modello lineare
fprintf('\nCostruzione del modello\n')

data=sim('misurazione');
t=data.time; % tempo di misurazione

T=length(t); % numero di misurazioni
fprintf('\nNumero di misurazioni T=%d\n',T)
u=data.u; % u(k)
y=data.y; % y(k)

n=4; 
m=1;
fprintf('\nCon n=%d e m=%d\n',n,m)

theta=calcolo_parametri(y,u,n,m,T);
fprintf('\nVettore delle incognite theta: [');
fprintf('%3.2f, ', theta(1:end-1));
fprintf('%3.2f]\n', theta(end));

alpha=theta(1:n); 
beta=theta(n+1:end); 

fprintf('\nFunzione di trasferimento del modello:\n')
Gz=tf(beta',[1 alpha'],Ts,'Variable','z^-1')

% Prima Validazione
fprintf('\nPrima valutazione\n')

figure(1)
subplot(2,1,1),plot(t,data.y,'Color','#3EA2C6'),grid
legend('Black Box','Location','south')
subplot(2,1,2),plot(t,lsim(Gz,data.u,t),'Color','#FF5733'),grid
legend('Modello Approssimato','Location','south')

figure(2) 
plot(t,y,'Color','#3EA2C6')
hold on 
plot(t,lsim(Gz,u,t),'Color','#FF5733')
grid 
legend('Black Box','Modello Approssimato','Location','southwest')
hold off

% Confronto
fprintf('\nConfronto:\n')
figure(3)
Color=["#3EA2C6","#57C784","#F061FA","#F26D6D","blue"];
pos=1;
for m=0:n
    theta=calcolo_parametri(y,u,n,m,T);

    alpha=theta(1:n); 
    beta=theta(n+1:end); 

    Gz=tf(beta',[1 alpha'],Ts,'Variable','z^-1');
    
    subplot(5,1,pos)
    plot(t,y,'Color','#A6ACA9'),hold on, grid
    plot(t,lsim(Gz,u,t),'Color',Color(pos)), hold off

    pos=pos+1;
    pause
end

figure(4)
plot(t,y,'Color','#A6ACA9'),hold on, grid
pos=1;
for m=0:n
    theta=calcolo_parametri(y,u,n,m,T);
    alpha=theta(1:n); 
    beta=theta(n+1:end); 
    Gz=tf(beta',[1 alpha'],Ts,'Variable','z^-1');
    plot(t,lsim(Gz,u,t),'Color',Color(pos))
    pos=pos+1;
end
legend('Black Box','m=0','m=1','m=2','m=3','m=4','Location','southwest')

pause
close all

%% Test-bench
fprintf('\nTest-bench\n')
fprintf('\nConsidero la f.d.t. con n=%d e m=%d\n',n,m); 

fprintf('\nVettore dei parametri alpha: [');
fprintf('%3.2f, ', alpha(1:end-1));
fprintf('%3.2f]\n', alpha(end));

fprintf('\nVettore dei parametri beta: [');
fprintf('%3.2f, ', beta(1:end-1));
fprintf('%3.2f]\n', beta(end));

Gz=tf(beta',[1 alpha'],Ts,'Variable','z^-1')

pause

%% Risposta al gradino delle 3 forme canoniche
fprintf('\nRisposta al gradino\n')
[b,a]=tfdata(Gz,'v');

fprintf('\nCon n=%d e m=%d\n',n,m); 

fprintf('\nVettore a: [');
fprintf('%3.2f, ', a(1:end-1));
fprintf('%3.2f]\n', a(end));

fprintf('\nVettore b: [');
fprintf('%3.2f, ', b(1:end-1));
fprintf('%3.2f]\n', b(end));

pause

a=a(2:end);

R=1; % ampiezza gradino

data=sim('forme_canoniche');
t=data.time;

% step-response del processo 
y=data.y;

% step-response del modello ARMA
ARMA=data.arma;

% step-response del modello TIPO 1
TIPO1=data.tipo1;

% step response del modello TIPO 2
TIPO2=data.tipo2;

figure(1)
plot(t,y), hold on, grid
pause
plot(t,ARMA)
pause
plot(t,TIPO1)
pause
plot(t,TIPO2)
legend('Black box','ARMA','Tipo 1','Tipo 2')

pause

return
















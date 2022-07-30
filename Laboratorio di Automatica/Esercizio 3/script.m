close all
clear

Fs=100; % Intervallo di frequenze che si vogliono rappresentare

N=Fs/2; % numero di campioni
if mod(N,2)~=0
    N=N+1;
end

% dominio del tempo
tstep=1/Fs; % tempo di campionamento
t=0:tstep:(N-1)*tstep;

% dominio delle frequenze
fstep=Fs/N; % frequenza fondamentale
freq=-Fs/2:fstep:Fs/2-fstep;

% dominio delle pulsazioni
puls=2*pi*freq;

% parametri del segnale da processare
A=[1 1];
f=[4 20]; %Hz
phi=[pi/6 -pi/3]; 

%% Linearità
%%% 1.
x1=A(1)*sin(2*pi*f(1)*t+phi(1));

figure(1)
plot(t,x1,'Color','#1776B8')
grid
xlabel('Time(s)')
legend('x1(t)')

% dft x1(t)
fig=[2 3];
X1=fft(x1);
X1=modulo_fase(freq,puls,X1,fig,N);

pause

%%% 2.
x2=A(2)*cos(2*pi*f(2)*t+phi(2));

figure(4)
plot(t,x2,'Color','#1776B8')
grid
xlabel('Time(s)')
legend('x2(t)')
 
% dft x2(t)
fig=[5 6];
X2=fft(x2);
X2=modulo_fase(freq,puls,X2,fig,N);

pause
close all

%%% 3. Segnale completo
x=x1+x2;

figure(1)
fig=[2 3];

plot(t,x,'Color','#1776B8','LineWidth',1.0)
hold on
plot(t,x1,'Color','#64D9CE'),plot(t,x2,'Color','#54CA9A'),grid
xlabel('Time(s)')
legend('x(t)','x1(t)','x2(t)')

X1=fft(x1);
X2=fft(x2);

X=X1+X2;
X=modulo_fase(freq,puls,X,fig,N);

return










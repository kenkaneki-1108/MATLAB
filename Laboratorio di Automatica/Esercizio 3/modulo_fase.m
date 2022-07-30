function X=modulo_fase(freq,puls,X,fig,N)

% rappresentazione spettro ampiezze e fase
% input : dominio delle frequenze, dominio delle pulsazioni, 
%         fft del segnale x, vettore per le figure, il numero di campioni
color=["#EC6A24","#259AD5"];

X=fftshift(X);
X_mag=abs(X/(N/2));
X_ph=deg2rad(angle(X));
        
figure(fig(1))
subplot(2,1,1),stem(freq,X_mag,'Color',color(1)),xlabel('Frequency(Hz)'),title('Modulo','Color',color(1)),grid
subplot(2,1,2),stem(freq,X_ph,'Color',color(2)),xlabel('Frequency(Hz)'),title('Fase','Color',color(2)),grid
        
figure(fig(2)) 
subplot(2,1,1),stem(puls,X_mag,'Color',color(1)),xlabel('Angular freq(rad/sec)'),title('Modulo','Color',color(1)),grid
subplot(2,1,2),stem(puls,X_ph,'Color',color(2)),xlabel('Angular freq(rad/sec)'),title('Fase','Color',color(2)),grid

end



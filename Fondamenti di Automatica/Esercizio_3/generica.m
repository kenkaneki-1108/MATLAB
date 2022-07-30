function [tau1,tau2]=generica(wc,m,phi)
%
% Calcola i parametri della rete correttrice
% I parametri della funzione sono:
% wc  : pulsazione di attraversamento desiderata
% m   : reciproco del modulo della funzione di anello non-compensata |L(j wc)|
% phi : incremento (o decremento) sulla fase desiderato in gradi
%

tau1 = (m^2-m*cos(phi*pi/180))/(wc*m*sin(phi*pi/180));

tau2 =  (m*cos(phi*pi/180) - 1)/(wc*m*sin(phi*pi/180));

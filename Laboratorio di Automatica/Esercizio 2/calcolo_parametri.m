function theta=calcolo_parametri(y,u,n,m,T)

Y=y(n+1:T); % termini noti

PHI=[]; % inizializzazione matrice dei regressori
% costruzione matrice dei regressori
for k=n:T-1
    phi=zeros(1,n+m+1); % k-esima row della PHI
     for j=1:n
        phi(j) = -y(k-j+1);
    end
    for j=1:m+1
        phi(n+j) = u(k-j+2);
    end
    PHI=[PHI;phi];
end

theta=regress(Y,PHI);
%theta=inv(PHI.'*PHI)*PHI.'*Y;


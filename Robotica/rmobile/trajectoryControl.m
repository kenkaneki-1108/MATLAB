function Xdot = trajectoryControl(X,piece,which,param)
    x = X(1); 
    y = X(2); 
    theta = X(3);
    
    xstar = piece(1); ystar = piece(2);
    xdotstar = piece(3); ydotstar = piece(4);
    xddotstar = piece(5); yddotstar = piece(6);

    thetastar = atan2(ydotstar,xdotstar);
    
    vstar = sqrt(xdotstar^2 + ydotstar^2);
    wstar = (yddotstar*xdotstar - xddotstar*ydotstar)/(xdotstar^2 + ydotstar^2);
    switch which
        case 'Linear'
            a=param{1}; delta=param{2};
            [v,w] = linear(x,y,theta,xstar,ystar,thetastar,vstar,wstar,a,delta);
        case 'NotLinear'
            K1=param{1}; K2=param{2}; K3=param{3};
            [v,w] = notLinear(x,y,theta,xstar,ystar,thetastar,vstar,wstar,K1,K2,K3);
        case 'IOLinear'
            b=param{1}; Kx=param{2}; Ky=param{3};
            [v,w] = IOLinear(x,y,theta,xstar,ystar,thetastar,...
                            xdotstar,ydotstar,xddotstar,yddotstar,b,Kx,Ky);
        otherwise
            exception = MException('ThisComponent:notFound','Controllore %s non trovato',which);
            throw(exception);
    end
    Xdot = [ v*cos(theta);
             v*sin(theta);
             w ];
end
%% Controllo lineare
function [v,w] = linear(x,y,theta,xstar,ystar,thetastar,vstar,wstar,a,delta)
    % check
    % 1. convergenza non sicura
    % 2. vstar = cost. e wstar = cost. -> convergenza locale
    % 3. vstar -> 0 se K2 -> infinity

    ex = cos(theta)*(xstar-x) + sin(theta)*(ystar-y);
    ey = -sin(theta)*(xstar-x) + cos(theta)*(ystar-y);
    etheta = thetastar-theta;
    
    K1 = 2*delta*a;
    K2 = (a^2 - wstar^2)/vstar;
    K3 = 2*delta*a;

    v = vstar*cos(etheta) + K1*(xstar-x);
    w = wstar + K2*(ystar-y) + K3*(etheta);
end

%% Controllo non lineare
function [v,w] = notLinear(x,y,theta,xstar,ystar,thetastar,vstar,wstar,K1,K2,K3)
    % scelgo v* e w* bounded e con vdot* e wdot* anch'esse bounded e non
    % convergono simultaneamente a zero -> convergenza globale

    ex = cos(theta)*(xstar-x) + sin(theta)*(ystar-y);
    ey = -sin(theta)*(xstar-x) + cos(theta)*(ystar-y);
    etheta = thetastar-theta;
    
    v = vstar*cos(etheta) + K1(vstar,wstar)*ex;
    w = wstar + (K2*vstar*sin(etheta))/etheta + K3(vstar,wstar)*etheta;
end

%% Controllo IO linearizzato
function [v,w] = IOLinear(x,y,theta,xstar,ystar,thetastar,...
                        xdotstar,ydotstar,xddotstar,yddotstar,b,Kx,Ky)
    
    % la traiettoria da seguire sarà quella del punto B
    xB = x + b*cos(theta);
    yB = y + b*sin(theta);
    
    xBdot_star = xdotstar;
    yBdot_star = ydotstar;
      
    % input ux, uy control law in funzione di B
    ux = xBdot_star + Kx*(xstar-xB);
    uy = yBdot_star + Ky*(ystar-yB);
    
    invT = inv([  cos(theta) -b*sin(theta);
                  sin(theta) b*cos(theta)     ]);
    
    % [v;w] = T-1(theta)*[ux;uy]
    v = dot(invT(1,:),[ux;uy]);
    w = dot(invT(2,:),[ux;uy]);
end



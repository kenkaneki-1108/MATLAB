function Xdot = postureRegulation(X,Xg,which,param)
    x = X(1); 
    y = X(2); 
    theta = X(3);

    xstar = Xg(1); 
    ystar = Xg(2);
    thetastar = Xg(3);

    ex = xstar-x;
    ey = ystar-y;
    etheta = thetastar-theta;

    switch which
        case 'Complete'
            K1=param{1}; K2=param{2}; K3=param{3};
            [v,w]=completeRegulation(ex,ey,etheta,theta,K1,K2,K3);
        case 'Cartesian'
            K1=param{1}; K2=param{2};
            [v,w]=cartesianRegulation(ex,ey,theta,K1,K2);
        otherwise
            exception = MException('ThisComponent:notFound','Controllore %s non trovato',which);
            throw(exception);
    end

    Xdot = [ v*cos(theta);
             v*sin(theta);
             w ];
end
%% Controllore completo
function [v,w]=completeRegulation(ex,ey,etheta,theta,K1,K2,K3)
    rho = sqrt(ex.^2 + ey.^2);
    gamma = atan2(ey,ex) - theta;
    delta = gamma - etheta;
   
    v = K1*rho.*cos(gamma);
    w = K2*gamma + K1.*sin(gamma).*cos(gamma).*(gamma+K3*delta).*(1./gamma);
end

%% Controllore cartesiano
function [v,w]=cartesianRegulation(ex,ey,theta,K1,K2)
    v = K1*(ex.*cos(theta)+ey.*sin(theta));
    w = K2*atan2(ey,ex)-theta;
end


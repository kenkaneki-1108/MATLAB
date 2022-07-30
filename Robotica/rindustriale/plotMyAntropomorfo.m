function plotMyAntropomorfo(Rb0,Rb3,DH,q,Q)
    figure("Name","Cinematica Diretta"); hold on; grid on; axis([-1 2 -1 2 -3 2]);
    xlabel("X"); ylabel("Y"); zlabel("Z");

    Rb2 = matrixRT(DH(1:2,:),Rb0);
    R0b = inv(Rb0);
    for i = 1:size(Q,2)   
        T3 = cinematicaDiretta(Rb3,q,Q(:,i));
    
        Pb3 = [T3(1:3,4); 1];
        P03 = R0b*Pb3; % P03 = inv(Rb0)*Pb3 = R0b*Pb3
        X(i) = P03(1); Y(i) = P03(2); Z(i) = P03(3);
        
        % Primo braccio, spalla
        Pr1 = [-0.5 -0.5 -1]; 

        % Secondo braccio 
        T2 = cinematicaDiretta(Rb2,q(1:2),Q(1:2,i));

        Pb2 = [T2(1:3,4); 1];
        Pr2 = R0b*Pb2;
        braccio2 = [Pr1; (Pr2(1:3))'];
        b2 = plot3(braccio2(:,1),braccio2(:,2),braccio2(:,3),"k","linewidth",4);
        
        % Terzo braccio
        braccio3 = [(Pr2(1:3))'; X(i) Y(i) Z(i)];
        b3 = plot3(braccio3(:,1),braccio3(:,2),braccio3(:,3),"k","linewidth",4);
        
        plot3(X(i),Y(i),Z(i),"ob");
        pause(0.01);
        delete(b2);
        delete(b3);
    end
end

function T = cinematicaDiretta(R,q,Q)
    T = double(subs(R,q,Q'));
end




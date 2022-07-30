function X = apf(Xs,Xg,Xobs,A)
    Ja = @(x,y,xg,yg) 0.5*((x-xg).^2+(y-yg).^2);
    dxJa = @(x,y,xg,yg) x-xg;
    dyJa = @(x,y,xg,yg) y-yg;

    Jr = @(x,y,xo,yo,d) 1 ./ ((x-xo).^2 + (y-yo).^2 - d.^2).^2;
    dxJr = @(x,y,xo,yo,d) -4*(x-xo) ./ ((x-xo).^2 + (y-yo).^2 - d^2).^3;
    dyJr = @(x,y,xo,yo,d) -4*(y-yo) ./ ((x-xo).^2 + (y-yo).^2 - d^2).^3;
    
    xx = 0:0.5:A(1); 
    yy = 0:0.5:A(2);
    [XX,YY]=meshgrid(xx,yy);
    
    JA = Ja(XX,YY,Xg(1),Xg(2));
    dxJA = dxJa(XX,YY,Xg(1),Xg(2));
    dyJA = dyJa(XX,YY,Xg(1),Xg(2));

    JR = zeros(size(JA));
    dxJR = zeros(size(dxJA));
    dyJR = zeros(size(dyJA));
    
    for i = 1:size(Xobs,1)
        JR = JR + Jr(XX,YY,Xobs(i,1),Xobs(i,2),Xobs(i,3));
        dxJR = dxJR + dxJr(XX,YY,Xobs(i,1),Xobs(i,2),Xobs(i,3));
        dyJR = dyJR + dyJr(XX,YY,Xobs(i,1),Xobs(i,2),Xobs(i,3));
    end

    wa = input("    Peso potenziale attrattivo, wa = ");
    wr = input("    Peso potenziale repulsivo, wr = ");
    
    J = wa*JA + wr*JR;
    dxJ = wa*dxJA + wr*dyJR;
    dyJ = wa*dyJA - wr*dxJR;
  
    X = optimization(Xs,Xg,Xobs,dxJa,dyJa,dxJr,dyJr,wa,wr);
    plotAPF(X,Xs,Xg,Xobs,XX,YY,J,dxJ,dyJ)   
end

function X = optimization(Xs,Xg,Xobs,dxJa,dyJa,dxJr,dyJr,wa,wr)
    alpha = 0.05;
    maxIter = 750;
    inGoal = 0.2;

    X=zeros(maxIter,2);
    Xk=[Xs(1) Xs(2)];

    for k=1:maxIter
        X(k,:) = Xk;

        if (Xk(1)-Xg(1))^2 + (Xk(2)-Xg(2))^2 <= inGoal^2
           break;
        end

        nablaJa = [dxJa(X(k,1),X(k,2),Xg(1),Xg(2));
                   dyJa(X(k,1),X(k,2),Xg(1),Xg(2))];
        nablaJr = [0;0];
        for i=1:size(Xobs,1)
            nablaJr = nablaJr + [dxJr(X(k,1),X(k,2),Xobs(i,1),Xobs(i,2),Xobs(i,3));
                                 dyJr(X(k,1),X(k,2),Xobs(i,1),Xobs(i,2),Xobs(i,3))];
        end

        nablaJ = wa*nablaJa + wr*nablaJr;
        Xk = Xk - alpha*[nablaJ(1) nablaJ(2)];
    end
    if k < maxIter
        X(k+1:end,:) = [];
    end
end

function plotAPF(X,Xs,Xg,Xobs,XX,YY,J,dxJ,dyJ)
    dxJn = dxJ./sqrt(dxJ.^2+dyJ.^2);
    dyJn = dyJ./sqrt(dxJ.^2+dyJ.^2);

    figure("Name","Artificial potetial fields")
        subplot(1,2,1), title("Potenziale artificiale completo"), hold on, grid on
            surf(XX,YY,J)
            plot(Xg(1),Xg(2),'xr','LineWidth',3)
        hold off
        
        subplot(1,2,2),title("Andamento dell'anti-gradiente"), hold on, grid on
            quiver(XX,YY,-dxJn,-dyJn)
            plot(Xobs(:,1),Xobs(:,2),'or')
            text(Xs(1),Xs(2),'Start','FontSize',10,'Color','k')
            text(Xg(1),Xg(2),'Goal','FontSize',10,'Color','k')
            for i=1:size(X,1)
                plot(X(i,1),X(i,2),'.r')
            end
        hold off
end
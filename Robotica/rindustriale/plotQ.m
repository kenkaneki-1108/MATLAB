function plotQ(Q,QDot,trange,typePath)
    Tsim = [];
    switch typePath
        case 'Triangolo'
            for i=1:size(trange,1)
                Tsim = [Tsim, trange(i,:)];
            end
        case 'Circonferenza'
            Tsim = trange;
    end
    
    Q = Q*180/pi; 
    QDot = QDot*180/pi;

figure("Name","Q(t)")
    subplot(3,1,1);
    plot(Tsim,Q(1,:))
    xlabel('t'); ylabel('q1(t)'); 

    subplot(3,1,2);  
    plot(Tsim,Q(2,:))
    xlabel('t'); ylabel('q2(t)'); 

    subplot(3,1,3);
    plot(Tsim,Q(3,:))
    xlabel('t'); ylabel('q3(t)'); 

 figure("Name","Qdot(t)")
    subplot(3,1,1);
    plot(Tsim,QDot(1,:))
    xlabel('t'); ylabel('dq1(t)'); 

    subplot(3,1,2);
    plot(Tsim,QDot(2,:))
    xlabel('t'); ylabel('dq2(t)'); 

    subplot(3,1,3);
    plot(Tsim,QDot(3,:))
    xlabel('t'); ylabel('dq3(t)'); 
end
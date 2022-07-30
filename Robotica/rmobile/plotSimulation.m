function plotSimulation(robot,Xg,obs,sol,A)
    data=load('data.mat','-mat');
    Cline = {'#FFA143','#244CD1'};

    hold on,grid minor,axis([0 A(1) 0 A(2)])

    % start 
    plot(robot(1),robot(2),'x','Color',data.green,'LineWidth',3)
    text(robot(1)-0.75,robot(2)-0.75,'Start','FontSize',15,'Color',data.blue)

    % goal
    plot(Xg(1),Xg(2),'x','Color',data.red,'LineWidth',3)
    text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',15,'Color',data.blue)

    % obstacles and room
    for i=1:size(obs,1)
        xo = obs(i,1);
        yo = obs(i,2);
        do = obs(i,3);
        rectangle('Position',[xo-do yo-do 2*do 2*do], 'Curvature',[1 1], ...
            'FaceColor',data.grey,'EdgeColor',data.greys,'LineWidth',1.5)
    end
    rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)

    xr = sol(:,1);
    yr = sol(:,2);
    thetar = sol(:,3);

    for i=1:size(sol,1)
        plot(xr(i),yr(i),'LineStyle','-','LineWidth',2,'Color',Cline{2})
        unycicle = plotUnycicle(xr(i),yr(i),thetar(i),robot(4));
        pause(0.05);

        if i~=size(sol,1)
            delete(unycicle);
        end
    end
    hold off
end

function triangle = plotUnycicle(x,y,theta,d)
    theta=pi/2 - atan2(sin(theta),cos(theta));
    Pc = [x;y];
    coordinate=[cos(theta) sin(theta);-sin(theta) cos(theta)]*[0 d/2 -d/2; d/2 -d/2 -d/2]+Pc;
    triangle = plot(polyshape(coordinate(1,:),coordinate(2,:)),'LineWidth',1,'FaceColor','b');
end
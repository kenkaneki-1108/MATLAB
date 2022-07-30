function plotEnvironment(robot,obs,Xs,Xg,Xobs,A)
    data = load('data.mat','-mat');

%%%%%%%%%%
    subplot(1,2,1),title('Scenario originale','Color','k')
        axis([0 A(1) 0 A(2)]), hold on, grid minor

        % obstacles and room
        for i=1:size(Xobs,1)
            xo = Xobs(i,1);
            yo = Xobs(i,2);
            do = obs(i,3);
            rectangle('Position',[xo-do yo-do 2*do 2*do],'Curvature',[1 1], ...
                'FaceColor',data.grey,'EdgeColor',data.greys,'LineWidth',1)
            plot(xo,yo,'.k')
        end
        rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)

        % robot
        rectangle('Position',[robot(1)-0.5*robot(4) robot(2)-0.5*robot(4) robot(4) robot(4)], ...
            'Curvature',[1 1],'FaceColor',data.green,'EdgeColor',data.green,'LineWidth',1.5)
        text(robot(1)-robot(4),robot(2)+robot(4),'Robot','FontSize',15,'Color',data.blue)

        % goal
        plot(Xg(1),Xg(2),'x','Color',data.red,'LineWidth',3)
        text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',15,'Color',data.blue)

    hold off
%%%%%%%%%%
    subplot(1,2,2),title('Scenario astratto','Color','k')
        axis([0 A(1) 0 A(2)]), hold on, grid minor

        % obstacles and room
        for i=1:size(Xobs,1)
            xo = Xobs(i,1);
            yo = Xobs(i,2);
            do = obs(i,3);
            rectangle('Position',[xo-do yo-do 2*do 2*do],'Curvature',[1 1], ...
                'FaceColor',data.grey,'EdgeColor',data.greys,'LineWidth',1)

            d = Xobs(i,3);
            rectangle('Position',[xo-d yo-d 2*d 2*d],'EdgeColor',data.greys,'LineWidth',1.5)
            plot(xo,yo,'.k')
        end
        rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)
            
        % start 
        plot(Xs(1),Xs(2),'Marker','.','MarkerFaceColor',data.green,'MarkerEdgeColor',data.green,'MarkerSize',10)
        text(Xs(1)-robot(4),Xs(2)+robot(4),'Start','FontSize',15,'Color',data.blue)

        % goal
        plot(Xg(1),Xg(2),'x','Color',data.red,'LineWidth',3)
        text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',15,'Color',data.blue)
    hold off
end
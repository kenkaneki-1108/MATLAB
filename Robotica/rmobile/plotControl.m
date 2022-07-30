function plotControl(Xs,Xg,dM,Xobs,x,y,sol,A)
    data=load('data.mat','-mat');
    Cline = {'#FFA143','#244CD1'};

    hold on,grid minor,axis([0 A(1) 0 A(2)])

    % start 
    plot(Xs(1),Xs(2),'x','Color',data.green,'LineWidth',3)
    text(Xs(1)-0.75,Xs(2)-0.75,'Start','FontSize',15,'Color',data.blue)

    % goal
    rectangle('Position',[Xg(1)-dM Xg(2)-dM 2*dM 2*dM],'Curvature',[1 1], ...
        'FaceColor',data.bluecc,'EdgeColor',data.bluecc)

    plot(Xg(1),Xg(2),'x','Color',data.red,'LineWidth',3)
    text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',15,'Color',data.blue)

    % obstacles and room
    for i=1:size(Xobs,1)
        xo = Xobs(i,1);
        yo = Xobs(i,2);
        do = Xobs(i,3);
        rectangle('Position',[xo-do yo-do 2*do 2*do], ...
            'FaceColor',data.grey,'EdgeColor',data.greys,'LineWidth',1.5)
    end
    rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)


    % trajectory star
    step = 0.01;
    for i=1:length(x) % per ogni break della spline
        plot(x{i,1}(i-1:step:i),y{i,1}(i-1:step:i), ...
            'LineStyle','-','LineWidth',1.5,'Color',Cline{1})
    end

    xr = sol(:,1);
    yr = sol(:,2);
    thetar = sol(:,3);
    % real trajectory
    plot(xr,yr,'LineStyle','-','LineWidth',2,'Color',Cline{2})

end
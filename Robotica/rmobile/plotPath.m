function plotPath(Xs,Xg,Xobs,x,y,X,A)
    data=load('data.mat');

%%%%%%%%%%%%%
    subplot(1,2,1),title('Path','Color','k')
    hold on, grid on, axis([0 A(1) 0 A(2)])
    
    % obstacles and room
    for i=1:size(Xobs,1)
        xo = Xobs(i,1); 
        yo = Xobs(i,2); 
        d = Xobs(i,3);
        rectangle('Position',[xo-d yo-d 2*d 2*d], ...
            'FaceColor',data.grey,'EdgeColor',data.greys,'LineWidth',1.5)
    end
    rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)

    % native function and X-points
    plot(X(:,1)',X(:,2)','LineStyle','-','LineWidth',2,'Color',data.bluec)
    for i=2:size(X,1)-1
        plot(X(i,1),X(i,2),'or','LineWidth',1.5)
    end
    
    % start and goal
    plot(Xs(1),Xs(2),'xk','LineWidth',3)
    text(Xs(1)-0.5,Xs(2)-0.5,'Start','FontSize',10,'Color',data.blue)

    plot(Xg(1),Xg(2),'xk','LineWidth',3)
    text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',10,'Color',data.blue)
    hold off
%%%%%%%%%%%%%%
    subplot(1,2,2),title('Interpolazione by Spline','Color','k')
        hold on, grid on,axis([0 A(1) 0 A(2)])
        
        % obstacles and room    
        for i=1:size(Xobs,1)
            xo = Xobs(i,1);
            yo = Xobs(i,2);
            d = Xobs(i,3);
            rectangle('Position',[xo-d yo-d 2*d 2*d],'LineWidth',1.5,...
                'FaceColor',data.grey,'EdgeColor',data.greys)
        end
        rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)

        % interpolation by spline 
        step = 0.01;
        for i=1:size(x,1) % for each break
             plot(x{i,1}(i-1:step:i),y{i,1}(i-1:step:i), ...
                 'LineStyle','-','LineWidth',2,'Color',data.blue)
        end
       
        % points X
        for i=2:size(X,1)-1
            plot(X(i,1),X(i,2),'or','LineWidth',1.5)
        end

        % start and goal
        plot(Xs(1),Xs(2),'xk','LineWidth',3)
        text(Xs(1)-0.5,Xs(2)-0.5,'Start','FontSize',10,'Color',data.blue)

        plot(Xg(1),Xg(2),'xk','LineWidth',3)
        text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',10,'Color',data.blue)
        hold off
%%%%%%%%%%%
end 
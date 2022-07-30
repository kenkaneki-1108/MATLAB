function X = visibilityGraph(Xs,Xg,Xobs,A)
    n = input("     Norma: ");
    if n ~= 1 && n ~= 2
        exception = MException('ThisComponent:notFound','Norm %s not found',n);
        throw(exception);
    end

    figure("Name","Visibility Graph")
        [vx,vy] = buildVisibility(Xs,Xg,Xobs,A);
        X = resolveVisibility(vx,vy,Xs,Xg,Xobs,A,n);
    hold off
end

%% Build Graph
function [vx,vy]=buildVisibility(Xs,Xg,Xobs,A)
    % corners of the room [[x;y], ...]
    wall = zeros(2,4);
        wall(:,1) = [0;0];
        wall(:,2) = [0;A(2)];
        wall(:,3) = [A(1);0];
        wall(:,4) = [A(1);A(2)];
    
    % corners for each obstacles 
    obs = zeros(2,4*size(Xobs,1)); % 4 points for each obs
    j=1;
    for i=1:size(Xobs,1)
        xo = Xobs(i,1);
        yo = Xobs(i,2);
        do = Xobs(i,3);
        
        xmd = xo-do; xpd = xo+do;
        ymd = yo-do; ypd = yo+do; 
    
        obs(:,j) = [xmd;ypd];
        obs(:,j+1) = [xmd;ymd];
        obs(:,j+2) = [xpd;ypd];
        obs(:,j+3) = [xpd;ymd];
        j=j+4;
    end
    
    % links room-obs
    vx = zeros(2,4*size(wall,2)); % [ [x1;x2], ...]
    vy= zeros(2,4*size(wall,2)); % [ [y1;y2], ...]
    k=1;
    for i=1:size(wall,2)
        for o=1:size(obs,2)
            vx(:,k) = [wall(1,i); obs(1,o)];
            vy(:,k) = [wall(2,i); obs(2,o)];
            k=k+1;
        end
    end

    % links obs-obs
    for i=1:4:size(obs,2)
        for o1=i:i+3
            for o2=i+4:size(obs,2)
                vx = [vx, [obs(1,o1); obs(1,o2)]];
                vy = [vy, [obs(2,o1); obs(2,o2)]];
            end
        end
    end

    % links corners of same obs
    for i=1:size(Xobs,1)
        xo = Xobs(i,1);
        yo = Xobs(i,2);
        do = Xobs(i,3);
        
        xmd = xo-do; xpd = xo+do;
        ymd = yo-do; ypd = yo+do; 
        vx = [ vx,[xmd; xmd],... % (xmd,ypd)-(xmd,ymd)
                  [xmd; xpd],... % (xmd,ypd)-(xpd,ypd)
                  [xmd; xpd],... % (xmd,ypd)-(xpd,ymd)
                  [xpd; xpd],... % (xpd,ypd)-(xpd,ymd)
                  [xpd; xmd],... % (xpd,ypd)-(xmd,ymd)
                  [xmd; xpd] ];   % (xmd,ymd)-(xpd,ymd)
        vy = [ vy,[ypd; ymd],... % (xmd,ypd)-(xmd,ymd)
                  [ypd; ypd],... % (xmd,ypd)-(xpd,ypd)
                  [ypd; ymd],... % (xmd,ypd)-(xpd,ymd)
                  [ypd; ymd],... % (xpd,ypd)-(xpd,ymd)
                  [ypd; ymd],... % (xpd,ypd)-(xmd,ymd)
                  [ymd; ymd] ];   % (xmd,ymd)-(xpd,ymd)
    end
    
    % insert start and goal
    % link start-goal
    vx = [vx,[Xs(1); Xg(1)]];
    vy = [vy,[Xs(2); Xg(2)]];
    
    % links with room
    for i=1:size(wall,2)
        vx = [vx, [Xs(1); wall(1,i)], [Xg(1); wall(1,i)]];
        vy = [vy, [Xs(2); wall(2,i)], [Xg(2); wall(2,i)]];
    end
    
    % links with obs
    for i=1:size(obs,2)
        vx = [vx, [Xs(1); obs(1,i)], [Xg(1); obs(1,i)]];
        vy = [vy, [Xs(2); obs(2,i)], [Xg(2); obs(2,i)]];
    end

%%%%%%%%%
    subplot(1,3,1), title("Visibility")
        hold on,grid minor,axis([0 A(1) 0 A(2)])
        plot(vx,vy,'Color','blue')
        plot(wall(1,:),wall(2,:),'.r','LineWidth',2.5)
        plot(obs(1,:),obs(2,:),'.r','LineWidth',2.5)

        % start and goal
        plot(Xs(1),Xs(2),'.r','LineWidth',2.5)
        plot(Xg(1),Xg(2),'.r','LineWidth',2.5)
        text(Xs(1)-0.5,Xs(2)-0.5,'Start','FontSize',10,'Color','red')
        text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',10,'Color','red')
    hold off
%%%%%%%%%%
end

%% Resolve Graph
function path = resolveVisibility(vx,vy,Xs,Xg,Xobs,A,n)
    data=load('data.mat','-mat');
    % clear graph 
    vxc = []; vyc = [];
    for i=1:size(vx,2)
        flag = 1;
        for o=1:size(Xobs,1)
            if canSee(vx(:,i),vy(:,i),Xobs(o,:))==0
                flag = 0;
                break
            end
        end
        if flag == 1
            vxc=[vxc,vx(:,i)];
            vyc=[vyc,vy(:,i)];
        end
    end
    vx=vxc; vy=vyc;
    vxc=[]; vyc=[];
    
%%%%%%%%
    subplot(1,3,2), title("Visibility Clear")
        hold on,grid minor,axis([0 A(1) 0 A(2)])
        plot(vx,vy,'Color','blue')
        
        % obstacles and room
        for i=1:size(Xobs,1)
            xo = Xobs(i,1); 
            yo = Xobs(i,2); 
            d = Xobs(i,3);
            rectangle('Position',[xo-d yo-d 2*d 2*d], ...
                'EdgeColor',data.greys,'LineWidth',1.5)
        end
        rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)

        % start and goal
        plot(Xs(1),Xs(2),'.r','LineWidth',2.5)
        plot(Xg(1),Xg(2),'.r','LineWidth',2.5)
        text(Xs(1)-0.5,Xs(2)-0.5,'Start','FontSize',10,'Color','red')
        text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',10,'Color','red')
    hold off
%%%%%%%%%%

    [start,goal,nodes,edge,distance] = buildGraph(vx,vy,Xs,Xg,n); 
    path = pathOnGraph(start,goal,nodes,edge,distance,vx,vy);

%%%%%%%%
    subplot(1,3,3), title("Percorso da start a goal")
        hold on,grid minor,axis([0 A(1) 0 A(2)])
        plot(vx,vy,'Color','blue')
        plot(path(:,1),path(:,2),'Color',data.red,'LineWidth',2)

        % obstacles and room
        for i=1:size(Xobs,1)
            xo = Xobs(i,1); 
            yo = Xobs(i,2); 
            d = Xobs(i,3);
            rectangle('Position',[xo-d yo-d 2*d 2*d], ...
                'FaceColor',data.grey,'EdgeColor',data.greys,'LineWidth',1.5)
        end
        rectangle('Position',[0 0 A(1) A(2)],'EdgeColor',data.greys,'LineWidth',1.5)

        % start and goal
        plot(Xs(1),Xs(2),'.r','LineWidth',3)
        text(path(1,1)-0.5,path(1,2)-0.5,'Start','FontSize',10,'Color','red')

        plot(Xg(1),Xg(2),'.r','LineWidth',3)
        text(path(end,1)+0.5,path(end,2)+0.5,'Goal','FontSize',10,'Color','red')
    hold off
%%%%%%%%%
end

function flag = canSee(X1,X2,Xobs) 
    % X1 = vx = [x1 x2] ,... X2 = vy = [y1 y2]
    if (X1(1)-X2(1)) >= 0 || (X1(2)-X2(2)) >= 0
        x1 = X1(2);
        x2 = X1(1);
        y1 = X2(2);
        y2 = X2(1);
    else
        x1 = X1(1);
        x2 = X1(2);
        y1 = X2(1);
        y2 = X2(2);
    end
    flag=1;
    error = 0.00001;

    xo = Xobs(1);
    yo = Xobs(2);
    do = Xobs(3)-error;   
    xmd = xo-do; xpd = xo+do;
    ymd = yo-do; ypd = yo+do;
    
    lambda = 0.0125;
    while lambda < 1
        xy = [x1;y1] + lambda.*([x2;y2]-[x1;y1]);
        lambda = lambda + 0.0125;
        [in,on] = inpolygon(xy(1),xy(2),[xmd xpd xmd xpd],[ymd ypd ypd ymd]);
        if in % è un punto interno all'ostacolo?
            flag=0;
            break
        end
        on=[];
    end
end

function [start,goal,nodes,edge,distance] = buildGraph(vx,vy,Xs,Xg,n)
    % build array for nodes of the graph
    nodes = [vx(1,1);vy(1,1)];
    for i=1:size(vx,2)
        for j=1:size(vx,1)
            flag = 0;
            xy = [vx(j,i);vy(j,i)];
            for k=1:size(nodes,2)
                if nodes(1,k) == xy(1) && nodes(2,k) == xy(2)
                    flag = 1;
                    break
                end
            end
            if flag == 0
                nodes = [nodes, xy];
            end
        end
    end
    
    distance = ones(1,size(vx,2));
    for i=1:size(vx,2)
        distance(i) = norm([vx(1,i)-vx(2,i),vy(1,i)-vy(2,i)],n);
    end
    
    % I Build main map and map to manage edges,then apply Dijkstra
    map(1:size(nodes,2),1:size(nodes,2)) = Inf;
    map_edge(1:size(nodes,2),1:size(nodes,2)) = 0;
    
    % useful to know in which position s and g are in nodes
    start = -1;
    goal = -1; 
    N = size(nodes,2);
    for i=1:N
        if nodes(1,i) == Xs(1) && nodes(2,i) == Xs(2)
            start = i; % source node reference
        end
        if nodes(1,i) == Xg(1) && nodes(2,i) == Xg(2)
            goal = i; % goal node reference
        end
        for j=1:size(vx,2)
            if nodes(1,i) == vx(1,j) && nodes(2,i) == vy(1,j)
                for k=1:N
                    if nodes(1,k) == vx(2,j) && nodes(2,k) == vy(2,j)
                        % edge between node i and node k
                        map(i,k) = distance(j);
                        map(k,i) = distance(j);
                        map_edge(i,k) = j; % reference to vx(:,j) and vy(:,j) -> edge
                        map_edge(k,i) = j;
                        break
                    end
                end
            elseif nodes(1,i) == vx(2,j) && nodes(2,i) == vy(2,j)
                for k=1:N
                    if nodes(1,k) == vx(1,j) && nodes(2,k) == vy(1,j)
                        % edge between node i and node k
                        map(i,k) = distance(j);
                        map(k,i) = distance(j);
                        map_edge(i,k) = j; % reference to vx(:,j) and vy(:,j) -> edge
                        map_edge(k,i) = j;
                        break
                    end
                end
            end
        end
    end

    edge = dijkstra(start,map,map_edge); % return edges of minimum spanning tree 
end

function ret = pathOnGraph(start,goal,nodes,edge,distance,vx,vy)
    % I look for the shortest path from start to goal and 'translate' it into my reference system 

    % Build param for matlab graph
    N = size(nodes,2);
    map(1:N,1:N) = 0;
    for i=1:N
        for j=1:length(edge)
            if edge(j) ~= 0
                if nodes(1,i) == vx(1,edge(j)) && nodes(2,i) == vy(1,edge(j))
                    for k=1:N
                        if nodes(1,k) == vx(2,edge(j)) && nodes(2,k) == vy(2,edge(j))
                            map(i,k) = distance(j);
                            map(k,i) = distance(j);
                            break
                        end
                    end
                elseif nodes(1,i) == vx(2,edge(j)) && nodes(2,i) == vy(2,edge(j))
                    for k=1:N
                        if nodes(1,k) == vx(1,edge(j)) && nodes(2,k) == vy(1,edge(j))
                            map(i,k) = distance(j);
                            map(k,i) = distance(j);
                            break
                        end
                    end
                end
            end
        end
    end

    s = zeros(1,N-1);
    t = zeros(1,N-1);
    weights = zeros(1,N-1);
    index = 1;
    for i=1:N
        j = i;
        for k=j:N
            if map(i,k) > 0
                s(index) = i;
                t(index) = k;
                weights(index) = map(i,k);
                index = index+1;
            end
        end
    end

    % Call matlab functions
    G = graph(s,t,weights);
    path = shortestpath(G,start,goal);
    ret = ones(length(path),2);
    for i=1:length(path)
        ret(i,:) = [nodes(1,path(i)), nodes(2,path(i))];
    end
end

function edge = dijkstra(start,map,map_edge)
    N = length(map);
    distance(1:N) = Inf;
    edge(1:N) = 0; 
    visited(1:N) = 0;
    distance(start) = 0;
    while sum(visited) < N
        candidates(1:N) = Inf;
        for index=1:N
            if visited(index) == 0
                candidates(index) = distance(index);
            end
        end
        [currentDistance, currentPoint] = min(candidates);
        for index=1:N
            newDistance = currentDistance + map(currentPoint,index);
            if newDistance < distance(index)
                distance(index) = newDistance; 
                edge(index) = map_edge(currentPoint,index);
            end
        end
        visited(currentPoint) = 1;
    end
end








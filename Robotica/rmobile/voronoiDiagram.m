function X = voronoiDiagram(Xs,Xg,Xobs,A) 
    n = input("     Norma: ");
    if n ~= 1 && n ~= 2
        exception = MException('ThisComponent:notFound','Norm %s not found',n);
        throw(exception);
    end

    step = input("     Passo di discretizzazione dell'ambiente: ");
    if step <= 0
        exception = MException('ThisComponent:notFound','Step %s <= 0',step);
        throw(exception);
    end

    figure("Name","Voronoi diagram")
        [vx,vy] = buildVoronoi(Xs,Xg,Xobs,A,step);
        X = resolveVoronoi(vx,vy,Xs,Xg,Xobs,A,n);
    hold off
end

%% Build Voronoi
function [vx, vy] = buildVoronoi(Xs,Xg,Xobs,A,step)
    data = load('data.mat','-mat');

%%%%%%%%%%
    subplot(1,4,1),title("Discretizzazione dell'ambiente")
        hold on, grid minor, axis([0 A(1) 0 A(2)])
        % room
        walls = [];
        walls = [walls; discrLine([A(1) 0],[0 0],step)];
        walls = [walls; discrLine([0 A(2)],[0 0],step)];
        walls = [walls; discrLine([A(1) A(2)],[A(1) 0],step)];
        walls = [walls; discrLine([A(1) A(2)],[0 A(2)],step)];
    
    % obstacles, uso l'array obs che mi servirà per pulire il diagramma successivamente
    obs = [];
    for i=1:size(Xobs,1)
        xo = Xobs(i,1);
        yo = Xobs(i,2);
        do = Xobs(i,3);
        plot(xo,yo,'.k')
    
        % assumendo che tutti gli ostacoli siano interni all'ambiente, determino gli spigoli degli ostacoli
        xmd = xo-do;
        xpd = xo+do;
        ymd = yo-do;
        ypd = yo+do; 
            
        obs = [obs; discrLine([xmd ypd],[xmd ymd],step);
                    discrLine([xpd ymd],[xmd ymd],step);
                    discrLine([xpd ypd],[xpd ymd],step);
                    discrLine([xpd ypd],[xmd ypd],step) ];
    end

    % start and goal
    plot(Xs(1),Xs(2),'.r','LineWidth',3),text(Xs(1)-0.5,Xs(2)-0.5,'Start','FontSize',10,'Color',data.blue)
    plot(Xg(1),Xg(2),'.r','LineWidth',3),text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',10,'Color',data.blue)

    hold off
%%%%%%%

    points = [walls;obs];
    [vx, vy] = voronoi(points(:,1),points(:,2));
    [vx,vy] = clearVoronoi(vx,vy,Xobs,A); % pulisco il diagramma dagli archi che non mi servono

%%%%%%%%%%
   subplot(1,4,2),title("Diagramma di Voronoi")
       hold on,grid minor,axis([0 A(1) 0 A(2)])
       plot(vx,vy,'Color','blue')
       for i=1:size(points,1)
            plot(points(i,1),points(i,2),'.k')
       end
       
       % obstacles
       for i=1:size(Xobs,1)
            xo = Xobs(i,1);
            yo = Xobs(i,2);
            d = Xobs(i,3);    
            rectangle('Position',[xo-d yo-d 2*d 2*d],'EdgeColor',data.greys,'LineWidth',1.5)
       end
       plot(vx(1,:),vy(1,:),'ok')
       plot(vx(2,:),vy(2,:),'ok')

       % start and goal
       plot(Xs(1),Xs(2),'.r','LineWidth',3),text(Xs(1)-0.5,Xs(2)-0.5,'Start','FontSize',10,'Color',data.blue)
       plot(Xg(1),Xg(2),'.r','LineWidth',3),text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',10,'Color',data.blue)

       hold off
%%%%%%%%%
end

function [vx,vy] = clearVoronoi(vx,vy,Xobs,A)
    % track of the points inside an obstacle, matrix with 'numObs' rows
    IN1 = zeros(size(Xobs,1),size(vx,2)); 
    IN2 = zeros(size(Xobs,1),size(vx,2));
    for i=1:size(Xobs,1)
        xo = Xobs(i,1);
        yo = Xobs(i,2);
        do = Xobs(i,3);    

        xmd = xo-do;
        xpd = xo+do;
        ymd = yo-do;
        ypd = yo+do;

        % I check if the first points [vx(1,:) vy(1,:)] is in the obstracles
        [in, on] = inpolygon(vx(1,:),vy(1,:),[xmd xpd xmd xpd],[ymd ypd ypd ymd]); 

        IN1(i,:) = in; % I'm only interested in internal points

         % I check if the second points [vx(2,:) vy(2,:)] is in the obstracles 
        [in, on] = inpolygon(vx(2,:),vy(2,:),[xmd xpd xmd xpd],[ymd ypd ypd ymd]);   

        IN2(i,:) = in;
    end
    on = [];

   % I mark the edges that I have to eliminate
   delete = zeros(1,size(vx,2));
   for i=1:length(delete)
        for o=1:size(Xobs,1)
            % if at least one of the two points is inside an obstacle
            if IN1(o,i) == 1 || IN2(o,i) == 1 
                delete(i) = 1; % this edge must be deleted
            end
            if vx(1,i) == vx(2,i) && vy(1,i) == vy(2,i) % I delete the coincident edges in a poin, trivial data
                delete(i) = 1;
            end
        end
   end

   vxc = zeros(size(vx,1),size(vx,2));
   vyc = zeros(size(vy,1),size(vy,2));
   j = 0;
   for i=1:size(vx,2)
       % if it is not to delete
       if delete(i) == 0 
           % I check if this edge is inside of room
           if vx(1,i) >= 0 && vx(1,i) <= A(1) && vx(2,i) >= 0 && vx(2,i) <= A(1) &&...
                   vy(1,i) >= 0 && vy(1,i) <= A(2) && vy(2,i) >= 0 && vy(2,i) <= A(2)
               j=j+1;
               vxc(:,j) = vx(:,i);
               vyc(:,j) = vy(:,i);
           end
       end
   end
   vx = vxc(:,1:j);
   vy = vyc(:,1:j);
end

function ret = discrLine(X1,X2,step) 
    % I discretize the environment
    if (X1(1)-X2(1)) >= 0 || (X1(2)-X2(2)) >= 0
        x1 = X2(1);
        y1 = X2(2);

        x2 = X1(1);
        y2 = X1(2);
    else
        x1 = X1(1);
        y1 = X1(2);

        x2 = X2(1);
        y2 = X2(2);
    end

    eq = @(x,y,x1,y1,x2,y2) (y-y1).*(x2-x1) - (x-x1).*(y2-y1);

    ret = [];
    xmin = min(x1,x2); xmax = max(x1,x2);
    ymin = min(y1,y2); ymax = max(y1,y2);
    for i=xmin:step:xmax
        for j=ymin:step:ymax
            if eq(i,j,x1,y1,x2,y2) <= 10e-2
                ret = [ret ;i j];
                plot(i,j,'.k')
            end
        end
    end
end

%% Resolve Voronoi
function ret = resolveVoronoi(vx,vy,Xs,Xg,Xobs,A,n)
    data=load('data.mat','-mat');

    [vx,vy] = addStartGoal(Xs,Xg,vx,vy,n); % insert start & goal 

     % I build the graph, by means of an adjacency matrix and calculating the minimum spanning tree
    [start,goal,nodes,edge,distance] = buildGraph(vx,vy,Xs,Xg,n); 

%%%%%%%%%%
    subplot(1,4,3), title("Minimo albero ricoprente")
        hold on,grid minor,axis([0 A(1) 0 A(2)])
        plot(vx(1,:),vy(1,:),'ok'),plot(vx(2,:),vy(2,:),'ok')
        
        for i=1:length(edge)
            if edge(i) ~= 0
                plot(vx(:,edge(i)),vy(:,edge(i)),'Color','red')
            end
        end

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
        text(Xs(1)+0.5,Xs(2)+0.5,'Start','FontSize',10,'Color','blue')
        text(Xg(1)+0.5,Xg(2)+0.5,'Goal','FontSize',10,'Color','blue')
    hold off
%%%%%%%%%

    ret = pathOnGraph(start,goal,nodes,edge,distance,vx,vy);

%%%%%%%%
    subplot(1,4,4), title("Cammino minimo da Start a Goal")
        hold on,grid minor,axis([0 A(1) 0 A(2)])
        plot(ret(:,1),ret(:,2),'LineWidth',2)

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
        text(ret(1,1)+0.5,ret(1,2)+0.5,'Start','FontSize',10,'Color','blue')

        plot(Xg(1),Xg(2),'.r','LineWidth',3)
        text(ret(end,1)+0.5,ret(end,2)+0.5,'Goal','FontSize',10,'Color','blue')
    hold off
%%%%%%%%%
end

function [vx,vy] = addStartGoal(Xs,Xg,vx,vy,n)
    % start and goal are linked to the points in the Voronoi's diagram at minimum distance
    smin = Inf;
    gmin = Inf;
    sx = [-1;Xs(1)];
    gx = [Xg(1);-1];
    sy = [-1;Xs(2)];
    gy = [Xg(2);-1];
    for k1=1:size(vx,2)
        for k2=1:size(vx,1)
            distanceS = norm([vx(k2,k1)-Xs(1) ,vy(k2,k1)-Xs(2)],n);
            distanceG = norm([vx(k2,k1)-Xg(1) ,vy(k2,k1)-Xg(2)],n);
            if distanceS < smin
                sx(1,1) = vx(k2,k1);
                sy(1,1) = vy(k2,k1);
                smin = distanceS;
            end
            if distanceG < gmin
                gx(2,1) = vx(k2,k1);
                gy(2,1) = vy(k2,k1);
                gmin = distanceG;
            end
        end
    end
    
    vx = [vx,[sx,gx]];
    vy = [vy,[sy,gy]];
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
    
    % Build main map and map to manage edges
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



function X = dpf(Xs,Xg,Xobs,A) 
    buildGrid(Xg,Xobs,A);
    n = input("     Norma: ");
    if n ~= 1 && n ~= 2
        exception = MException('ThisComponent:notFound','Norm %s not found',n);
        throw(exception);
    end
    X = resolve(Xs,Xg,n);
    figure("Name","Discrete Potential Field")
        plotGrid(X,Xs,Xg)
    hold off
end

%% Build DPF
function buildGrid(Xg,Xobs,A)
    setGrid(zeros(A(1),A(2)));
    xg = Xg(1);
    yg = Xg(2);

    % set dei valori crescenti dal punto di goal
    expand(xg,yg,0);
    maxIt = max(A);
    for i=1:maxIt
        expand(xg+i,yg+i,i);
        expand(xg+i,yg-i,i);
        expand(xg-i,yg+i,i);
        expand(xg-i,yg-i,i);
    end

    % ostacoli
    INFINITY = Inf;

    for i=1:size(Xobs,1)
        xo = Xobs(i,1);
        yo = Xobs(i,2);
        do = ceil(Xobs(i,3)); % distanza intera!!, cosi si ha meno spazio di manovra!
        infect(xo,yo,INFINITY);
        % infetto le celle adiacenti a me 
        for jmp = 1:do-1
            infect(xo-jmp,yo,INFINITY);    
            infect(xo+jmp,yo,INFINITY);  
            infect(xo,yo-jmp,INFINITY);    
            infect(xo,yo+jmp,INFINITY);  
            
            infect(xo+jmp,yo+jmp,INFINITY);
            infect(xo-jmp,yo-jmp,INFINITY);
            infect(xo-jmp,yo+jmp,INFINITY);
            infect(xo+jmp,yo-jmp,INFINITY);
        end
    end
end

function expand(x,y,value)
    mtx = getGrid;
    maxIt = max(size(mtx));
    xo = cell(x);
    yo = cell(y);

    if xo == -1 | yo == -1
        return
    end

    mtx(xo,yo) = value;
    
    for i=1:maxIt % right
        yi = cell(y+i);
        if yi ~= -1
            if mtx(xo,yi) == 0
                mtx(xo,yi) = value + i;
            else 
                break
            end
        else 
            break
        end
    end

    for i=1:maxIt % left
        yi = cell(y-i);
        if yi ~= -1
            if mtx(xo,yi) == 0
                mtx(xo,yi) = value + i;
            else 
                break
            end
        else 
            break
        end
    end

    for i=1:maxIt  % up
        xi = cell(x-i);
        if xi ~= -1
            if mtx(xi,yo) == 0
                mtx(xi,yo) = value + i;
            else 
                break
            end
        else 
            break
        end
    end
    
    for i=1:maxIt % down
        xi = cell(x+i);
        if xi ~= -1
            if mtx(xi,yo) == 0
                mtx(xi,yo) = value + i;
            else 
                break
            end
        else 
            break
        end
    end
    setGrid(mtx)
end

function infect(x,y,INFINITY)
    mtx = getGrid;

    xo = cell(x);
    yo = cell(y);
    xomi = cell(x-1);
    xopi = cell(x+1);
    yomi = cell(y-1);
    yopi = cell(y+1);

    if xo == -1 | yo == -1
        return
    end
   
    mtx(xo,yo) = INFINITY;

    if yomi ~= -1
        mtx(xo,yomi) = INFINITY;
    end

    if yopi ~= -1
       mtx(xo,yopi) = INFINITY;
    end

     if xomi ~= -1   
         mtx(xomi,yo) = INFINITY;
         if yomi ~= -1
            mtx(xomi,yomi) = INFINITY;
         end
         if yopi ~= -1
            mtx(xomi,yopi) = INFINITY;
         end
     end
    
     if xopi ~= -1
         mtx(xopi,yo) = INFINITY;
         if yomi ~= -1
            mtx(xopi,yomi) = INFINITY;
         end
         if yopi ~= -1
            mtx(xopi,yopi) = INFINITY;
         end
     end
     setGrid(mtx)
end

%% Resolve DPF
function X = resolve(Xs,Xg,n)
    mtx = getGrid;

    xg = cell(Xg(1));
    yg = cell(Xg(2));
    
    xcurr = cell(Xs(1));
    ycurr = cell(Xs(2));
    
    numIt = 150;

    X = zeros(numIt,2);
    X(1,:) = [Xs(1),Xs(2)];

    for cont=2:numIt
        if xcurr == xg && ycurr == yg
            break
        end

        xm1 = xcurr - 1;
        xp1 = xcurr + 1;
    
        ym1 = ycurr - 1;
        yp1 = ycurr + 1;
    
        xmin = xcurr;
        ymin = xcurr;
        dmin = norm([xcurr-xg, ycurr-yg],n);
        pmin = mtx(xcurr,ycurr);
    
        % up
        if xm1 <= size(mtx,1) && xm1 > 0
            if  mtx(xm1,ycurr) < Inf && mtx(xm1,ycurr) <= pmin && norm([xm1-xg,ycurr-yg],n) < dmin
                xmin = xm1;
                ymin = ycurr;
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
        
        % down
        if xp1 <= size(mtx,1) && xp1 > 0
            if  mtx(xp1,ycurr) < Inf && mtx(xp1,ycurr) <= pmin && norm([xp1-xg,ycurr-yg],n) < dmin
                xmin = xp1;
                ymin = ycurr; 
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
    
        % left
        if ym1 > 0 && ym1 <= size(mtx,2)
            if mtx(xcurr,ym1) < Inf && mtx(xcurr,ym1) <= pmin && norm([xcurr-xg,ym1-yg],n) < dmin
                xmin = xcurr;
                ymin = ym1;
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
    
        % rigth
        if yp1 > 0 && yp1 <= size(mtx,2)
            if mtx(xcurr,yp1) < Inf && mtx(xcurr,yp1) <= pmin && norm([xcurr-xg,yp1-yg],n) < dmin
                xmin = xcurr;
                ymin = yp1;  
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
    
        % up-left
        if (xm1 <= size(mtx,1) && xm1 > 0) && (ym1 > 0 && ym1 <= size(mtx,2))
            if  mtx(xm1,ym1) < Inf && mtx(xm1,ym1) <= pmin && norm([xm1-xg,ym1-yg],n) < dmin
                xmin = xm1;
                ymin = ym1; 
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
    
        % up - right
        if (xm1 <= size(mtx,1) && xm1 > 0) && (yp1 > 0 && yp1 <= size(mtx,2))
            if  mtx(xm1,yp1) < Inf && mtx(xm1,yp1) <= pmin && norm([xm1-xg,yp1-yg],n) < dmin
                xmin = xm1;
                ymin = yp1;    
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
    
        % down - left
        if (xp1 <= size(mtx,1) && xp1 > 0) && (ym1 > 0 && ym1 <= size(mtx,2))
            if  mtx(xp1,ym1) < Inf && mtx(xp1,ym1) <= pmin && norm([xp1-xg,ym1-yg],n) < dmin
                xmin = xp1;
                ymin = ym1;   
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
    
        % down - right
        if (xp1 <= size(mtx,1) && xp1 > 0) && (yp1 > 0 && yp1 <= size(mtx,2))
            if  mtx(xp1,yp1) < Inf && mtx(xp1,yp1) <= pmin && norm([xp1-xg,yp1-yg],n) < dmin
                xmin = xp1;
                ymin = yp1;
                pmin = mtx(xmin,ymin);
                dim = norm([xmin-xg,ymin-yg]);
            end
        end
    
        xcurr = xmin;
        ycurr = ymin;
    
        % voglio il tracking sul mio sistema di riferimento centrato in (0,0)
        X(cont,:) = [xcurr-1 ycurr-1];
    end
    
    if cont < numIt
        X(cont:end,:) = [];
    end
end

%% Metodi per leggere/modificare la griglia e per plot
function setGrid(mtx)
    global grid 
    grid = mtx;
end

function ret = getGrid
    global grid
    ret = grid;
end

function c = cell(x)
    M = getGrid;
    c = x+1;
    if (c > size(M,1)) | (c > size(M,2)) | (c <= 0)
        c = -1;
    end
end

function plotGrid(ret,Xs,Xg)
    data = load('data.mat','-mat');
    mtx = getGrid;
    N = length(mtx); % room quadrata affinche funzioni tutto dpf
    title('Grid','FontSize',15), hold on
    for i=1:N
        for j=1:N
            if mtx(i,j)<Inf
                if i == Xs(1)+1 && j == Xs(2)+1 % set Xs 
                    rectangle('Position',[i-1 j-1 1 1],'Curvature',[0.1 0.1], ...
                        'LineWidth',1.5,'FaceColor',data.green)
                    text(i-0.6,j-0.5,num2str(mtx(i,j)),'FontSize',15,'color','#000000') ;
                elseif i == Xg(1)+1 && j == Xg(2)+1 % set Xg
                    rectangle('Position',[i-1 j-1 1 1],'Curvature',[0.1 0.1], ...
                        'LineWidth',1.5,'FaceColor',data.red)
                    text(i-0.6,j-0.5,num2str(mtx(i,j)),'FontSize',15,'color','#000000') ;
                    else
                        color = 'white';
                        for k=1:size(ret,1) % per set traiettoria
                            if i == ret(k,1)+1 && j == ret(k,2)+1
                                color = data.yellow;
                                break
                            end
                        end 
                        rectangle('Position',[i-1 j-1 1 1],'Curvature',[0.1 0.1], ...
                            'LineWidth',1.5,'FaceColor',color)
                        text(i-0.6,j-0.5,num2str(mtx(i,j)),'FontSize',15,'color','#000000') ;
                end
            else % per set inf
                rectangle('Position',[i-1 j-1 1 1],'Curvature',[0.1 0.1], ...
                    'LineWidth',1.5,'FaceColor',data.blue)
                text(i-0.65,j-0.5,num2str(mtx(i,j)),'FontSize',15,'color','#FFFFFF') ;
            end
        end
    end
    xlabel('x','FontSize',10), ylabel('y','FontSize',10), axis off
end


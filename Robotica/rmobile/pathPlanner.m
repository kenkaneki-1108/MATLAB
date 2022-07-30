function X = pathPlanner(Xs,Xg,Xobs,A,which)
    switch which
        case 'APF'
            X = apf(Xs,Xg,Xobs,A);
        case 'DPF'
            X = dpf(Xs,Xg,Xobs,A);
        case 'Voronoi'
            X = voronoiDiagram(Xs,Xg,Xobs,A);
        case 'Visibility'
            X = visibilityGraph(Xs,Xg,Xobs,A);
        otherwise
            exception = MException('ThisComponent:notFound','Path Planner %s not found',which);
            throw(exception);
    end
    X = addData(X);
end

function X = addData(X)
    lambda = 0.25;
    while size(X,1) < 4
        Xnew = X(1,:) + lambda.*(X(2,:)-X(1,:)); 
        lambda = lambda + 0.15;
        X=[X(1,:); Xnew; X(2:end,:)];
    end
end


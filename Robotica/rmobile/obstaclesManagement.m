function ret = obstaclesManagement(robot,goal,obs)
    Xs = [robot(1) robot(2) robot(3)]; % start
    Xg = [goal(1) goal(2) goal(3)]; % goal

    dimRobot = robot(4);

    Xobs = zeros(size(obs,1),3); % obstacles
    for i=1:size(obs,1)
        Xobs(i,:) = [obs(i,1) obs(i,2) obs(i,3)+dimRobot]; % xo,yo,do
    end

    ret = [Xs; Xg; Xobs];
end


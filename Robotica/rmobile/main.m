clear; clc; close all;

robot = [15 2 180 1];
goal = [2 12 180]; 

%% ENVIRONMENT
A = [20 20];
obs = [ 12 6 2;
        4 8 1;
        8 14 1 ]; 

fprintf('#Attenzione: Input di tipo stringa tra apici singoli. \n')

%% OBSTACLES MANAGEMENT
abs = obstaclesManagement(robot,goal,obs);

Xs = abs(1,:);
Xg = abs(2,:); 
Xobs(:,:) = abs(3:end,:);

figure("Name","Environment") 
    plotEnvironment(robot,obs,Xs,Xg,Xobs,A)
hold off

fprintf('\n- Plot environment \n')

pause

%% PATH PLANNING
which = input("\n1. Quale path planning? ");
X = pathPlanner(Xs,Xg,Xobs,A,which);

x = mySpline(X(:,1));
y = mySpline(X(:,2));

figure("Name","Path Planning")
    plotPath(Xs,Xg,Xobs,x,y,X,A)
hold off

fprintf('\n- Plot path planning \n')

pause

%% CONTROL
whichT = input("\n2. Quale trajectory control? ");
paramT = {};
switch whichT
    case 'Linear'
        a = input("     a>0 :");
        delta = input("     delta compreso tra (0,1) :");
        paramT{1} = a; paramT{2} = delta;
    case 'NotLinear'
        K1 = input("    K1(v,w)>0 bounded :");
        K2 = input("    K2>0 :");
        K3 = input("    K3(v,w)>0 bounded :");
        paramT{1} = K1; paramT{2} = K2; paramT{3} = K3;
    case 'IOLinear'
        b = input("    b~=0 :");
        Kx = input("    Kx>0 :");
        Ky = input("    Ky>0 :");
        paramT{1} = b; paramT{2} = Kx; paramT{3} = Ky;
end

whichP = input("\n3. Quale posture regulation? ");
paramP = {};
switch whichP
    case 'Complete'
        K1 = input("    K1>0 :");
        K2 = input("    K2>0 :");
        K3 = input("    K3 :");
        paramP{1} = K1; paramP{2} = K2; paramP{3} = K3;
    case 'Cartesian'
        K1 = input("    K1>0 :");
        K2 = input("    K2>0 :");
        paramP{1} = K1; paramP{2} = K2;    
end

flag = input("\n >> Raggio dell'intorno centrato in Xg: ");
RHO = @(X,Xc,d) (X(1)-Xc(1))^2 + (X(2)-Xc(2))^2 > d^2;

%% SIMULATION
ROBOT = @(t,X) ( trajectoryControl(X,piece(t,x,y),whichT,paramT).*RHO(X,Xg,flag)+ ...
                    postureRegulation(X,Xg,whichP,paramP).*(~RHO(X,Xg,flag)) ); 

tsim = 0:size(X,1);
[t,sol] = ode45(ROBOT,[tsim(1)+0.0001 tsim(end)-0.001],[Xs(1);Xs(2);Xs(3)]);

figure("Name","Control")
    plotControl(Xs,Xg,flag,Xobs,x,y,sol,A)
fprintf('\n- Plot control \n')

pause

fprintf('\n- Plot simulation \n')
figure("Name","Simulation")
    plotSimulation(robot,Xg,obs,sol,A)
hold off

























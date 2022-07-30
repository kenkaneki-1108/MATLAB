clear, clc, close all

syms ("theta",[1,3])
a = [0; 0.9; 0.9];
alpha = [pi/2; 0; 0];
d = [0; 0; 0]; 
THETA = [theta1; theta2; theta3];

DH = [a,alpha,d,THETA]

Rb0 = [ 1 0 0 0.5;
        0 1 0 0.5;
        0 0 1 1;
        0 0 0 1 ];

P1 = [0.8; 0.8; 0.5];
P2 = [1.2; 0.8; 0.5];
P3 = [1.0; 1.2; 0.5];

P = [P1,P2,P3,P1];

Te = 40;
numRoute = 3;

typePath = 'Triangolo';

fprintf('#Attenzione: Input di tipo stringa tra apici singoli. \n')

%% 1 Definizione del tempo
numRange = numRoute+1;
Trange = linspace(0,Te,numRange);

numStep = input("\n1. numStep per discretizzare l'intervallo di tempo: ");
trange = zeros(numRoute,numStep);
for i=1:numRange-1
    trange(i,:) = linspace(Trange(i),Trange(i+1),numStep);
end

%% 2 Definizione della traiettoria
degree = input("2. ordine del polinomio lambda: ");
lambdaFun = lambdaFunction(degree);

position = zeros(3,numRoute*numStep); % pos = [ [x;y;z], ... ]
velocity = zeros(3,numRoute*numStep); % vel = [ [vx;vy;vz], ... ]

syms s;
k=0;
for i=1:numRoute
    for j=1:numStep
        t = trange(i,j);
        T2 = Trange(i+1);
        T1 = Trange(i);

        P1 = P(:,i);
        P2 = P(:,i+1);

        sigma = (t-T1)/(T2-T1);
        lambda = subs(lambdaFun,s,sigma);

        lambdaDot = subs(lambdaFun,s,sigma);

        k=k+1;
        position(:,k) = P1+lambda*(P2-P1);
        velocity (:,k) = ((P2-P1)/(T2-T1))*lambdaDot;
    end
end

%% Ricavo matrice di rototralazione dalla tabella DH
[Rb3,q] = matrixRT(DH,Rb0);

which = input("3. Quale Jacobiano? ");
switch which
    case 'Geometrico'
        J = jacobianGeometric(DH,q); 
    case 'Analitico'
        J = jacobianAnalytic(q,Rb3);
    otherwise
        exception = MException('ThisComponent:notFound','Jacobian %s not found',which);
        throw(exception);
end

%% Calcolo delle variabili di giunto
Q = zeros(length(q),numRoute*numStep);
QDot = zeros(length(q),numRoute*numStep);

config = input("4. Gomito Alto o Basso? ");
switch config
    case 'Alto'
        cnfg = 2;
    case 'Basso'
        cnfg = 1;
    otherwise
        exception = MException('ThisComponent:notFound','Config %s not found',config);
        throw(exception);
end

Qstar = [0;0;pi/2];

for i=1:length(position)
    Qstar = cinematicaInversa(position(:,i),DH,Qstar);
    Qstar = double(Qstar(:,cnfg));
    
    Jq = subs(J,[q(1) q(2) q(3)],Qstar');
    Jq = double(Jq);

    Qdot = pinv(Jq)*velocity(:,i);
    
    Q(:,i) = Qstar;
    QDot(:,i) = Qdot;
end

%% Plot 
fprintf('\n- Plot della traiettoria \n')
plotPosition(numRoute*numStep,P,position)

pause

fprintf('- Plot con Robotics Toolbox \n')
plotAntropomorfo(P,Q,d,a,alpha,position)

pause

fprintf('- Plot andamento delle variabili di giunto \n')
plotQ(Q,QDot,trange,typePath)

pause

fprintf('- Cinematica diretta \n')
plotMyAntropomorfo(Rb0,Rb3,DH,q,Q)







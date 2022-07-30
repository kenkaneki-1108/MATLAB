function ret = lambdaFunction(degree)
%% Costruzione polinomio
    switch degree 
        case 3
            syms s a0 a1 a2 a3; % poly 4-order

            lambda = a0*s^3 + a1*s^2 + a2*s + a3;
            lambdaDot = 3*a0*s^2 + 2*a1*s + a2;
        case 5
            syms s a0 a1 a2 a3 a4 a5; % poly 6-order

            lambda = a0*s^5 + a1*s^4 + a2*s^3 + a3*s^2 + a4*s + a5;
            lambdaDot = 5*a0*s^4 + 4*a1*s^3 + 3*a2*s^2 + 2*a3*s + a4;
            lambdaDDot = 20*a0*s^3 + 12*a1*s^2 + 6*a2*s + 2*a3;
        case 7
            syms s a0 a1 a2 a3 a4 a5 a6 a7; % poly 8-order

            lambda = a0*s^7 + a1*s^6 + a2*s^5 + a3*s^4 + a4*s^3 + a5*s^2 + a6*s + a7;
            lambdaDot = 7*a0*s^6 + 6*a1*s^5 + 5*a2*s^4 + 4*a3*s^3 + 3*a4*s^2 + 2*a5*s + a6;
            lambdaDDot = 42*a0*s^5 + 30*a1*s^4 + 20*a2*s^3 + 12*a3*s^2 + 6*a4*s + 2*a5;
            lambdaDDDot = 210*a0*s^4 + 120*a1*s^3 + 60*a2*s^2 + 24*a3*s + 6*a4;
        otherwise
            exception = MException('ThisComponent:notFound','Degree %s not found',degree);
            throw(exception);
    end

%% Vincoli di continuità
    eq1 = subs(lambda,s,0) == 0;
    eq2 = subs(lambda,s,1) == 1;

    % dot 
    eq3 = subs(lambdaDot,s,0) == 0;
    eq4 = subs(lambdaDot,s,1) == 0;

    if degree > 3  % dot dot
        eq5 = subs(lambdaDDot,s,0) == 0;
        eq6 = subs(lambdaDDot,s,1) == 0;
    end
    
    if degree > 5 % dot dot dot
        eq7 = subs(lambdaDDDot,s,0) == 0;
        eq8 = subs(lambdaDDDot,s,1) == 0;      
    end

%% Risoluzione del sistema
    if degree == 3
        [a0, a1, a2, a3] = vpasolve([eq1, eq2, eq3, eq4]);
    end

    if degree == 5
        [a0, a1, a2, a3, a4, a5] = vpasolve([eq1, eq2, eq3, eq4, eq5, eq6]);
    end

    if degree == 7
        [a0, a1, a2, a3, a4, a5, a6, a7] = vpasolve([eq1, eq2, eq3, eq4, eq5, eq6, eq7, eq8]);
    end
    
    ret = subs(lambda);
end





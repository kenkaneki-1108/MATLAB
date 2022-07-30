function [Ja,sing] = jacobianAnalytic(q,Rb3)
    numQ = length(q);
    Pos = Rb3(1:numQ,4); 
    
    Ja = sym([]); 
    for i = 1:numQ
        for j = 1:numQ
            Ja(i,j) = diff(Pos(i),q(j));
        end
    end
    
    eq = simplify(det(Ja)) == 0;
    sing = solve(eq,q);
end


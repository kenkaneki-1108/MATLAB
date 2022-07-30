function [Jg,sing] = jacobianGeometric(DH,q)
    a = double(DH(:,1));
    alpha = DH(:,2);
    d = DH(:,3);
    theta = DH(:,4);

    a2c1c2 = a(2)*cos(q(1))*cos(q(2));
    a2s1c2 = a(2)*sin(q(1))*cos(q(2));
    a2s2 = a(2)*cos(q(2));
    c1 = cos(q(1));
    s1 = sin(q(1));
    a2c2 = a(2)*cos(q(2));
    a3c23 = a(3)*cos(q(2)+q(3));
    a3s23 = a(3)*sin(q(2)+q(3));
    
    % pi-1 con i=1,2,3
    p0 = [ 0;0;0 ];
    p1 = [ 0;0;0 ];
    p2 = [ a2c1c2;
           a2s1c2;
           a2s2 ];
    % p
    p =[ c1*(a2c2+a3c23);
         s1*(a2c2+a3c23);
         a2s2 + a3s23 ];
    
    % Asse di rotazione dei giunti
    z0 = [ 0;0;1 ];
    z1 = [ s1;-c1;0 ];
    z2 = z1;

    % Giunti rotoidali
    if symType(theta(1)) == "variable" 
        Z0 = Z(z0);
        Z1 = Z(z1);
        Z2 = Z(z2);
        
        J = [ Z0*(p-p0) Z1*(p-p1) Z2*(p-p2);
              z0 z1 z2 ];
    % Giunti prismatici    
    elseif symType(d(1)) == "variable" 
        O = [0;0;0];

        J = [ z0 z1 z2; 
              O O O ];
    end    
    Jg = J(1:3,:);

    % eq = simplify(det(Jg)) == 0;
    % sing = solve(eq,q);
end

function Zim1 = Z(zim1) % z di i meno 1
    Zim1 = [ 0 -zim1(3) zim1(2);
             zim1(3) 0 -zim1(1);
             -zim1(2) zim1(1) 0 ];
end

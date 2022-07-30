function [T,q] = matrixRT(DH,Rb0)
    nLink = size(DH,1);
    syms ("q",[1,nLink]);
    T=Rb0;
    for i=1:nLink
        ai = DH(i,1);
        alphai = DH(i,2);
        di = DH(i,3);
        thetai = DH(i,4);

        % Giunti rotoidali
        if symType(thetai) == "variable"
            % SRi -> SRi'
            Rip = [ [rotZ(q(i)), traslZ(di)];
                    0 0 0 1 ];
            % SRi' -> SRi+1
            Ri = [ [rotX(alphai), traslX(ai)];
                   0 0 0 1 ];

        % Giunti prismatici
        elseif symType(di) == "variable" 
            % SRi -> SRi'
            Rip = [ [rotZ(thetai), traslZ(q(i))];
                    0 0 0 1 ];
            % SRi' -> SRi+1
            Ri = [ [rotX(alphai), traslX(ai)];
                   0 0 0 1 ];
        end      
        R = Rip*Ri;
        T = T*R;
    end
    T = simplify(T);
end

% rotazione attorno z
function Rz = rotZ(angle)
    Rz = [ cos(angle) -sin(angle) 0;
           sin(angle) cos(angle) 0;
           0 0 1 ];
end

% rotazione attorno x
function Rx = rotX(angle)
    Rx = [ 1 0 0;
           0 cos(angle) -sin(angle);
           0 sin(angle) cos(angle) ];
end

% traslazione lungo z
function tz = traslZ(d)
    tz = [ 0;
           0;
           d ];
end

% traslazione lungo x
function tx = traslX(a)
    tx = [ a;
           0;
           0 ];
end
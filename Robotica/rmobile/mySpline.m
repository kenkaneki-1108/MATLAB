function p = mySpline(y)
    xx = 0:length(y)-1;
    pp = spline(xx,y(:));
    p = {};
    for k = 1:pp.pieces
        xk = pp.breaks(k);
        ak = pp.coefs(k,1);
        bk = pp.coefs(k,2);
        if pp.order < 3
            ck = 0;
        else
            ck = pp.coefs(k,3);
        end
        if pp.order < 4
            dk = 0;
        else
            dk = pp.coefs(k,4);
        end
        if k == 1
            p{k,1} = @(x) ((dk + ck*(x-xk) + bk*(x-xk).^2 + ak*(x-xk).^3) .* (x~=xk)) + (y(1) * (x==xk));  % p 
            p{k,2} = @(x) (ck + 2*bk*(x-xk) + 3*ak*(x-xk).^2); % pdot
            p{k,3} = @(x) (2*bk + 6*ak*(x-xk)); % pdotdot
        else 
            p{k,1} = @(x) ((dk + ck*(x-xk) + bk*(x-xk).^2 + ak*(x-xk).^3) .* (x~=xk)) + (y(k) .* (x==xk));  % p 
            p{k,2} = @(x) ((ck + 2*bk*(x-xk) + 3*ak*(x-xk).^2) .* (x~=xk)) + (p{k-1,2}(xk) .* (x==xk)); % pdot
            p{k,3} = @(x) ((2*bk + 6*ak*(x-xk)) .* (x~=xk)) + (p{k-1,3}(xk) .* (x==xk)); % pdotdot
        end
    end    
    % p{1,1} polinomio, p{1,2} pdot, p{1,3} pdotdot
    % p{1,1}(t) to call
end



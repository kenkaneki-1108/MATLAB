function xy = piece(t,x,y)
    k = size(x,1);
    if t == 0
        k = 1;
    elseif ceil(t) < k
        k = ceil(t);
    end
    xy = [  x{k,1}(t); y{k,1}(t);
                x{k,2}(t); y{k,2}(t); 
                x{k,3}(t); y{k,3}(t) ];
end  



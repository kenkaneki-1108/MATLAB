function C=regolatore(Kp,Ti,Td,N);
s=zpk('s');
if N~=0
    if Ti~=0 | Td~=0
        C=Kp + (Kp)/(Ti*s) + (Kp*Td*s)/(1+(Td*s)/N); % derivatore realizzabile
        return
    end
    
    if Ti~=0 & Td==0
         C=Kp + (Kp)/(Ti*s)
        return
    end
    
    if Ti==0 & Td~=0
         C=Kp + (Kp*Td*s)/(1+(Td*s)/N);
        return
    end

    if Ti==0 & Td==0
         C=Kp;
        return
    end
end
throw('Exception for filter coefficient')



function Q = cinematicaInversa(p,DH,q)
    a = double(DH(:,1));
    
    px = p(1);
    py = p(2);
    pz = p(3);
    
    Q1 = [atan2(py,px) atan2(py,px)+pi];

    c3 = (px^2 + py^2 + pz^2 - a(2)^2 - a(3)^2)/(2*a(2)*a(3));
    s3 = sqrt( 1-cos(q(3))^2 ) ;
    
    Q3 = [atan2(s3,c3) atan2(-s3,c3)];
    
    s2 = ( ( a(2)+a(3)*cos(q(3)) )*pz - a(3)*sin(q(3))*sqrt(px^2+py^2) )/( px^2 + py^2 + pz^2 );
    c2 = ( ( a(2)+a(3)*cos(q(3)) )*sqrt(px^2+py^2) + a(3)*sin(q(3))*pz )/( px^2 + py^2 + pz^2 );
    
    Q2 = atan2(s2,c2);
    
    Q = [ [Q1(1); Q2; Q3(1)],...
          [Q1(1); Q2; Q3(2)],...
          [Q1(2); Q2; Q3(1)],...
          [Q1(2); Q2; Q3(2)] ];        
end



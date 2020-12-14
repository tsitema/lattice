
function err=egs(a,b,pa,pc,lambda,phi,k,g)
    %alpha=2*(1+cos(phi-k));
    %beta=2*(1+cos(phi+k));
    b=exp(1i).*b;
    M=[g.*abs(a).^2,  -exp(-1i.*phi)-exp(-1i.*phi.*k),                      0;
      -exp(1i.*phi)-exp(1i.*phi.*k),        g.*abs(b).^2,   -exp(-1i.*phi)-exp(1i.*phi.*k);
        0,     -exp(1i.*phi)-exp(-1i.*phi.*k),      g.*abs(1-abs(a).^2-abs(b).^2);];
    c=exp(1i*pc).*sqrt(abs(1-abs(a).^2-abs(b).^2));   
    
    a=a.*exp(1i.*pa);
    %eigenvalue equation here
    eqn=M*[a;b;c]-lambda.*[a;b;c];
    err=norm(eqn);     
%    limit normalization
    nrm=sqrt(abs(a).^2+abs(b).^2+abs(c).^2);
    if nrm>1.001||nrm<0.999
        err=10000;
    end
end
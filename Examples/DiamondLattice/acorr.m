function cr=acorr(M)
cr=zeros(size(M));
    for ii =1:size(M,1)
        for jj=1:size(M,2)
        cr(ii,jj)=sum(M(ii,:).*conj(circshift(M(ii,:),jj)));
        end
    end
end
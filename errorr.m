function err = errorr(x1,x2)
L1=length(x1);
E=x1-x2;
err=sqrt(sum(E.^2,"omitnan"))/L1;
end


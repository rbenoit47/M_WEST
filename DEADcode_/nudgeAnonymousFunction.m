% d1=lambda*delta/nu;
% %nudge d1 to d such that alpha*delta becomes (integer)*d
% n=floor(alpha*delta/d1);
% d=alpha*delta/n;

 nudge=@(d1,alpha,delta,nu,sigma) alpha*delta/floor(alpha/((2*alpha/(1-sigma))/nu))

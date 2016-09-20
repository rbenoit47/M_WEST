function [ d,sigmaout ] = solve_microdx( alpha,delta,nu,sigma,varargin )
%SOLVE_MICRODX Summary of this function goes here
%   Detailed explanation goes here
d=[];sigmaout=[];
if ~(alpha-floor(alpha)==0 );disp('alpha is not integer');return;end
if ~isempty(sigma)
	d=f(alpha,sigma,delta,nu);
	lambda=nu*d/delta;
	sigmaout=1-2*alpha/lambda;
else
	dTarget=varargin{1};
	disp(['sigma is empty. solve for it with target d=',num2str(dTarget)])
	%
	REF=[alpha,delta,nu,dTarget];
	h = @(y) g(y,REF);
	sigma0=0.;
	%
	options = optimset('Display','off');
	[sigmaSol,fval]=fsolve(h,sigma0,options);
	if numel(sigmaSol) > 1;disp('solution multiple pour sigma. Inacceptable');disp(sigmaSol);return;end
	% check validite de solution sigma doit etre dans [0,1]
	if sigmaSol < 0 || sigmaSol > 1
		disp(['sigma (',num2str(sigmaSol),')']);
		disp('changer les valeurs de alpha, nu ou d')
		return
	else
		sigmaout=sigmaSol;
	end
	d=f(alpha,sigmaout,delta,nu);
end
[d,sigmaout]=shake_d(alpha,sigmaout,nu,delta);
d=single(d);sigmaout=single(sigmaout);
end
function d=f(alpha,sigma,delta,nu)
lambda=2*alpha/(1-sigma);
d1=lambda*delta/nu;
%nudge d1 to d such that alpha*delta becomes (integer)*d
n=floor(alpha*delta/d1);
%d=alpha*delta/n;
d=d1;  % no nudging
end
function G=g(sigma,REF)
alpha=REF(1);delta=REF(2);nu=REF(3);dTarget=REF(4);
G=f(alpha,sigma,delta,nu)-dTarget;
end
function [ d,sigmaout ] = shake_d( alpha,sigma,nu,delta )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
      lambda=2*alpha/(1-sigma);
      d1=lambda*delta/(nu);
      d=alpha*delta/round(alpha*delta/d1);
      lambda=(nu)*d/delta;
      sigmaout=1.0-2.0*alpha/lambda;
end


function [yes ] = yes_answer( rep )
%YES_ANSWER Summary of this function goes here
%   Detailed explanation goes here
yes=false;
hit=[];
hit=regexp(rep,'[YyOo]');
yes=~isempty(hit);
end


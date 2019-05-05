% Copyright 2019, Viktor Leek
%
% This file is part of Yop.
%
% Yop is free software: you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any
% later version.
% Yop is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Yop.  If not, see <https://www.gnu.org/licenses/>.
% -------------------------------------------------------------------------
classdef YopBoundaryInitialConstraint < YopNonlinearConstraint

    methods
        function obj = YopBoundaryInitialConstraint(constraint, input, descaling)            
            [isMember, memberNumber] = YopBoundaryInitialConstraint.isMember(constraint);
            assert(isMember);
            
            pattern = YopBoundaryInitialConstraint.getMemberPattern(memberNumber);
            
            [expression, upper, lower] = pattern.parse(constraint);
            
            obj@YopNonlinearConstraint(constraint, expression, upper, lower, input, descaling);
            
        end
    end
    
    methods (Static)        
        
        function patterns = memberPatterns()
            
            p1 = YopConstraintPattern({'numeric' '<=' 'InitialBoundary' '<=' 'numeric'}, ...
                @(c) c{3}.Expression, @(c) c{5}, @(c) c{1});
            
            p2 = YopConstraintPattern({'numeric' '==' 'InitialBoundary'}, ...
                @(c) c{3}.Expression, @(c) c{1}, @(c) c{1});
            
            p3 = YopConstraintPattern({'numeric' '<=' 'InitialBoundary'}, ...
                @(c) c{3}.Expression, @(c) inf(size(c{3}.Expression)), @(c) c{1});
            
            p4 = YopConstraintPattern({'numeric' '>=' 'InitialBoundary'}, ...
                @(c) c{3}.Expression, @(c) c{1}, @(c) -inf(size(c{3}.Expression)));
            
            patterns = [p1, p2, p3, p4];
            
        end
        
        function pattern = getMemberPattern(patternNumber)
            patterns = YopBoundaryInitialConstraint.memberPatterns;
            pattern = patterns(patternNumber);
        end
        
        function [value, memberNumber] = isMember(constraint)
            patterns = YopBoundaryInitialConstraint.memberPatterns();
            patternMatch = zeros(size(patterns));
            memberNumber = [];
            for k=1:length(patterns)
                if patterns(k).match(constraint)
                    memberNumber = k;
                    patternMatch(k) = 1;
                end
            end
            
            assert(sum(patternMatch)<=1);
            value = ~isempty(memberNumber);            
        end               
    end
end
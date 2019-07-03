classdef YopRelation < handle
    
    properties
        Lhs
        Rhs
        Relation
    end
    
    methods
        
        function obj = YopRelation(lhs, rhs, relation)
            obj.Relation = relation;
            obj.Lhs = lhs;
            obj.Rhs = rhs;
        end
        
        function relation = le(x, y)
            relation = YopRelation(x, y, @le);
        end
        
        function l = lhs(obj)
            l = obj.Lhs;
        end
        
        function r = rhs(obj)
            r = obj.Rhs;
        end
                
        function v = value(obj)
            % Rekursivt gå igenom trädet :)
        end
        
    end
end
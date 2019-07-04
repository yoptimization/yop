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
            x = YopExpression.convert(x);
            y = YopExpression.convert(y);
            relation = YopRelation(x, y, @le);
        end
        
        function l = lhs(obj)
            l = obj.Lhs;
        end
        
        function r = rhs(obj)
            r = obj.Rhs;
        end
                
        function v = value(obj)
            v = obj.Relation(obj.Lhs.value, obj.Rhs.value); % Recursion               
        end
        
        function rels = relations(obj)
            if isa(obj.Lhs, 'YopRelation') && YopRelation.leafp(obj.Rhs)                
                rels = 1 + relations(obj.Lhs);                
                               
            elseif YopRelation.leafp(obj.Lhs) && isa(obj.Rhs, 'YopRelation') 
                rels = 1 + relations(obj.Rhs);
                
            elseif isa(obj.Lhs, 'YopRelation') && isa(obj.Rhs, 'YopRelation')
                rels = 1 + relations(obj.Lhs) + relations(obj.Rhs);
                
            else
                rels = 1;
                
            end
        end
        
        function lm = leftmost(obj)
            if YopRelation.leafp(obj.Lhs)
                lm = obj.Lhs;
            else
                lm = leftmost(obj.Lhs);
            end
        end
        
        function lm = rightmost(obj)
            if YopRelation.leafp(obj.Rhs)
                lm = obj.Rhs;
            else
                lm = rightmost(obj.Rhs);
            end
        end
        
    end
    
    methods (Static)
        
        function bool = leafp(node)
            bool = ~isa(node, 'YopRelation');
        end

    end
end
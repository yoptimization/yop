classdef YopRelation < handle
    
    properties
        Lhs
        Rhs
        Relation
    end
    
    methods % (Relation)
        
        function obj = YopRelation(lhs, rhs, relation)
            obj.Relation = relation;
            obj.Lhs = lhs;
            obj.Rhs = rhs;
        end
        
        function relation = lt(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @lt);
        end
        
        function relation = le(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @le);
        end
        
        function relation = gt(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @gt);
        end
        
        function relation = ge(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @ge);
        end
        
        function relation = ne(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @ne);
        end
        
        function relation = eq(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @eq);
        end
        
        function relation = and(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @and);
        end
        
        function relation = or(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @or);
        end
        
        function relation = not(lhs, rhs)
            lhs = YopExpression.convert(lhs);
            rhs = YopExpression.convert(rhs);
            relation = YopRelation(lhs, rhs, @not);
        end
        
        function expression = value(obj)
            expression = obj.Relation(value(obj.Lhs), value(obj.Rhs));
        end
        
        function expressions = values(obj)
            expressions = [];
            for k=1:length(obj)
                expressions = [expressions; obj(k).value];
            end
        end
        
        function lhs = leftmost(obj)
            if obj.lhsIsYopExpression
                lhs = obj.Lhs;
            else
                lhs = leftmost(obj.Lhs);
            end
        end
        
        function lhs = rightmost(obj)
            if obj.rhsIsYopExpression
                lhs = obj.Rhs;
            else
                lhs = rightmost(obj.Rhs);
            end
        end
        
        function bool = lhsIsYopExpression(obj)
            bool = isa(obj.Lhs, 'YopExpression');
        end
        
        function bool = rhsIsYopExpression(obj)
            bool = isa(obj.Rhs, 'YopExpression');
        end
        
        function bool = lhsIsYopRelation(obj)
            bool = isa(obj.Lhs, class(obj));
        end
        
        function bool = rhsIsYopRelation(obj)
            bool = isa(obj.Rhs, class(obj));
        end
        
        function bool = isaSimpleRelation(obj)
            bool = obj.lhsIsYopExpression && obj.rhsIsYopExpression;
        end
        
        function relations = unnest(obj)
            % Unnest from left to right independent of parenteses
            if obj.isaSimpleRelation
                relations = obj;
                
            elseif obj.lhsIsYopExpression && obj.rhsIsYopRelation
                relations = [ ...
                    YopRelation(obj.Lhs, leftmost(obj.Rhs), obj.Relation); ...
                    unnest(obj.Rhs) ...
                    ];
                
            elseif obj.lhsIsYopRelation && obj.rhsIsYopExpression
                relations = [ ...
                    unnest(obj.Lhs); ...
                    YopRelation(rightmost(obj.Lhs), obj.Rhs, obj.Relation) ...
                    ];
                
            elseif obj.lhsIsYopRelation && obj.rhsIsYopRelation
                relations = [ ...
                    unnest(obj.Lhs); ...
                    YopRelations(rightmost(obj.Lhs), leftmost(obj.Rhs), obj.Relation); ...
                    unnest(obj.Rhs) ...
                    ];
                
            else
                assert(false);
                
            end
            
        end
        
        function bool = isaDoubleInequality(obj)
            relations = obj.unnest;
            if length(relations) == 2
                bool = isequal(relations(1).Relation, relations(2).Relation);
            else
                bool = false;
            end
        end
        
        function text = toText(obj)
            text = replace(evalc('disp(obj.value)'), {newline, ' '}, '');
        end
        
        function value = getLowerValue(obj)
            if isequal(obj.Relation, @lt) || isequal(obj.Relation, @le)
                value = obj.Lhs;
                
            elseif isequal(obj.Relation, @gt) || isequal(obj.Relation, @ge)
                value = obj.Rhs;
                
            end
        end
        
    end
    
    methods % (Constraint)
        
        function bool = isaBoxConstraint(obj)
            if obj.isaSimpleRelation
                bool = xor( ...
                    yopIsValidInput(obj.Lhs.Expression), ...
                    yopIsValidInput(obj.Rhs.Expression) ...
                    ) ...
                    && ...
                    xor( ...
                    isnumeric(obj.Lhs.Expression), ...
                    isnumeric(obj.Rhs.Expression) ...
                    );
            else
                bool = false;
            end
        end
        
        function text = textform(obj)
            relations = obj.unnest;
            for k=1:length(relations)
                rk = relations(k);
                lhs = replace(evalc('disp(rk.Lhs.Expression)'), {newline, ' '}, '');
                rhs = replace(evalc('disp(rk.Rhs.Expression)'), {newline, ' '}, '');
                if isequal(rk.Relation, @lt)
                    op = '<';
                elseif isequal(rk.Relation, @gt)
                    op = '>';
                elseif isequal(rk.Relation, @le)
                    op = '<=';
                elseif isequal(rk.Relation, @ge)
                    op = '>=';
                elseif isequal(rk.Relation, @ne)
                    op = '~=';
                elseif isequal(rk.Relation, @eq)
                    op = '==';
                else
                    op = '[OP]';
                end
                text{k} = [lhs ' ' op ' ' rhs];
            end
        end
        
    end
end
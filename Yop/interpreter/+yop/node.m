classdef node < handle
    
    properties
        name % Name of the node.
    end
    
    properties (SetObservable, AbortSet)
        value % Value associated with node.
    end
    
    properties (SetAccess=protected)
        rows    % Number of rows.
        columns % Number of columns.
        parent  % Parent nodes. Is proteced beacuse it needs a listener.
        child   % Child nodes.
    end
    
    properties (SetAccess=private, GetAccess=private)
        eval_order
    end
    
    methods
        
        function obj = node(name, rows, columns)
            if nargin == 1
                rows = 1;
                columns = 1;
            elseif nargin == 2
                columns = 1;
            end
            obj.name = name;
            obj.rows = rows;
            obj.columns = columns;
            obj.parent = yop.node_listener_list();
            obj.child = yop.list();
        end
        
        function obj = set_parent(obj, parent)
            listener = addlistener(obj, 'value', 'PostSet', @parent.clear);
            add(obj.parent, parent, listener);
        end
        
        function obj = remove_parent(obj, parent)
            remove(obj.parent, parent);
        end
        
        function obj = set_child(obj, child)
            % Lyssnare?
            add(obj.child, child);
        end
        
        function obj = remove_child(obj, child)
            % Ta bort lyssnare.
            remove(obj.child, child);
        end
        
        function clear(obj, ~, ~)
            if isvalid(obj)
                obj.value = [];
            end
        end
        
        function obj = set_value(obj, value)
            obj.value = value;
        end
        
        function obj = forward(obj)
        end
        
        function bool = isa_valid_relation(obj)
            % tests for the following structure where r is a relation and e
            % is an expression, e.g. e1 <= e2 <= ... <= eN
            %         r
            %        / \
            %       r   e
            %      / \
            %     r   e
            %    /\
            %   e  e
            if isa(obj, 'yop.relation') && ~isa(obj.left, 'yop.relation') && ~isa(obj.right, 'yop.relation')
                % This is the end node.
                bool = true;
                
            elseif isa(obj, 'yop.relation') && isa(obj.left, 'yop.relation') && ~isa(obj.right,'yop.relation')
                bool = obj.left.isa_valid_relation();
                
            else
                bool = false;
                
            end
            
        end
        
        function bool = isa_variable(obj)            
            if isa(obj, 'yop.variable')
                bool = true;
                
            elseif ~isa(obj, 'yop.subs_operation')
                bool = false;
                
            else % has to be a subs_operation and therefore it's
                 % sufficient to look at the first argument and see if that
                 % tree only containts variables or subs_operations
                bool = obj.child.elem(1).object.isa_variable();
                
            end            
        end
        
        function l = left(obj)
            l = obj.child.elem(1).object;
        end
        
        function l = right(obj)
            l = obj.child.elem(2).object;
        end
        
        function r = leftmost(obj)
            if isa_variable(obj)
                r = obj;
            else
                r = obj.left.leftmost();
            end
        end
        
        function r = rightmost(obj)
            if isa_variable(obj)
                r = obj;
            else
                r = obj.right.rightmost();
            end
        end
        
    end
    
    methods % Default changing behavior
        
        function y = subsref(x, s)
            if s(1).type == "()" && isnumeric(s(1).subs{1})
                tmp = ones(size(x));
                tmp = tmp((s(1).subs{1}));
                
                txt = [x.name '(' num2str(s(1).subs{1}) ')'];
                y = yop.subs_operation(txt, size(tmp,1), size(tmp,2), @subsref);
                
                s_yop = yop.constant('s', 1, 1);
                s_yop.value = s(1);
                
                y.set_child(x);
                y.set_child(s_yop);
                x.set_parent(y);
                s_yop.set_parent(y);                
                
                if length(s) > 1
                    y = subsref(y, s(2:end));
                end
            else
                y = builtin('subsref', x, s);
            end
        end
        
        function z = subsasgn(x, s, y)
            if s(1).type == "()" && isnumeric(s(1).subs{1})
                y = yop.node.typecast(y);
                
                z = yop.subs_operation(x.name, x.rows, x.columns, @subsasgn);
                
                s_yop = yop.constant('s', 1, 1);
                s_yop.value = s(1);
                
                z.set_child(x);
                z.set_child(s_yop);
                z.set_child(y);
                x.set_parent(z);
                s_yop.set_parent(z);
                y.set_parent(z);                
            else
                z = builtin('subsasgn',x, s, y);
            end
        end
        
        function s = size(obj, dim)
            if nargin == 2
                if dim == 1
                    s = obj.rows;
                elseif dim == 2
                    s = obj.columns;
                else
                    yop.assert(false, yop.messages.error_size(dim))
                end
            else
                s = [obj.rows, obj.columns];
            end
        end
        
        function l = length(obj)
            l = max(size(obj));
        end
        
        function y = horzcat(varargin)
            cols = 0;
            cond = true;
            for k = 1:length(varargin)
                cond = cond && size(varargin{k},1)==size(varargin{1},1);
                if cond
                    varargin{k} = yop.node.typecast(varargin{k});
                    cols = cols + size(varargin{k}, 2);
                else
                    break
                end
            end
            yop.assert(cond, yop.messages.incompatible_size( ...
                'horzcat', varargin{1}, varargin{k}));
            
            y = yop.operation('horzcat', size(varargin{1},1), cols, @horzcat);
            
            for k=1:length(varargin)
                y.set_child(varargin{k});
                varargin{k}.set_parent(y);
            end
        end
        
        function y = vertcat(varargin)
            row_cnt = 0;
            cond = true;
            for k = 1:length(varargin)
                cond = cond && size(varargin{k},2)==size(varargin{1},2);
                if cond
                    varargin{k} = yop.node.typecast(varargin{k});
                    row_cnt = row_cnt + size(varargin{k}, 1);
                else
                    break
                end
            end
            yop.assert(cond, yop.messages.incompatible_size( ...
                'vertcat', varargin{1}, varargin{k}));
            
            y = yop.operation('vertcat', row_cnt, size(varargin{1},2), @vertcat);
            
            for k=1:length(varargin)
                y.set_child(varargin{k});
                varargin{k}.set_parent(y);
            end
        end
        
    end
    
    methods % Computational graph
        
        function obj = order_nodes(obj)
            visited = yop.list;
            ordering = yop.list;
            
            function recursion(node)
                if isa(node, 'yop.operation') || isa(node, 'yop.relation')
                    for k=1:length(node.child.elem)
                        if ~visited.contains(node.child.elem(k).object)
                            recursion(node.child.elem(k).object);
                        end
                    end
                end
                add(visited, node);
                add(ordering, node);
            end
            
            recursion(obj);
            obj.eval_order = ordering;
        end
        
        function value = evaluate(obj)
            if isempty(obj.eval_order)
                obj.order_nodes();
            end
            for k=1:length(obj.eval_order.elem)
                obj.eval_order.elem(k).object.forward();
            end
            value = obj.value;
        end
    end
    
    methods % ool
        
        function z = plus(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('+', x, y));
            
            z_rows = max(size(x, 1), size(y, 1));
            z_cols = max(size(x, 2), size(y, 2));
            
            z = yop.operation('plus', z_rows, z_cols, @plus);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
            
            yop.debug.validate_size([z.rows, z.columns], ...
                size(plus(ones(size(x)), ones(size(y)))));
        end
        
        function z = minus(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('-', x, y));
            
            z_rows = max(size(x,1), size(y,1));
            z_cols = max(size(x,2), size(y,2));
            
            z = yop.operation('minus', z_rows, z_cols, @minus);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function y = uplus(x)
            y = yop.operation('uplus', x.rows, x.columns, @uplus);
            y.set_child(x);
            x.set_parent(y);
        end
        
        function y = uminus(x)
            y = yop.operation('uminus', x.rows, x.columns, @uminus);
            y.set_child(x);
            x.set_parent(y);
        end
        
        function z = times(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('.*', x, y));
            
            z_rows = max(size(x, 1), size(y, 1));
            z_cols = max(size(x, 2), size(y, 2));
            
            z = yop.operation('times', z_rows, z_cols, @times);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = mtimes(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = isscalar(x) || isscalar(y) || size(x,2)==size(y,1);
            yop.assert(cond, yop.messages.incompatible_size('*', x, y));
            
            z = yop.operation('mtimes', size(x,1), size(y,2), @mtimes);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = rdivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('./', x, y));
            
            z_rows = max(size(x,1), size(y,1));
            z_cols = max(size(x,2), size(y,2));
            
            z = yop.operation('rdivide', z_rows, z_cols, @rdivide);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = ldivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('.\', x, y));
            
            z_rows = max(size(x,1), size(y,1));
            z_cols = max(size(x,2), size(y,2));
            
            z = yop.operation('ldivide', z_rows, z_cols, @ldivide);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = mrdivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = isscalar(y) || size(x,2)==size(y,2);
            yop.assert(cond, yop.messages.incompatible_size('/', x, y));
            
            z = yop.operation('mrdivide', size(y,1), size(x,1), @mrdivide);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = mldivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = isscalar(x) || size(x,1)==size(y,1);
            yop.assert(cond, yop.messages.incompatible_size('\', x, y));
            
            z = yop.operation('mldivide', size(y,1), size(x,1), @mldivide);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = power(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('.^', x, y));
            
            z_rows = max(size(x, 1), size(y, 1));
            z_cols = max(size(x, 2), size(y, 2));
            
            z = yop.operation('power', z_rows, z_cols, @power);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = mpower(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = size(x,1)==size(x,2) && isscalar(y) || ...
                size(y,1)==size(y,2) && isscalar(x);
            yop.assert(cond, yop.messages.incompatible_size('^', x, y));
            
            z_rows = max(size(x, 1), size(y, 1));
            z_cols = max(size(x, 2), size(y, 2));
            
            z = yop.operation('mpower', z_rows, z_cols, @mpower);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function y = exp(x)
            y = yop.operation('exp', x.rows, x.columns, @exp);
            y.set_child(x);
            x.set_parent(y);
        end
        
        function y = expm(x)
            cond = size(x,1)==size(x,2);
            yop.assert(cond, yop.messages.wrong_size('expm', x));
            y = yop.operation('exp', x.rows, x.columns, @expm);
            y.set_child(x);
            x.set_parent(y);
        end
        
        function y = ctranspose(x)
            y = yop.operation('ctranspose', x.columns, x.rows, @ctranspose);
            y.set_child(x);
            x.set_parent(y);
        end
        
        function y = transpose(x)
            y = yop.operation('transpose', x.columns, x.rows, @transpose);
            y.set_child(x);
            x.set_parent(y);
        end
        
        function y = sign(x)
            y = yop.operation('sign', 1, 1, @sign);
            y.set_child(x);
            x.set_parent(y);
        end
        
        function z = dot(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = size(x)==size(y);
            yop.assert(cond, yop.messages.incompatible_size('dot', x, y));
            
            z = yop.operation('dot', size(x,1), size(x,2), @dot);
            
            z.set_child(x);
            z.set_child(y);
            x.set_parent(z);
            y.set_parent(z);
        end
        
        function z = cross(x, y)
            
        end
        
        function y = norm(x)
            r = 1;
            c = 1;
        end
        
        function log()
        end
        
        function r = lt(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant('lhs', size(rhs,1), size(rhs,2));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant('rhs', size(lhs,1), size(lhs,2));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('<', lhs, rhs));
            
            r = yop.relation('<', size(lhs,1), size(lhs,2), @lt);
            r.set_child(lhs);
            r.set_child(rhs);
            lhs.set_parent(r);
            rhs.set_parent(r); 
        end
        
        function r = gt(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant('lhs', size(rhs,1), size(rhs,2));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant('rhs', size(lhs,1), size(lhs,2));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('>', lhs, rhs));
            
            r = yop.relation('>', size(lhs,1), size(lhs,2), @gt);
            r.set_child(lhs);
            r.set_child(rhs);
            lhs.set_parent(r);
            rhs.set_parent(r); 
        end
        
        function r = le(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant('lhs', size(rhs,1), size(rhs,2));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant('rhs', size(lhs,1), size(lhs,2));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('<=', lhs, rhs));
            
            r = yop.relation('<=', size(lhs,1), size(lhs,2), @le);
            r.set_child(lhs);
            r.set_child(rhs);
            lhs.set_parent(r);
            rhs.set_parent(r); 
        end
        
        function r = ge(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant('lhs', size(rhs,1), size(rhs,2));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant('rhs', size(lhs,1), size(lhs,2));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('>=', lhs, rhs));
            
            r = yop.relation('>=', size(lhs,1), size(lhs,2), @ge);
            r.set_child(lhs);
            r.set_child(rhs);
            lhs.set_parent(r);
            rhs.set_parent(r); 
        end
        
        function r = ne(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant('lhs', size(rhs,1), size(rhs,2));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant('rhs', size(lhs,1), size(lhs,2));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('~=', lhs, rhs));
            
            r = yop.relation('~=', size(lhs,1), size(lhs,2), @ne);
            r.set_child(lhs);
            r.set_child(rhs);
            lhs.set_parent(r);
            rhs.set_parent(r);
        end
        
        function r = eq(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant('lhs', size(rhs,1), size(rhs,2));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant('rhs', size(lhs,1), size(lhs,2));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('==', lhs, rhs));
            
            r = yop.relation('==', size(lhs,1), size(lhs,2), @eq);
            r.set_child(lhs);
            r.set_child(rhs);
            lhs.set_parent(r);
            rhs.set_parent(r); 
        end
        
        % --- Logic ---
        % Size scalar?
        % ------------------------------------------------------------------------------------------------
        
    end
    
    
    methods (Static)

        function v = typecast(v)
            if ~isa(v, 'yop.node')
                v = yop.constant('c', size(v,1), size(v,2)).set_value(v);
            end
        end
        
        function bool = compatible(x, y)
            % COMPATIBLE Check if inputs are 2D compatible
            
            bool = isequal(size(x), size(y)) ...    Equal size
                || isscalar(x) || isscalar(y) ...   One input scalar
                || ( size(x,1)==size(y,1) ) ...     Same number of rows
                || size(x,1)==1 && size(y,2)==1 ... One row, one column
                || size(x,2)==1 && size(y,1)==1;
        end
        
    end
    
end



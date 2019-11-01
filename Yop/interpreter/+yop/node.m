classdef node < handle
    
    properties
        name % Name of the node.
        operation % operation possibly associated with node.
    end
    
    properties (SetObservable, AbortSet)
        value % Value associated with node.
    end
    
    properties (SetAccess=protected)
        rows    % Number of rows.
        columns % Number of columns.
        parents  % Parent nodes. Is proteced beacuse it needs a listener.
        children   % Child nodes.
    end
    
    properties (SetAccess=private, GetAccess=private)
        eval_order
    end
    
    methods
        
        function obj = node(name, size)
            if nargin == 1
                size = [1, 1];
            end
            obj.name = name;
            obj.rows = size(1);
            obj.columns = size(2);
            obj.parents = yop.node_listener_list();
            obj.children = yop.list();
        end
        
        function p = parent(obj, index)
            p = obj.parents.object(index);
        end
        
        function c = child(obj, index)
            c = obj.children.object(index);
        end
        
        function obj = add_parent(obj, parent)
            listener = addlistener(obj, 'value', 'PostSet', @parent.clear);
            obj.parents.add(parent, listener);
            parent.value = [];
        end
        
        function obj = remove_parent(obj, parent)
            obj.parents.remove(parent);
        end
        
        function obj = add_child(obj, child)
            obj.children.add(child);
        end
        
        function obj = remove_child(obj, child)
            obj.children.remove(child);
        end
        
        function obj = clear(obj, ~, ~)
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
            if isa(obj, 'yop.relation') && ...
                    ~isa(obj.left, 'yop.relation') && ...
                    ~isa(obj.right, 'yop.relation')
                % This is the end node.
                bool = true;
                
            elseif isa(obj, 'yop.relation') && ...
                    isa(obj.left, 'yop.relation') && ...
                    ~isa(obj.right,'yop.relation')
                bool = obj.left.isa_valid_relation();
                
            else
                bool = false;
                
            end
            
        end
        
        function bool = isa_symbol(obj)
            if isa(obj, 'yop.variable')
                bool = true;
                
            elseif ~isa(obj, 'yop.subs_operation')
                bool = false;
                
            else % has to be a subs_operation and therefore it's
                % sufficient to look at the first argument and see if that
                % tree only containts variables or subs_operations
                bool = obj.child(1).isa_symbol();
                
            end
        end
        
        function l = left(obj)
            l = obj.child(1);
        end
        
        function l = right(obj)
            l = obj.child(2);
        end
        
        function r = leftmost(obj)
            if isa_symbol(obj)
                r = obj;
            else
                r = obj.left.leftmost();
            end
        end
        
        function r = rightmost(obj)
            if isa_symbol(obj)
                r = obj;
            else
                r = obj.right.rightmost();
            end
        end
        
        
        
    end
    
    methods % Default changing behavior
        
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
        
        function ind = end(obj,k,n)
            szd = size(obj);
            if k < n
                ind = szd(k);
            else
                ind = prod(szd(k:end));
            end
        end
        
        function y = subsref(x, s)
            if s(1).type == "()" && (isnumeric(s(1).subs{1}) || strcmp(s(1).subs{1},':'))
                tmp = ones(size(x));
                tmp = tmp((s(1).subs{1}));
                
                txt = [x.name '(' num2str(s(1).subs{1}) ')'];
                y = yop.subs_operation(txt, size(tmp), @subsref);
                
                s_yop = yop.constant('s', [1, 1]);
                s_yop.value = s(1);
                
                y.add_child(x);
                y.add_child(s_yop);
                x.add_parent(y);
                s_yop.add_parent(y);
                
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
                
                z = yop.subs_operation(x.name, size(x), @subsasgn);
                
                s_yop = yop.constant('s', [1, 1]);
                s_yop.value = s(1);
                
                z.add_child(x);
                z.add_child(s_yop);
                z.add_child(y);
                x.add_parent(z);
                s_yop.add_parent(z);
                y.add_parent(z);
            else
                z = builtin('subsasgn',x, s, y);
            end
        end
        
        function y = horzcat(varargin)
            args = varargin(~cellfun('isempty', varargin));
            args = cellfun(@yop.node.typecast, args, 'UniformOutput', false);
            
            yop.assert(all(cellfun('size', args, 1)), ...
                yop.messages.incompatible_size('horzcat', args{1}, args{end}));
            
            sz = [size(args{1},1), sum(cellfun('size', args, 2))];
            y = yop.operation('horzcat', sz, @horzcat);
            
            for k=1:length(args)
                y.add_child(args{k});
                args{k}.add_parent(y);
            end
            
            yop.debug.validate_size(y, @horzcat, varargin{:});
        end
        
        function y = vertcat(varargin)
            args = varargin(~cellfun('isempty', varargin));
            args = cellfun(@yop.node.typecast, args, 'UniformOutput', false);
            
            yop.assert(all(cellfun('size', args, 2)), ...
                yop.messages.incompatible_size('vertcat', args{1}, args{end}));
            
            sz = [sum(cellfun('size', args, 1)), size(args{1}, 2)];
            y = yop.operation('vertcat', sz, @vertcat);
            
            for k=1:length(args)
                y.add_child(args{k});
                args{k}.add_parent(y);
            end
            
            yop.debug.validate_size(y, @vertcat, varargin{:});
        end
        
    end
    
    methods % Computational graph
        
        function obj = order_nodes(obj)
            visited = yop.list;
            ordering = yop.list;
            
            function recursion(node)
                if isa(node, 'yop.operation') || isa(node, 'yop.relation')
                    for k=1:length(node.children)
                        if ~visited.contains(node.child(k))
                            recursion(node.child(k));
                        end
                    end
                end
                visited.add_unique(node);
                ordering.add_unique(node);
            end
            
            recursion(obj);
            obj.eval_order = ordering;
        end
        
        function value = evaluate(obj)
            if isempty(obj.eval_order)
                obj.order_nodes();
            end
            for k=1:length(obj.eval_order)
                obj.eval_order.object(k).forward();
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
            
            z = yop.operation('plus', [z_rows, z_cols], @plus);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @plus, x, y);
        end
        
        function z = minus(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('-', x, y));
            
            z_rows = max(size(x,1), size(y,1));
            z_cols = max(size(x,2), size(y,2));
            
            z = yop.operation('minus', [z_rows, z_cols], @minus);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @minus, x, y);
        end
        
        function y = uplus(x)
            y = yop.operation('uplus', size(x), @uplus);
            y.add_child(x);
            x.add_parent(y);
            
            yop.debug.validate_size(y, @uplus, x);
        end
        
        function y = uminus(x)
            y = yop.operation('uminus', size(x), @uminus);
            y.add_child(x);
            x.add_parent(y);
            
            yop.debug.validate_size(y, @uminus, x);
        end
        
        function z = times(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('.*', x, y));
            
            z_rows = max(size(x, 1), size(y, 1));
            z_cols = max(size(x, 2), size(y, 2));
            
            z = yop.operation('times', [z_rows, z_cols], @times);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @times, x, y);
        end
        
        function z = mtimes(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = isscalar(x) || isscalar(y) || size(x,2)==size(y,1);
            yop.assert(cond, yop.messages.incompatible_size('*', x, y));
            
            z = yop.operation('mtimes', [size(x,1), size(y,2)], @mtimes);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @mtimes, x, y);
        end
        
        function z = rdivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('./', x, y));
            
            z_rows = max(size(x,1), size(y,1));
            z_cols = max(size(x,2), size(y,2));
            
            z = yop.operation('rdivide', [z_rows, z_cols], @rdivide);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @rdivide, x, y);
        end
        
        function z = ldivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('.\', x, y));
            
            z_rows = max(size(x,1), size(y,1));
            z_cols = max(size(x,2), size(y,2));
            
            z = yop.operation('ldivide', [z_rows, z_cols], @ldivide);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @ldivide, x, y);
        end
        
        function z = mrdivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = isscalar(y) || size(x,2)==size(y,2);
            yop.assert(cond, yop.messages.incompatible_size('/', x, y));
            
            z = yop.operation('mrdivide', [size(y,1), size(x,1)], @mrdivide);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @mrdivide, x, y);
        end
        
        function z = mldivide(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = isscalar(x) || size(x,1)==size(y,1);
            yop.assert(cond, yop.messages.incompatible_size('\', x, y));
            
            z = yop.operation('mldivide', [size(y,1), size(x,1)], @mldivide);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @mldivide, x, y);
        end
        
        function z = power(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            yop.assert(yop.node.compatible(x, y), ...
                yop.messages.incompatible_size('.^', x, y));
            
            z_rows = max(size(x, 1), size(y, 1));
            z_cols = max(size(x, 2), size(y, 2));
            
            z = yop.operation('power', [z_rows, z_cols], @power);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @power, x, y);
        end
        
        function z = mpower(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = size(x,1)==size(x,2) && isscalar(y) || ...
                size(y,1)==size(y,2) && isscalar(x);
            yop.assert(cond, yop.messages.incompatible_size('^', x, y));
            
            z_rows = max(size(x, 1), size(y, 1));
            z_cols = max(size(x, 2), size(y, 2));
            
            z = yop.operation('mpower', [z_rows, z_cols], @mpower);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @mpower, x, y);
        end
        
        function y = exp(x)
            y = yop.operation('exp', size(x), @exp);
            y.add_child(x);
            x.add_parent(y);
            
            yop.debug.validate_size(y, @exp, x);
        end
        
        function y = expm(x)
            cond = size(x,1)==size(x,2);
            yop.assert(cond, yop.messages.wrong_size('expm', x));
            y = yop.operation('exp', size(x), @expm);
            y.add_child(x);
            x.add_parent(y);
            
            yop.debug.validate_size(y, @expm, x);
        end
        
        function y = ctranspose(x)
            y = yop.operation('ctranspose', [x.columns, x.rows], @ctranspose);
            y.add_child(x);
            x.add_parent(y);
            
            yop.debug.validate_size(y, @ctranspose, x);
        end
        
        function y = transpose(x)
            y = yop.operation('transpose', [x.columns, x.rows], @transpose);
            y.add_child(x);
            x.add_parent(y);
            
            yop.debug.validate_size(y, @transpose, x);
        end
        
        function y = sign(x)
            y = yop.operation('sign', [1, 1], @sign);
            y.add_child(x);
            x.add_parent(y);
            
            yop.debug.validate_size(y, @sign, x);
        end
        
        function z = dot(x, y)
            x = yop.node.typecast(x);
            y = yop.node.typecast(y);
            
            cond = size(x)==size(y);
            yop.assert(cond, yop.messages.incompatible_size('dot', x, y));
            
            z = yop.operation('dot', size(x), @dot);
            
            z.add_child(x);
            z.add_child(y);
            x.add_parent(z);
            y.add_parent(z);
            
            yop.debug.validate_size(z, @dot, x, y);
        end
        
        function y = integral(x)
            x = yop.node.typecast(x);
            y = yop.operation('integral', size(x), @integral);
            y.add_child(x);
            x.add_parent(y);
        end
        
        function y = t0(x)
            x = yop.node.typecast(x);
            y = yop.operation('t0', size(x), @t0);
            y.add_child(x);
            x.add_parent(y);
        end
        
        function y = tf(x)
            x = yop.node.typecast(x);
            y = yop.operation('tf', size(x), @tf);
            y.add_child(x);
            x.add_parent(y);
        end
        
        function y = der(x)
            x = yop.node.typecast(x);
            y = yop.operation('der', size(x), @der);
            y.add_child(x);
            x.add_parent(y);
        end
        
        function y = alg(x)
            x = yop.node.typecast(x);
            y = yop.operation('alg', size(x), @alg);
            y.add_child(x);
            x.add_parent(y);
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
                lhs = yop.constant(yop.keywords().default_name_lhs, size(rhs));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant(yop.keywords().default_name_rhs, size(lhs));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('<', lhs, rhs));
            
            r = yop.relation('<', size(lhs), @lt);
            r.add_child(lhs);
            r.add_child(rhs);
            lhs.add_parent(r);
            rhs.add_parent(r);
        end
        
        function r = gt(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant(yop.keywords().default_name_lhs, size(rhs));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant(yop.keywords().default_name_rhs, size(lhs));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('>', lhs, rhs));
            
            r = yop.relation('>', size(lhs), @gt);
            r.add_child(lhs);
            r.add_child(rhs);
            lhs.add_parent(r);
            rhs.add_parent(r);
        end
        
        function r = le(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant(yop.keywords().default_name_lhs, size(rhs));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant(yop.keywords().default_name_rhs, size(lhs));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('<=', lhs, rhs));
            
            r = yop.relation('<=', size(lhs), @le);
            r.add_child(lhs);
            r.add_child(rhs);
            lhs.add_parent(r);
            rhs.add_parent(r);
        end
        
        function r = ge(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant(yop.keywords().default_name_lhs, size(rhs));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant(yop.keywords().default_name_rhs, size(lhs));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('>=', lhs, rhs));
            
            r = yop.relation('>=', size(lhs), @ge);
            r.add_child(lhs);
            r.add_child(rhs);
            lhs.add_parent(r);
            rhs.add_parent(r);
        end
        
        function r = ne(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant(yop.keywords().default_name_lhs, size(rhs));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant(yop.keywords().default_name_rhs, size(lhs));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('~=', lhs, rhs));
            
            r = yop.relation('~=', size(lhs), @ne);
            r.add_child(lhs);
            r.add_child(rhs);
            lhs.add_parent(r);
            rhs.add_parent(r);
        end
        
        function r = eq(lhs, rhs)
            if isnumeric(lhs)
                tmp = lhs.*ones(size(rhs));
                lhs = yop.constant(yop.keywords().default_name_lhs, size(rhs));
                lhs.value = tmp;
            elseif isnumeric(rhs)
                tmp = rhs.*ones(size(lhs));
                rhs = yop.constant(yop.keywords().default_name_rhs, size(lhs));
                rhs.value = tmp;
            end
            
            cond = size(lhs,1)==size(rhs,1)&&size(lhs,2)==size(rhs,2);
            yop.assert(cond, yop.messages.incompatible_size('==', lhs, rhs));
            
            r = yop.relation('==', size(lhs), @eq);
            r.add_child(lhs);
            r.add_child(rhs);
            lhs.add_parent(r);
            rhs.add_parent(r);
        end
        
        % --- Logic ---
        % Size scalar?
        % ------------------------------------------------------------------------------------------------
        
        function r = reshape(A, varargin)
            sz = size(reshape(ones(size(A)), varargin{:}));
            varargin = cellfun(@yop.node.typecast, varargin, ...
                'UniformOutput', false);
            
            r = yop.operation('reshape', sz, @reshape);
            
            r.add_child(A);
            A.add_parent(r);
            for k=1:length(varargin)
                r.add_child(varargin{k});
                varargin{k}.add_parent(r);
            end
            
        end
        
    end
    
    
    methods (Static)
        
        function v = typecast(v)
            if ~isa(v, 'yop.node')
                v = yop.constant(yop.keywords().default_name_constant, ...
                    size(v)).set_value(v);
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
        
        function varargout = sort(obj, mode, varargin)
            % Search tree in order to find subtrees mathching the criterias
            % in varargin.
            
            visited = yop.list;
            varargout = cell(size(varargin));
            for n=1:length(varargout)
                varargout{n} = yop.node_list();
            end
            
            function recursion(node)
                match = false;
                for k=1:length(varargin)
                    criteria = varargin{k};
                    if criteria(node)
                        varargout{k}.add(node);
                        match = true;
                        if mode=="first"
                            break
                        end
                    end
                end
                visited.add(node);
                if ~match
                    for k=1:length(node.children)
                        if ~visited.contains(node.child(k))
                            recursion(node.child(k))
                        end
                    end
                end
            end
            
            recursion(obj);
        end
        
    end
    
end



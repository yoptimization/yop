classdef operation < yop.node & yop.stupid_overhead
    properties
        timepoint
        index
    end
    methods
        
        function obj = operation(name, rows, columns, operation)
            obj.init(name, rows, columns);
            obj.operation = operation;
        end
        
        function obj = forward(obj)
            args = cell(size(obj.children));
            for k=1:size(args,2)
                args{k} = obj.child(k).value;
            end
            obj.value = obj.operation(args{:});
        end
        
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
end
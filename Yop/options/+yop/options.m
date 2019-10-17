classdef options < handle
    
    properties
        symbolic_engine
    end
    
    properties (Hidden)
        options_updated = false;
    end
    
    methods (Hidden)
        function obj = options()
        end
    end
    
    methods (Static) % Available options
        
        function store(opts)
            save(yop.options.get_options_path, 'opts');
            yop.options.updated(true);
        end
        
        function all_options = get()
            persistent opts
            if isempty(opts) || yop.options.updated
                % Test existens of file
                path = yop.options.get_options_path;
                if isfile(path)
                    tmp = load(path);
                    opts = tmp.opts;
                    yop.options.updated(false);
                else
                    opts = yop.options.default_options();
                end
            end
            all_options = opts;
        end
        
        function opts = set_symbolic_engine(engine)
            % set_symbolic_engine(engine) Sets which symbolic software to use.
            %   yop.options.set_symbolic_engine('symbolic_math')
            %   yop.options.set_symbolic_engine('casadi')
            %   yop.options.set_symbolic_engine('default')
            %
            % Available engines:
            %    engine = 'symbolic_math' - Use Matlab's symbolic math.
            %    engine = 'casadi'        - Use the CasADi framework.
            %    engine = 'default'       - Reset to the default option.
            opts = yop.options.get();
            opts.symbolic_engine = 'casadi';
            yop.options.store(opts);
        end
        
        function option1()
        end
        
        function option2()
        end
        
    end
    
    methods (Hidden, Static)
        
        function opts = default_options()
            opts = struct;
            opts.symbolic_engine = 'symbolic_math';
        end
        
        function bool = updated(is_updated)            
            state = yop.options.get_state();
            if nargin == 1
                state.options_updated = is_updated;
            end            
            bool = state.options_updated;
        end
        
        function state = get_state()
            persistent pers_state
            if isempty(pers_state)
                pers_state = yop.options();
            end
            state = pers_state;
        end
        
        function path = get_options_path()
            persistent pers_path
            if isempty(pers_path) 
                folder = fileparts( mfilename('fullpath') );
                filename = '/opts.mat';
                pers_path = [folder, filename];
            end
            path = pers_path;
        end
        
    end
end

























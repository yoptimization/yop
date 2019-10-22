classdef options < handle &  matlab.mixin.SetGetExactNames
    % OPTIONS Controls the default options in Yop.
    %    Options can be controlled in multiple ways.
    %    1. By obtaining the currently active option set by a call to:
    %         opts = yop.options()
    %       and manipulating the instace variable in opts.
    %
    %       To get help type:
    %         help yop.options/options
    %
    %    2. By calling the static methods
    %         yop.options.name_of_static_method();
    %
    %       To get help type:
    %         help yop.options.name_of_static_method();
    %
    % -- Properties --
    %    symbolics - Controls which symbolic package to use.
    %
    % -- Methods --
    %    obj = options(option_set) :Obtain the options currently used,
    %                                reset to the default options, or load
    %                                from file.
    %    save(obj, file_name)      :Save the options to file file_name.
    %
    % -- Methods (Static) --
    %    set_symbolics(name)       :Set the symbolic package.
    %    name = get_symbolics()    :Get the symbolic pacakge used.
    %
    % -- Details --
    %    The options class implements the singleton design pattern.
    %    It means that only one instance of the class is allowed.
    %    Therefore, when calling any of the option controlling static
    %    methods, the options in the singleton are
    %    changed. However, it is possible to store and load options
    %    from file. It is also possible to obtain the singleton by a
    %    call to this method. It is then possible to control the
    %    options by manipulating the instance variables.
    
    properties
        symbolics % Controls which symbolic package to use.
    end    
    
    methods
        
        function obj = options(option_set)
            % OPTIONS Controls the default behavior of Yop. Default 
            % options are overruled by local options such as the number of
            % collocation points.
            %
            % -- Syntax --
            %    options = yop.options();
            %    options = yop.options(option_set);
            %
            % -- Arguments --
            %    option_set : Optional argument. Controls the active
            %                 option set.
            %               = 'default' % Use default options.
            %               = 'file_name.mat' % load options from file.
            %
            % -- Examples --
            %    options = yop.options() % Get current options
            %
            %    yop.options('default')  % reset to default options
            %    options = yop.options('default') % Reset and get options
            %
            %    yop.options('file_name.mat') % Load options from file
            %    options = yop.options('file_name.mat') % Load and get
            
            persistent singleton
            if isempty(singleton) && nargin == 0
                set_default(obj);
                singleton = obj;
                
            elseif ~isempty(singleton) && nargin == 0
                obj = singleton;
                
            elseif isempty(singleton) && option_set == "default"
                set_default(obj);
                singleton = obj;
                
            elseif ~isempty(singleton) && option_set == "default"
                set_default(singleton)
                obj = singleton;
                
            else % Load from file
                tmp = load([fileparts(mfilename('fullpath')), '/stored/', option_set]);
                obj = tmp.obj;
                singleton = obj;
                
            end
        end
        
        function obj = save(obj, file_name)
            % SAVE Save the options 'obj' to the file file_name.
            %
            % -- Syntax --
            %    save(obj, file_name)
            %    obj.save(file_name)
            % 
            % -- Arguments --
            %    obj : Handle to the options
            %    file_name: Name of the file to store in. End with '.mat'.
            %
            % -- Examples --
            %    opts = yop.options();
            %    % modify opts
            %    opts.save('my_opts.mat')
            %
            % -- Details --
            %    All options are stored in 'options/+yop/stored/'. 
            
            path = [fileparts( mfilename('fullpath') ), '/stored/'];   
            if ~isfolder(path)
                mkdir(path);
            end
            save([path, file_name], 'obj');
        end
        
        function obj = set_default(obj)
            % SET_DEFAULT Reset the options to their default values.
            %
            % -- Syntax --
            %    set_default(obj)
            %    obj.set_default
            %
            % -- Arguments --
            %    obj : Handle to the option object
            
            obj.symbolics = 'casadi';
        end
        
    end
    
    methods (Static) % Available options
        
        function opts = use_default()
            % USE_DEFAULT Use the default options
            %
            % -- Syntax --
            %    yop.options.use_default()
            %
            % -- Arguments --
            %    opts : Handle to the current options.
            
            opts = yop.options();
            set_default(opts);
        end
        
        function opts = set_symbolics(name)
            % SET_SYMBOLICS Sets which symbolic software to use for
            %               computations.
            %
            % -- Syntax --
            %    yop.options.set_symbolics(name)
            %
            % -- Arguments --
            %    name : Name of the package to use.
            %         = 'symbolic math' % Use Matlab's symbolic math.
            %         = 'casadi'        % Use CasADi.
            %    opts : Handle to the current options.
            %
            % -- Examples --
            %    yop.options.set_symbolics('symbolic math')
            %    yop.options.set_symbolics('casadi')
            
            cond = name==yop.options.name_symbolic_math || ...
                   name==yop.options.name_casadi;
            yop.assert(cond, yop.messages.unrecognized_option(name, 'set_symbolics'));
            
            opts = yop.options();
            opts.symbolics = name;
        end
        
        function name = get_symbolics()
            % GET_SYMBOLICS Get which symbolic software is used for
            %               computations.
            %
            % -- Syntax --
            %    name = yop.options.get_symbolics()
            %
            % -- Arguments --
            %    name : Name of the package.
            
            opts = yop.options();
            name = opts.symbolics;
        end
        
        function opts = save_current(file_name)
            % SAVE_CURRENT Save the current options to file.
            %
            % -- Syntax --
            %    yop.options.save_current(file_name)
            % 
            % -- Arguments --
            %    file_name: Name of the file to store in. End with '.mat'.
            %    opts : Handle to the current options
            %
            % -- Details --
            %    All options are stored in 'options/+yop/stored/'.
            
            opts = yop.options();
            save(opts, file_name);
        end
        
    end
    
    methods (Hidden, Static)

       
        function txt = name_symbolic_math()
            txt = "symbolic math";
        end
        
        function txt = name_casadi()
            txt = "casadi";
        end
        
    end
    
end
















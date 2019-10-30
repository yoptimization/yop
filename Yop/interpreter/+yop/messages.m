classdef messages < handle
   methods (Static)
       function msg = error_size(dim)
           msg = ['Variables are matrix valued. Size of dimension ' num2str(dim) ' is therefore not possible.'];
       end
       
       function msg = wrong_size(operation, x)
            msg = ['Wrong dimensions for operation "', operation,'". You have: [' num2str(size(x)) '].'];
       end
       
       function msg = incompatible_size(operation, x, y)
            msg = ['Incompatible dimensions for operation "', operation,'". You have: [' num2str(size(x)) '] and [' num2str(size(y)) '].'];
       end
       
       function msg = unrecognized_option(option_passed, fn_name)
           msg = ['Option "' option_passed '" passed to ' fn_name ' is not recognized as a valid option'];
       end
       
%        function msg = graph_not_relation()
%            msg = 'Graph is not recognized as a relation.';
%        end
      
       function msg = graph_not_valid_relation()
           msg = 'Graph does not describe a valid relation. Valid graphs can be wrtitten similar to: expr <= expr > expr == expr. Not allowed: (expr<=expr) > (expr==expr).';
       end
       
       function msg = graph_not_simple()
           msg = 'Cannot turn the provided graph into nlp-form because it is not a single relation with the expressions connected to it. Consider to do a "split()" before putting on nlp-form.';
       end
       
       function msg = optimization_variable_missing()
           msg = 'An optimization variable must be provided.';
       end
       
       function msg = optimization_not_column_vector()
           msg = 'The optimization variable must be a column vector.';
       end
       
       function msg = debug_operation_wrong_size()
           msg = '[Debug] Operation produced the wrong size of the node.';
       end
       
   end
end
function flag = iscellOf(var, dataType)
%ISCELLOF Determines if input is a cell array containing a certain type
% == Parameters ========================================================================================================
% var (Any) - variable to be tested
% dataType (char) - Datatype to be tested
% == Returns ===========================================================================================================
% flag - true if input is a cell array containing object of type dataType
% ======================================================================================================================
flag = iscell(var) && all(cellfun(@(e) isa(e, dataType), var));
end


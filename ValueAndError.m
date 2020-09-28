classdef ValueAndError
    
    
    
    
    properties (Access = public)
        Value
        Error
        NumElements
    end
    

    
    methods (Access = public)
        %% c'tor:
        function obj = ValueAndError(Value,Error)
            %VALUEANDERROR Construct an instance of this class
            %   Insert a known Value and Error
            arguments
                Value (:,1) double = double.empty(0,1)
                Error  (:,1) double = double.empty(0,1)
            end
            
            %check input:               
            if  length(Value) > length(Error)     && length(Error)  == 1
                Error =  Error * ones(size(Value));
            elseif length(Value) ==   length(Error)
                % check if empty both inputs are empty:
                if isempty(Value) && isempty(Error)
                    Value = [];
                    Error = [];
                 % check if no input is empty:
                elseif ~isempty(Value) && ~isempty(Error)
                    % do nothing
                % If only one input is empty... that's a big no-no:
                else
                    error("Default Constructor can only get both  inputs as empty.");
                end
            else
                error("Incorrect Value and Error vector lengths");
            end
            
            %insert
            obj.Value = Value ;
            obj.Error = Error;
            obj.NumElements =  length(Value);

        end % C'tor
        function [ValueAndErrorOut] = mean(obj)
            ValueOut = mean( obj.Value );
            ErrorOut  = (1/obj.NumElements)*sqrt(  sum( (    obj.Error  ).^2  ) ) ;
            ValueAndErrorOut = ValueAndError(ValueOut , ErrorOut);
        end % mean
        function leftSideObj =  append(leftSideObj , RightSideObj)
            %APPEND  Append all values and errors of RightSideObj to the end of values and errors of leftSideObj.
            % leftSideObj =  append(leftSideObj , RightSideObj)
            %  Inputs:
            %     - leftSideObj     ValueAndError 
            %     - RightSideObj  ValueAndError 
            %  output:
            %     - leftSideObj ValueAndError - after appending.
            arguments
                leftSideObj     ValueAndError {mustBeValueAndError}
                RightSideObj  ValueAndError {mustBeValueAndError}
            end
            leftSideObj.Value = [leftSideObj.Value ; RightSideObj.Value];
            leftSideObj.Error   = [leftSideObj.Error   ; RightSideObj.Error ];
            leftSideObj.NumElements = leftSideObj.NumElements + RightSideObj.NumElements;
        end % append
    end % public methods
    
    methods (Access = public  , Hidden)
        function [] = disp(obj)
            % disp(ValueAndError) displays the ValueAndError object
            
            % For every object in an array of objects:
            for objIndex = 1 : length(obj)                
                valueAndErrorObj = obj(objIndex);
                Values = valueAndErrorObj.Value;
                Errors = valueAndErrorObj.Error;
                
                % for every value and an object with vector of values:
                NumElements2Plot = length(obj.Value);
                for i = 1 :  NumElements2Plot
                    

                    valueString =  string( num2str(Values(i)) ) ;
                    plusOrMinusString = " +- ";
                    errorString  =  string( num2str(Errors(i)) ) ;
                    valuesString = valueString + plusOrMinusString + errorString;
                    
                    AndStringStartIndex = strlength(valueString);
                    errorStringStartIndex = strlength(valueString) + strlength(plusOrMinusString);
                    
                    whiteSpacesFactor = 1;
                    titlesString =  pad("Value"                     , round(AndStringStartIndex*whiteSpacesFactor) ) ;
                    titlesString = pad( titlesString + plusOrMinusString  , round(errorStringStartIndex*whiteSpacesFactor) );
                    titlesString = titlesString + "Error:";
                    
                    % don't print titles for more than just the first element:
                    if i == 1
                        if NumElements2Plot == 1
                            disp(titlesString);
                        else
                            space = "";
                            for spaceIndex = 1 : length(   num2str( NumElements2Plot ) )
                                space = space + " ";
                            end
                            disp(space+titlesString);
                        end
                    end
                    if NumElements2Plot==1
                        disp(valuesString);
                    elseif NumElements2Plot > 1
                        precisionStr = "%"+num2str(  length(   num2str( NumElements2Plot ) ) ) + "d";
                        indexStr = sprintf( precisionStr  , i );
                        disp(indexStr  + ":  " + valuesString);
                    else
                        error("NumElements2Plot  is not legit");
                    end
                    
                end % i
            end % objIndex
        end % disp
        function output = subsref(objIn,S) 
            %overload idnexing:
            
            % Get Values and Errors:
            Values = objIn.Value;
            Errors  = objIn.Error;
            
            % Act according to way of indexing:
            if length(S)>=1
                Type = string(S(1).type);
            else
                error("Unexpected indexing method");
            end
            
            if Type == "()"                
                indices = S.subs{1};
                output = ValueAndError( Values(indices) , Errors(indices) );
            elseif Type == "."
                % if a   function with input,  use that function:
                if string(S(1).subs) == "append"
                    input = S(2).subs{1};
                    output =  objIn.append(input);
                else                    
                    output = objIn.(S(1).subs);
                end
            else
                error("Indexing with  " + Type +  "   is not supported for class ValueAndError");
            end
        end % subsref
        
        function ind = end(obj,k,n)
            %END override the ValueAndError(end)  indexing:
            ind = obj.NumElements;                       
        end % end

    end % methods (Access = public  , Hidden )
    
    methods (Static)
        function ValueAndErrorOutput = fromstandardDeviationOfValues( Values)
            %fromFunction Construct an instance of this class from a big sample of values.
            %   Derives Error by computing the Standart Deviation (std) of a large sample.
            %
            %   Inputs:  
            %      - Values: 1D vector of values that should resemble the same result.
            %
            %   Output: An instance of ValueAndError.
            %
            % By: Nir Gutman
            arguments
                Values
            end
            ValueAndErrorOutput = ValueAndError(Values , std(Values) );
        end
        function ValueAndErrorOutput = fromFunction( Function , ValueAndErrorInputs)
            %fromFunction Construct an instance of this class from other members of this class
            %   Derives Value and Error from a  function with given inputs which also have Value and Error. 
            %
            %   Inputs:  
            %      - Function: A symbolic function or a function handle. Note the order of input arguments.
            %      - InputValueAndArror:  Comma devided ValueAndError objects  in the same order as Function dictates.
            %
            %   Output: An instance of ValueAndError derived from "Function" and the given inputs.
            %
            % By: Nir Gutman            
           arguments
               Function  
           end%arguments
           arguments (Repeating)
               ValueAndErrorInputs ValueAndError {mustBeValueAndError}
           end
           
           [SymbolicFunction , InputCellArray ] = assert_and_deduce_inputs(Function , ValueAndErrorInputs);
           
      
            SymbolicInputs = argnames(SymbolicFunction);
           if isempty(SymbolicInputs) ||  (  length(SymbolicInputs) ~=  length(InputCellArray) )
               error("Expected a symbolic function with as many input arguments as given by ValueAndErrorInputs ");
           end
           
           % Compute lengths of data:
           NumSymbolicInputVariables = length(SymbolicInputs);
           
           NumGivenInputs_i = zeros(length( InputCellArray ) , 1);
           for i = 1: length( InputCellArray )
               NumGivenInputs_i(i) = InputCellArray{i}.NumElements;
           end
           [LengthLongestGivenInput  , indexLongestGivenInput]= max(NumGivenInputs_i);
           
           %If we are dealing with vectors, duplicate each input that was given as a single value:
           if LengthLongestGivenInput>1 && any(NumGivenInputs_i<LengthLongestGivenInput)
               indices_need_multiplication  = find(NumGivenInputs_i<LengthLongestGivenInput);
               %if any of these is larger than 1, we have a problem:
               if any( NumGivenInputs_i(indices_need_multiplication) > 1 )
                   error("If an input is a vector, then other inputs should be either of the same length, or of length 1");
               end
                % to what dimensions should we enlarge our single inputs:
                SizeLonges = size( InputCellArray{indexLongestGivenInput}.Value );
               for  index = indices_need_multiplication
                   SingleInput = InputCellArray{index};
                   LongerValues = SingleInput.Value*ones(SizeLonges);
                   LongerErrors  = SingleInput.Error*ones(SizeLonges);
                   InputCellArray{index} = ValueAndError(LongerValues , LongerErrors);
               end
           end
           
           % Prepare Inputs :
           InValues = zeros(LengthLongestGivenInput , NumSymbolicInputVariables);
           InErrors =  zeros(LengthLongestGivenInput , NumSymbolicInputVariables);
           for j = 1 : NumSymbolicInputVariables
               inputValueAndError = InputCellArray{j};
               InValues(:,j) = inputValueAndError.Value;
               InErrors(:,j)  = inputValueAndError.Error;
           end
           
           % Prepare Valued errors to use for the overall error :  
           ValuedErrors           = zeros(LengthLongestGivenInput, NumSymbolicInputVariables);
           
            % Itterate over all symbolic inputs to compute derivatives:
             for j = 1:NumSymbolicInputVariables
                 SymInput_i = SymbolicInputs(j);
                 SymDerivative_i = diff( SymbolicFunction , SymInput_i );                 

                 % for each symbolic input, itterate over all vector values and errors:
                 for i = 1:LengthLongestGivenInput                                          
                     %Cumpute The Value of Derivative:
                     InValues_i = InValues(i,:) ;
                     ValuedDerivative = vpa(      subs(SymDerivative_i  ,   SymbolicInputs  ,  InValues_i  ) )  ;
                     % Using Derivative's Value, compute value of Error: 
                     ValuedErrors(i,j) =     vpa(   ValuedDerivative  *    InErrors(i,j)  ) ;
                 end % for i
             end % for j
           
             % Prepare Outputs Values:
             OutputValues = zeros(LengthLongestGivenInput,1);
             % Compute Output Values:
             for i = 1 : LengthLongestGivenInput
                 OutputValues(i) = double(  vpa(    subs(SymbolicFunction , SymbolicInputs , InValues(i,:)  )   )  );
             end
             % Compute Output Errors:
             OutputErrors = double(sqrt(sum(ValuedErrors.^2,2)));
             
             % output is now a column vector,  check if we should flip to row vector (dipends on input):
              imputDimensions = size( InputCellArray{1}.Value );
              if imputDimensions(2) > imputDimensions(1)  % row vector
                  OutputValues = OutputValues.';
                  OutputErrors   = OutputErrors.';
              end
             ValueAndErrorOutput = ValueAndError(OutputValues , OutputErrors );
                  
        end % fromFunction
        
        function [ OutputValue , OutputError] = compute_value_and_error_without_objects( SymbolicFunction, InputValues , InputErrors )
            %[ OutputValue , OutputError] = compute_value_and_error_without_objects( SymbolicFunction, InputValues , InputErrors ) Calculates the value and the error of a function
            % when some inputs are known withing a certein error.
            %
            % Inputs:
            %        -  SymbolicFunction
            %        -  InputValues
            %        -  InputErrors
            %
            % Outputs:
            %        -  OutputValue
            %        -  OutputError
            %
            % Example:
            % ==============
            % syms v(f,m)
            % v(f,m) = 2*pi*f/m ;
            % SymFucntion = v;
            % InputValues = [5      , 10  ];
            % InputErrors = [0.01   , 0.2 ];
            % [OutputValue , OutputError] = lab_value_and_error( SymFucntion, InputValues , InputErrors )
            %
            % By: Nir Gutman & Ohad Segal
            
            SymbolicInputs = argnames(SymbolicFunction);
            if isempty(SymbolicInputs)
                errorMsg = "Expected to get SymbolicFunction with Symbolic Input Arguments." + newline + ...
                    "Tip: Create your symbolic function with specific arguments. Then when applying a function to that symbolic function, " + ...
                    "use those same arguments. " + newline + ...
                    "Example: " + newline + ...
                    "    syms  f(x,y)  " + newline + ...
                    "     f(x,y)  =  y * x^2 " ;
                error(errorMsg);
            end
            NumInputs = length(SymbolicInputs);
            ValuedDerivatives = zeros(1, NumInputs);
            ValuedError = zeros(1, NumInputs);
            
            for i = 1:NumInputs
                SymInput_i = SymbolicInputs(i);
                SymDerivative_i = diff( SymbolicFunction , SymInput_i );
                InputError_i  = InputErrors(i)  ;
                %Cumpute error relative to argument i:
                ValuedDerivatives(i) = vpa(      subs(SymDerivative_i  ,   SymbolicInputs  ,  InputValues  ) )  ;
                ValuedError(i) =     vpa(   ValuedDerivatives(i)  *    InputError_i  ) ;
            end
            
            % Compute Output error concerning all arguments:
            OutputError = double(sqrt(sum(ValuedError.^2)));
            % Compute Output Value:
            OutputValue = double(  vpa(    subs(SymbolicFunction , SymbolicInputs , InputValues)   )  );
        end % compute_value_and_error_without_objects
    end % static methods 
    
    
end % class






function [symbolicFunction , InputCellArray ] = assert_and_deduce_inputs(Function , ValueAndErrorInputs)

       %Assert input array is  a cellArray:
       if iscell(ValueAndErrorInputs)
           InputCellArray = ValueAndErrorInputs;
       else
           error("Expected Repeating Argument  ""InputArray"" to be  a  Cell Array ");
       end

       % Fuction can be either a function handle or a symbolic function.
       if string(class(Function)) ==  "function_handle"                      
             symbolicFunction = function_handle_to_symbolic_function( Function );
       elseif  string(class(Function)) ==  "symfun"
           symbolicFunction = Function;
       else
           error("What kind of Function did we get as input?");
       end

end % assert_and_deduce_inputs



function symbolicFunction = function_handle_to_symbolic_function(FunctionHanlde)

    % find strings out of function handle:
    inputFunctionString=func2str(FunctionHanlde);
    functionStringParts =regexp(inputFunctionString,'[^()]*','match');
    % break into arguments and operation:
    argumentsStrings = regexp(functionStringParts{2},'\,','split');
    operationString = regexp(inputFunctionString,'(?<=[\)])\S*','match');
    % create Symbolic arguments and operation:
    %            SymbolicOpertaion  =  str2sym(operationString{1})  ;
    %            SymbolicArguments = str2sym(argumentsStrings{1} );

    % create one function string   like f(a,b):
    standartFunctionString = "ValueAndError_Symbolic_Function_(" + argumentsStrings{1};
     for i = 2 : length(argumentsStrings)
         standartFunctionString = standartFunctionString +"," + argumentsStrings{i};
     end
     standartFunctionString = standartFunctionString + ")";

     % create symbolic function named f:
     syms(standartFunctionString) ;
     % Implement the function 
     try 
         eval(  standartFunctionString + " = " + operationString{1} );
     catch
         error("Given FunctionHanlde couldn't be analyzed. Check syntax and try running your function handle seperately. "+ newline + ...
                    "One Reason for failure might be that parts of the function are known in a limited context." + newline +...
                   "Try bringing those Sub-functions to an outside .m  file (MATLAB Script). "+ newline +...  
                   "Also, consider using a MATLAB symbolic function as input instead." + newline +  ...
                   newline +...   
                   "Function handle is :  " + string(inputFunctionString) ...
                   );
     end

     % finish:
     symbolicFunction = ValueAndError_Symbolic_Function_;
end


function mustBeValueAndError(A)
%mustBeValueAndError Validate that value is of class ValueAndError or issue error
%   mustBeValueAndError(A) issues an error if A contains objects not of class ValueAndError. 
%   MATLAB calls mustBeValueAndError to determine if a value is member of ValueAndError.
%
%   See also: isnumeric
        
%   Copyright 2020 Nir Gutman

     try
         S = whos("A");
         ClassString =  string(S.class);
         
         if ClassString ~= "ValueAndError"
             throw(createValidatorException('MATLAB:validators:mustBeValueAndError'));
         end
     catch
         error("mustBeValueAndError failed to determine class  " +    ClassString );
     end
end
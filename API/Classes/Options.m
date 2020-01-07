classdef Options
    properties (Access = public)
        list;%list of possible options
        default;%default options
        custom;%currently selected options
    end
    methods
        function obj=Options(varargin)
            if rem(length(varargin),2)>0
                error('Option initialized with no value');
            end
            %obj.list=struct(varargin);
            for i=1:2:length(varargin)
                obj.list.(varargin{i})=varargin{i+1};
                obj.default.(varargin{i})=obj.list.(varargin{i})(1);
                obj.custom.(varargin{i})=obj.list.(varargin{i})(1);
            end
        end
        function obj=set.custom(obj,val)
            names=fieldnames(val);
            for i=1:length(names)
                if isfield(obj.list,names(i))==1
                    obj.custom.(names{i})=val.(names{i});
                    
                else
                    warning(strcat('no such property: ',string(names(i))))
                end
            end
        end
    end
end
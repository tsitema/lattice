classdef Misc
    methods(Static)
        %arrays of structures to structure of arrays
        function soa= aos2soa(aos)
            props=fieldnames(aos);
            for i=1:length(props)
                sprop=props{i};
                soa.(sprop)=[aos.(sprop)]';
            end
        end
        %noise function
        function fcn=noise(longpass)
            samples=1000;
            rndlist=rand(1,samples);
            tlist=(0:samples-1).*longpass;
            fcn =@(t) interp1(tlist,rndlist,t);
        end
    end
end
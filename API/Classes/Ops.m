%DEPRECATED
classdef Ops
    properties
        %this will be the diagonal matrix in the hamiltonian. this is
        %configurable and determines the behaviour of the system.
        matrix;        
    end
    properties (SetAccess=protected)
        %operators are class specific anonymous functions. They take the
        %state vector as input, and perform operations on it and return.
        %equation class is responsible for forming the collective matrix of
        %the system. Operator should take two inputs, state vector and the
        %matrix that represent the state of the corresponding nonlinear 
        %part of the individual nodes.
        operator;
    end
end
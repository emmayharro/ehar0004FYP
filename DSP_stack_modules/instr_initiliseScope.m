function [scope_obj] = initiliseScopeLean(scope,interface,vendor);
%setup the Scope and environment for acquisition

%% Define Configuration Parameters

if strcmp(vendor,'ni')==1
    Leader.Interface='ni';
elseif strcmp(vendor,'agilent')==1
    Leader.Interface='agilent';
else
    Leader.Interface='agilent';
end

if strcmp(scope,'leader')==1
    if strcmp(interface,'TCPIP')==1
        Leader.Addr = 'TCPIP0::AGILENT-DSO1::inst0::INSTR'; %other scope address (TCPIP remote)
    elseif strcmp(interface,'USB')==1
        Leader.Addr = 'USB0::2391::36882::MY50270102::0::INSTR'; %A series scope address (USB remote)
    elseif strcmp(interface,'local')==1
        Leader.Addr = 'TCPIP0::localhost::inst0::INSTR'; % Leader visa address
    else
        error('interface not defined')
    end
elseif strcmp(scope,'follower')==1
    if strcmp(interface,'TCPIP')==1
        Leader.Addr = 'TCPIP0::AGILENT-442A484::inst0::INSTR'; %other scope address (TCPIP remote)
    elseif strcmp(interface,'USB')==1
        Leader.Addr = 'USB0::2391::36883::MY50270101::0::INSTR'; %A series scope address (USB remote)
    elseif strcmp(interface,'local')==1
        Leader.Addr = 'TCPIP0::localhost::inst0::INSTR'; % Leader visa address
    else
        error('interface not defined')
    end
elseif strcmp(scope,'Qseries')==1
    if strcmp(interface,'TCPIP')==1
        Leader.Addr = 'TCPIP0::169.254.42.221::inst0::INSTR'; %Q series scope address (TCPIP remote)
    elseif strcmp(interface,'USB')==1
        Leader.Addr = 'USB0::0x2A8D::0x9054::MY54410101::INSTR'; %Q series scope address (USB remote)
    elseif strcmp(interface,'local')==1
        Leader.Addr = 'TCPIP0::localhost::inst0::INSTR'; % Leader visa address
    else
        error('interface not defined')
    end
elseif strcmp(scope,'ZseriesRMIT')==1
    if strcmp(interface,'TCPIP')==1
        Leader.Addr = 'TCPIP0::169.254.98.88::inst0::INSTR'; %Q series scope address (TCPIP remote)
    elseif strcmp(interface,'USB')==1
        Leader.Addr = 'USB0::0x2A8D::0x905C::MY55160102::INSTR'; %Q series scope address (USB remote)
    elseif strcmp(interface,'local')==1
        Leader.Addr = 'TCPIP0::localhost::inst0::INSTR'; % Leader visa address
    else
        error('interface not defined')
    end
elseif strcmp(scope,'QseriesUSyd')==1
    if strcmp(interface,'TCPIP')==1
        Leader.Addr = 'TCPIP0::127.0.0.1::inst0::INSTR'; %Q series scope address (TCPIP remote)
    elseif strcmp(interface,'USB')==1
        Leader.Addr = 'USB0::0x2A8D::0x9052::MY53060101::INSTR'; %Q series scope address (USB remote)
    elseif strcmp(interface,'local')==1
        Leader.Addr = 'TCPIP0::localhost::inst0::INSTR'; % Leader visa address
    else
        error('interface not defined')
    end
else
    error('scope not defined')
end


%open remote interfaces
scope_obj = visa(Leader.Interface,Leader.Addr);
fopen(scope_obj);

fprintf(scope_obj,[':acq:interpolate Off']);
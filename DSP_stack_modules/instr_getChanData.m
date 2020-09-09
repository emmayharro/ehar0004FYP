function [k, WfmTmp] = getDataChanSelectLean(scope_obj,chs)
    fopen(scope_obj);

    if ~exist('chs','var')
        chs=[1,2,3,4];
    end
    %% Freeze waveform for data transfer
	instr_AcquireWaveform(scope_obj);

	%% Read the digitized waveforms
	for ii=1:length(chs)
    WfmTmp{ii} = instr_ReadScopeWfm(scope_obj,['Chan' num2str(chs(ii))]);
    end
    
	k = 1:1:length(WfmTmp{1}.Data);
	
    %% Run scope again ('unfreeze' waveform)
    fprintf(scope_obj,':run');
	
    fclose(scope_obj);
	
end
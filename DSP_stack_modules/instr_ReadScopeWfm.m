function Wfm = ReadScopeWfmLean(scope_obj,Source)


%% Define Data Waveform Settings
NBytes = 1;
BlockReadType = 'int8';
MaxBlockSize = pow2(20);

%% Set waveform data settings on scope
    fprintf(scope_obj,[':wav:source ',Source]);
    fprintf(scope_obj,':wav:byteorder lsbfirst');
    fprintf(scope_obj,[':wav:format ','byte']);

%% Read waveform Wfm info
%can be trimmed down to finding the number of points ...
    fprintf(scope_obj,':wav:points?'); 
    Wfm.Points = str2double(fscanf(scope_obj));

%% Set input buffer size and timeout
    % InputBufferSize cannot be set while OBJ is open.
    fclose(scope_obj);  
    set(scope_obj,'TimerPeriod',max(10,1e-6*Wfm.Points*NBytes));
    PrevInBuffSize = get(scope_obj,'InputBufferSize');
    BlockSize = min(pow2(ceil(log2(Wfm.Points))),MaxBlockSize);
    set(scope_obj,'InputBufferSize',NBytes*BlockSize);
    fopen(scope_obj); 

%% Read waveform data
    % We have to loop over the different s due to stack limitations in matlab.
        BlockCount = int8(ceil(max(1,Wfm.Points/BlockSize)));
        for Block = 0:BlockCount - 1;
            StartPoint = double(Block) * BlockSize + 1;
            EndPoint = min((double(Block + 1)) * BlockSize,Wfm.Points);
            PointsRead = EndPoint - StartPoint + 1;
            fprintf(scope_obj, sprintf(':wav:data? %d,%d', StartPoint,PointsRead));        
            tmp = binblockread(scope_obj,BlockReadType);
			if ~isempty(tmp)
				Wfm.Data(StartPoint:EndPoint,1) = tmp;
			else
				fprintf(1, 'Error reading from scope: %s. Returned 0 bytes\n', Source);
			end
			
            Junk = fread(scope_obj,1,'schar');  %#ok Read out end of file character.
        end
    
end





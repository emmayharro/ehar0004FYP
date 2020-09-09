function AcquireWaveformLean(scope_obj)

%  pause(3);

fprintf(scope_obj,':stop');
fprintf(scope_obj,'*opc?'); Junk = str2double(fscanf(scope_obj)); %#ok
fprintf(scope_obj,':ader?'); AcquisitionDone = str2double(fscanf(scope_obj)); %#ok
fprintf(scope_obj,':pder?'); ProcessingDone = str2double(fscanf(scope_obj)); %#ok
fprintf(scope_obj,':single');

%% Wait for both acquisitions to complete

fprintf(scope_obj,':ader?'); AcquisitionDone = str2double(fscanf(scope_obj));
while ~AcquisitionDone
    fprintf(scope_obj,':ader?'); AcquisitionDone = str2double(fscanf(scope_obj));
    pause(0.01);
end
fprintf(scope_obj,':pder?'); ProcessingDone = str2double(fscanf(scope_obj));
while ~ProcessingDone
    fprintf(scope_obj,':pder?'); ProcessingDone = str2double(fscanf(scope_obj));
    pause(0.01);
end

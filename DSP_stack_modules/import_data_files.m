function [XI,XQ,YI,YQ]=import_data_files()

% inputs: 
%
% None.
%
% outputs - real and imaginary components from generated data files:
%
% XI - real component of x-pol field
% XQ - imag component of x-pol field
% YI - real component of y-pol field
% YQ - imag component of y-pol field

cd data_files
XI=importdata('tmp_real_X.txt');
XQ=importdata('tmp_imag_X.txt');
YI=importdata('tmp_real_Y.txt');
YQ=importdata('tmp_imag_Y.txt');
cd ..
clear all;
close all;
clc;

delete(instrfind)

[scope_id] = initiliseScopeLean('follower','USB','ni');
[k,XI,XQ,YI,YQ] = getDataLean(scope_id);

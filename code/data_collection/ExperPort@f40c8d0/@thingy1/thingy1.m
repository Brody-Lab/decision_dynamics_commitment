function [obj] = thingy1;

obj = struct('empty', []);
obj = class(obj, 'thingy1');

SoloParamHandle(obj, 'blah');

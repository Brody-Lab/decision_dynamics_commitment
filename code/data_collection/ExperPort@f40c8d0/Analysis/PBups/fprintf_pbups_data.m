function fprintf_pbups_data(ratdata, filename)

% takes ratdata, an output of package_pbups_data, and must conform to that
% standard format
%
% ratdata should be a struct array with the following fields, where each
% element of the array represents an individual, non-violation trial:
%	T:			duration of the stimulus, in seconds
%	leftbups:	times of bups played on left
%	rightbups:	times of bups played on right
%	pokedR:		whether the rat poked right

fid = fopen(filename, 'w');

ntrials = length(ratdata);

fprintf(fid, '%d\n', ntrials);

for n = 1:ntrials,
	fprintf(fid, '%e %d\n', ratdata(n).T, ratdata(n).pokedR);
	
	fprintf(fid, '%i ', length(ratdata(n).leftbups));
	for c = 1:length(ratdata(n).leftbups),
		fprintf(fid, '%e ', ratdata(n).leftbups(c));
	end;
	fprintf(fid, '\n');
	
	fprintf(fid, '%i ', length(ratdata(n).rightbups));
	for c = 1:length(ratdata(n).rightbups),
		fprintf(fid, '%e ', ratdata(n).rightbups(c));
	end;
	fprintf(fid, '\n');
end;

fclose(fid);
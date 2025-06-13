function map_network_drives(message)

    % matlab utility for automatically connecting network storage drives
    % (bucket, archive_me, sink and archive) on windows or mac

    locations = {   'latrobe.princeton.edu\pni-archive',...
                    'cup.pni.princeton.edu\archive_me',...
                    'cup.pni.princeton.edu',...
                    'bucket.pni.princeton.edu\scratch'   };

    if ~ispc
        for i=1:numel(locations)
            locations{i} = strrep(locations{i},'\','/');
        end
    end

    letters = {'Z','Y','X','T'};            

    if ~nargin
        message={'',''};
    end
    prompt = {'Enter PU ID','Enter PU ID password'};    
    for i=1:2
        prompt{i} = [prompt{i},message{i}];
    end
    dlgtitle = 'Network Credentials';
    dims = [1 35];
    definput = {'',''};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    if isempty(answer)
        return
    end
    if isempty(answer{1})
        message='(must not be empty)';
        map_network_drives({message,''});
        return;
    end
    if isempty(answer{2})
        message='(must not be empty)';
        map_network_drives({'',message});
        return;
    end
    if contains(lower(answer{1}),'princeton')
        message = ' ONLY (do not include princeton prefix or suffix)';
        map_network_drives({message,''});
        return
    end
    
    fprintf('\n');
    for i=1:length(letters)
        if ispc
            [~,~] = system(sprintf('net use %s: /delete /y',letters{i}));
            fprintf('Mapping %s: ---> \\\\%s\\brody ... ',letters{i},locations{i});
            system(sprintf('net use %s: \\\\%s\\brody /user:princeton\\%s %s',letters{i},locations{i},answer{1},answer{2}));
        elseif ismac
            [~,~] = system(sprintf('umount /Volumes/mnt/%s',letters{i}));
            fprintf('Mapping /Volumes/mnt/%s: ---> //%s/brody ... \n',letters{i},locations{i});
            system(sprintf('mount -t smbfs //%s:%s@%s/brody /Volumes/mnt/%s',answer{1},strrep(answer{2},'!','\!'),locations{i},letters{i}));
        else
            error('Not supported for this OS.')
        end
    end

end
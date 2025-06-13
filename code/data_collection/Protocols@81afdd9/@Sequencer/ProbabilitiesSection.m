% [x, y] = ProbabilitiesSection(obj, action, x, y)
%
%
%
%
% PARAMETERS AND RETURNS:
% -----------------------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init' x y
%            Initializes the plugin and sets up the GUI for it. Requires
%            two extra arguments, which will be the (x, y) coords, in
%            pixels, of the lower left hand corner of where this plugin's
%            GUI elements will start to be displayed in the current figure.
%            Returns [x, y], the position of the top left hand corner of
%            the plugin's GUI elements after they have been added to the
%            current figure.
% 
%   'get_probabilities'  Returns a cell array with two columns. The first
%            one will have char entries, each composed of only 'L' and 'R', 
%            like 'LLR'.  They represent a sequence of side pokes.  The 
%            second column will have numeric entries, all positive and
%            adding up to 1, which represent the prior probability of
%            choosing each sequence on a given trial.     
%
%   'set_probabilities'  Takes as argument a cell array in the same format 
%            as 'get_probabilities' returns, and sets the probabilities to
%            the passed values. Any probability less than zero will be set
%            to zero, and their sum will be normalized to 1. The number of
%            rows must be equal to 2^nSides, and the first column of the
%            passed cell array must cover every one of the 2^nSides
%            possibilities. Otherwise a warning will be thrown and the
%            probabilities will nto be changed.
%
%   'normalize'  Makes sure all probabilities are positive and add up to 1
%
%   'hide'   hide the window with the probabilities
%
%   'show'   show the window with the probabilities
%
%   'show_hide'  call 'show' or 'hide' depending on value of SPH ProbabilitiesShow
%
%   'close'  Delete all of this section's GUIs and data.
%
%   'reinit' Delete all of this section's GUIs and data, and reinit, at the
%            same position on the same figure as the original section GUI
%            was placed.
%



function [x, y] = ProbabilitiesSection(obj, action, x, y)

GetSoloFunctionArgs(obj);

switch action
    case 'init'     
        % Save the figure and the position in the figure where we are going to start adding GUI elements:
        SoloParamHandle(obj, 'my_gui_info', 'value', [x y double(gcf)]);
        
        ToggleParam(obj, 'ProbabilitiesShow', 0, x, y, 'OnString', 'Probabilities Showing', ...
            'OffString', 'Probabilities Hidden', 'TooltipString', 'Show/Hide Probabilities panel');
        set_callback(ProbabilitiesShow, {mfilename, 'show_hide'});  %#ok<*NODEF,*STRNU>
        next_row(y);
                       
        
        SubheaderParam(obj,'title',mfilename,x,y); next_row(y, 1.5);
        
        
        % Store current position in original figure
        SoloParamHandle(obj, 'my_xyfig', 'value', [x y double(gcf)]);
        
        % Make new figure, myfig
        SoloParamHandle(obj, 'myfig', 'value', double(figure('Position', [ 226   671   233    (2^nSides)*20+40], ...
            'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
            'Name', mfilename)), 'saveable', 0);

        % internal copy of nSides, to be able to detect changes:
        SoloParamHandle(obj, 'my_nSides', 'value', value(nSides))

        nx=10; ny=10;
        for myId = 0:(2^nSides - 1)
            binaryId = replace(replace(dec2bin(myId, nSides), '0', 'L'), '1', 'R');
            for digit=1:nSides
                DispParam(obj, char("d" + binaryId + "_" + (digit-1)), binaryId(digit), nx, ny, ...
                    'position', [nx, ny, 30, 20], 'labelfraction', 0.1, 'label', '', ...
                    'HorizontalAlignment', 'center'); nx = nx+33; 
            end 
            NumeditParam(obj, char("p" + binaryId), 1/(2^nSides), nx, ny, 'position', [nx, ny, 220-nx, 20]);
            set_callback(eval(char("p" + binaryId)), {mfilename, 'normalize'});
            nx=10; next_row(ny);            
        end
        SubheaderParam(obj, 'sidesProbs', 'sides and probs', nx, ny)

        feval(mfilename, obj, 'hide');
        
        x = my_xyfig(1);
        y = my_xyfig(2);
        figure(my_xyfig(3))
        
        
    case 'get_probabilities'
        nSequences = 2^nSides;
        seqs = cell(nSequences, 2);
        for myId = 1:2^nSides
            binaryId = replace(replace(dec2bin(myId-1, nSides), '0', 'L'), '1', 'R');
            prob = value(eval(char("p" + binaryId)));
            seqs{myId, 1} = binaryId;
            seqs{myId, 2} = prob;
        end
        x = seqs;

        
    case 'set_probabilities'
        nSequences = 2^nSides;
        seqs = x;
        if ~iscell(seqs) || cols(seqs) ~= 2 || rows(seqs) ~= nSequences
            warning([mfilename ' : set_probabilities requires a cell array of probabilities\n' ...
                'That cell must have 2 columns and 2^nSequences rows.\nNo action taken'], 1);
            return;
        end
        
        % Check that the first column contains only the expected and required sequences:
        labels = seqs(:,1);
        for myId = 1:2^nSides
            binaryId = replace(replace(dec2bin(myId-1, nSides), '0', 'L'), '1', 'R');
            % Check each label
            for j=1:length(labels)
                % if we found it, remove it
                if labels{j} == binaryId
                    labels = labels([1:j-1 j+1:end]);
                    binaryId = [];
                    break;
                end
            end
            if ~isempty(binaryId)
                warning([mfilename ' : set_probabilities : sequence ' ...
                    binary ' not found.\nNo action taken'], 1);
            end
        end
        if ~isempty(labels)
            warning([mfilename ' : set_probabilities : was passed sequences ' ...
                    'that don''t make sense?\nNo action taken'], 1);
            disp(labels)
        end
        % --- end check

        for myId = 1:2^nSides
            binaryId = replace(replace(dec2bin(myId-1, nSides), '0', 'L'), '1', 'R');
            mySPH = eval(char("p" + binaryId));
            for j=1:rows(seqs)
                % if we found it, set it
                if seqs{j,1} == binaryId
                    mySPH.value = seqs{j,2};
                    break;
                end
            end
            % end this binaryId
        end
        x = ProbabilitiesSection(obj, 'normalize');
        
        
    case 'normalize'
        probs = zeros(2^nSides,1);
        % -- read all the probabilities from the SoloParamHandles
        probs = zeros(2^nSides, 1);
        for myId = 1:2^nSides
            binaryId = replace(replace(dec2bin(myId-1, nSides), '0', 'L'), '1', 'R');
            probs(myId) = value(eval(char("p" + binaryId)));
        end
        
        % --- normalize --- 
        nSequences = 2^nSides;
        probs(probs<0) = 0;        
        if sum(probs) == 0
            probs(:) = 1/nSequences;
        else
            probs = probs/sum(probs);
        end

        % --- set the SoloParamHandles
        for myId = 1:2^nSides
            binaryId = replace(replace(dec2bin(myId-1, nSides), '0', 'L'), '1', 'R');
            sph = eval(char("p" + binaryId));
            sph.value = probs(myId);
        end
        
        x = ProbabilitiesSection(obj, 'get_probabilities');
        
        
    % --- SHOW HIDE ---
        
    case 'hide'
        ProbabilitiesShow.value = 0; set(value(myfig), 'Visible', 'off');
        
    case 'show'
        ProbabilitiesShow.value = 1; set(value(myfig), 'Visible', 'on');
        
    case 'show_hide'
        if ProbabilitiesShow == 1, set(value(myfig), 'Visible', 'on');
        else                       set(value(myfig), 'Visible', 'off'); %#ok<SEPEX>
        end
        
        
        % --- REINIT ---

    case 'reinit_if_nSides_changed'
        if nSides ~= my_nSides
            ProbabilitiesSection(obj, 'reinit')
        end
        
    case 'reinit'        
        currfig = double(gcf);
        
        % Get the original GUI position and figure:
        x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        [x, y] = feval(mfilename, obj, 'init', x, y);
        
        % Restore the current figure:
        figure(currfig);
        
        % ------------------------------------------------------------------
        %              CLOSE
        % ------------------------------------------------------------------
    case 'close'
        if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig))
            myfignum = value(myfig);
        else
            myfignum = [];
        end
        delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);
        if ~isempty(myfignum), delete(myfignum); end
        
end

                




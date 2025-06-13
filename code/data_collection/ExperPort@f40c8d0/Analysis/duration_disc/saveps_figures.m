function [] = saveps_figures(varargin)
pairs = { ...
    'action', '' ; ...
    'pformat', 'fig'; ... % [ai | postscript | fig]
    'img_dir', '~/Documents/Neuro/brodylab/img_tmp' ; ...
    };
parse_knownargs(varargin,pairs);

formats = {};
formats.ai = {}; % Adobe Illustrator
formats.ai.fileext= '%s%s.ai';
formats.ai.popt = '-dill';

formats.postscript ={}; %EPS
formats.postscript.fileext = '%s%s.ps';
formats.postscript.popt = '-depsc';


figs = get(0,'Children');

if isempty(action),
    action=pformat;
end;

switch action
    case 'paper' % saves as fig file as well as ps file in 'graphics' directory
        img_dir = '~/Documents/Neuro/My_Papers/Brody_ACxlesions/graphics';
        saveps_figures('action', 'fig', 'img_dir', [img_dir filesep 'figs' filesep]);
        saveps_figures('action','postscript','pformat', 'postscript',...
            'img_dir',img_dir);
    
    case 'thesis' % saves as fig file as well as ps file in 'graphics' directory
        img_dir = '~/Documents/Neuro/brodylab/graphics';
        saveps_figures('action', 'fig', 'img_dir', [img_dir filesep 'figs' filesep]);
        saveps_figures('action','postscript','pformat', 'postscript',...
            'img_dir',[img_dir filesep 'eps' filesep]);

    case 'postscript'
        fstruct = eval(['formats.' pformat]);
        
        if ~strcmpi(img_dir(end), filesep), img_dir=[img_dir filesep]; end;

        for idx = 1:length(figs)
            currfig = figs(idx);
            t=get(findobj('Tag', 'figname','Parent',currfig),'String');
            if ~isempty(t)
                set(currfig,'PaperPositionMode','auto');
                fname = sprintf(fstruct.fileext, img_dir, t)
                % print('-dill', '-zbuffer', sprintf('-f%i',currfig), fname);
                print(fstruct.popt, sprintf('-f%i',currfig), fname);
            end;

        end;
        
    case 'ill'
        fstruct = eval(['formats.' pformat]);        
        if ~strcmpi(img_dir(end), filesep), img_dir=[img_dir filesep]; end;

        for idx = 1:length(figs)
            currfig = figs(idx);
            t=get(findobj('Tag', 'figname','Parent',currfig),'String');
            if ~isempty(t)
                set(currfig,'PaperPositionMode','auto');
                fname = sprintf(fstruct.fileext, img_dir, t)
                 print('-dill', sprintf('-f%i',currfig), fname);
                %print(fstruct.popt, sprintf('-f%i',currfig), fname);
            end;

        end;
        
    case 'fig'
        for idx = 1:length(figs)
            currfig = figs(idx);
            t=get(findobj('Tag', 'figname','Parent',currfig),'String');
            
            if ~isempty(t)
                set(currfig,'PaperPositionMode','auto');
                fname = [img_dir filesep t];
                % print('-dill', '-zbuffer', sprintf('-f%i',currfig), fname);
                saveas(currfig, fname, 'fig');
            end;
        end;

    otherwise
        error('invalid format');
end;

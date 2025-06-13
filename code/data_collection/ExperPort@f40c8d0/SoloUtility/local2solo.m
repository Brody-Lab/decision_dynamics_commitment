function varargout=local2solo(c_vars)
% function local2solo(a)


cols=ceil(numel(c_vars)/20);
rows=ceil(numel(c_vars)/cols);
bot=5;
x=bot;
tmcd=sprintf('x=5;y=5;boty=5;\n\n');
for xi=1:numel(c_vars)

    if strfind(lower(c_vars(xi).name), 'sound')
            mcd=sprintf('[x,y]=SoundInterface(obj, ''add'', ''%s'',x,y);\n', c_vars(xi).name);
            tmcd=[tmcd mcd];
        
    else
    switch c_vars(xi).class,
        case 'logical',
            mcd=sprintf('ToggleParam(obj, ''%s'', %i, x,y, ''OnString'', ''%s'', ''OffString'', ''%s'');\n',...
                c_vars(xi).name, evalin('caller', c_vars(xi).name),  ['Do ' c_vars(xi).name] , ['Do NOT ' c_vars(xi).name]);
            tmcd=[tmcd mcd];
        case 'cell',
            if min(c_vars(xi).size)~=1
                display('Can only handle 1D cell arrays')
                continue;
            end
            mcd=sprintf('MenuParam(obj, ''%s'', %s, 1, x, y, ''labelfraction'' , 0.65);\n',...
                c_vars(xi).name, feval('strFromCell',evalin('caller', c_vars(xi).name)));
            tmcd=[tmcd mcd];

        case 'double'
            if prod(c_vars(xi).size)==1
                mcd=sprintf('NumeditParam(obj, ''%s'', %i, x,y, ''labelfraction'' , 0.65);\n',...
                    c_vars(xi).name, evalin('caller', c_vars(xi).name));
                tmcd=[tmcd mcd];

            else
                mcd=sprintf('EditParam(obj, ''%s'', ''[%s]'', x,y, ''labelfraction'' , 0.65);\n',...
                    c_vars(xi).name, sprintf('%i ',evalin('caller', c_vars(xi).name)));
                tmcd=[tmcd mcd];

            end
        case 'char'
            mcd=sprintf('SubheaderParam(obj, ''%s'', ''%s'', x,y, ''labelfraction'' , 0.65);\n',...
                c_vars(xi).name, evalin('caller', c_vars(xi).name));
            tmcd=[tmcd mcd];


    end
    end
    if mod(xi,rows)==0
        mcd=sprintf('next_column(x); y=boty;\n\n');
        tmcd=[tmcd mcd];

    else
        mcd=sprintf('next_row(y);\n\n');
        tmcd=[tmcd mcd];

    end
end
clipboard('copy',tmcd);
if nargout==1
    varargout{1}=tmcd;
end
return;

cd(olddir);

function s=strFromCell(C)
s='{';
for xi=1:numel(C)
    if isstr(C{xi})
        st=['''' C{xi} ''''];
    else
        st=num2str(C{xi});
    end
    s=[s ' ' st];
end
s=[s '}'];




function ip = getRigIP(rigno)
    validateattributes(rigno,{'numeric'},{'positive','scalar','finite','integer'},'','rigno',1);
    riglist = bdata('select rigid from ratinfo.riginfo');
    if ismember(rigno,riglist)
        ip = bdata(['select ip_addr from ratinfo.riginfo where rigid=',num2str(rigno)]);
        ip=ip{:};
    else
        error('%g is not a recognized rig.',rigno);
    end
end
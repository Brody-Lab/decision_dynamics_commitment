function [] = check_tagname(lh1, tagname)

    if ~isfield(struct(lh1), tagname), error(['The lunghao1 doesn''t have a ' tagname ' tag']); end;

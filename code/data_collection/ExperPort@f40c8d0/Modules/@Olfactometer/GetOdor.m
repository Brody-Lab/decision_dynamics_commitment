function odorNum = GetOdor(olf, bankname)
    odorNum = str2num(DoQueryCmd(olf, sprintf('GET BANK ODOR %s', bankname)));
    
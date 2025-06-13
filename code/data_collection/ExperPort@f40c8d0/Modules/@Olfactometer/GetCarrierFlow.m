function flow = GetCarrierFlow(olf, mixname)

    flow = str2num(DoQueryCmd(olf, sprintf('GET ACTUAL CARRIER FLOW %s', mixname)));
    

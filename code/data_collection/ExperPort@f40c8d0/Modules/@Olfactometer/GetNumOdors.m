% returns the number of odors in a bank, pass in a bankname
function numOdors = GetNumOdors(olf, bankname)

    idx = GetBankIndex_INTERNAL(olf, bankname);
    numOdors = olf.banks{idx, 3};
    
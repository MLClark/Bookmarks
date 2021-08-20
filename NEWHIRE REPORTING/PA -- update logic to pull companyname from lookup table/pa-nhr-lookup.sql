select replace(value1,'-','') as lufein
from edi.lookup l
join edi.lookup_schema ls on l.lookupid = ls.lookupid and ls.lookupname = 'PA FEIN'

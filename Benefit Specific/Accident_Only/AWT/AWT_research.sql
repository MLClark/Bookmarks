select * from person_identity
where current_timestamp between createts and endts
  and personid = '8502'
  ;
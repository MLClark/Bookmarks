/*
CREATE SEQUENCE lid START 1;

INSERT INTO edi.lookup_schema 
(lookupid, keycoldesc1,keycoldesc2,valcoldesc1,lookupname, lookupdesc)
VALUES (1,'LOC_CODE','BENEFIT_PLAN','FIDELITY_PLAN_NAME','AWT_QBPLANS_LOOKUP','"keys=loc_code,benefit_plan values=fidelity_plan_name"');

SELECT * FROM edi.lookup_schema  where lookupname = 'AWT_QBPLANS_LOOKUP';

--delete from edi.lookup where id <> 3

INSERT INTO edi.lookup (id,lookupid,key1,key2,value1) VALUES (nextval('serial'),1,'400','HMO Blue NE Enhanced','BCBS MA Med HMO Blue NE Enhan Val EPOCH Sen Liv');
INSERT INTO edi.lookup (id,lookupid,key1,key2,value1) VALUES (nextval('serial'),1,'400','Blue Care Elect Preferred','BCBS MA Med PPO Blue Care Pref EPOCH Sen Liv');
INSERT INTO edi.lookup (id,lookupid,key1,key2,value1) VALUES (nextval('serial'),1,'400','Blue Care Elect Preferred','BCBS MA Med PPO Blue Care Pref EPOCH Sen Liv');

*/
INSERT INTO edi.lookup (id,lookupid,key1,key2,value1) VALUES (nextval('serial'),1,'400','Blue Care Elect Preferred','BCBS MA Med PPO Blue Care Pref EPOCH Sen Liv');
select * from edi.lookup;



--log on/of trigger
create table db_evnt_audit(
  user_name VARCHAR2(20),
  event_type VARCHAR2(20),
  logon_date date,
  logon_time VARCHAR2(20),
  logof_date date,
  logof_time VARCHAR2(20)
);

show user;

create or replace trigger db_lgoff_audit
before logoff on database
begin
  insert into db_evnt_audit values(
  user,
  ora_sysevent,
  null,
  null,
  sysdate,
  to_char(sysdate, 'hh24:mi:ss')
  );
  commit;
end;

create or replace trigger db_lgon_audit
after logon on database
begin
  insert into db_evnt_audit values(
  user,
  ora_sysevent,
  sysdate,
  to_char(sysdate, 'hh24:mi:ss'),
  null,
  null
  );
  commit;
end;

select * from db_evnt_audit;
TRUNCATE TABLE db_evnt_audit;


--startup trigger
create table startup_audit(
  event_type VARCHAR2(30),
  event_date DATE,
  event_time VARCHAR2(15)
);

CREATE OR REPLACE TRIGGER tr_startup_audit
AFTER STARTUP ON DATABASE
BEGIN
  INSERT INTO startup_audit(event_type, event_date,event_time)
  VALUES(
  ora_sysevent,
  SYSDATE,
  TO_CHAR(SYSDATE, 'hh24:mm:ss')
  );
END;
/



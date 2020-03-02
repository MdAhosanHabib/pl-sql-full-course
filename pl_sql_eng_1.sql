--variable
set serveroutput on;
declare
  v_test varchar2(15);
begin
  v_test := 'ahosan';
  dbms_output.put_line(v_test);
end;


--variable
set serveroutput on;
declare
  v_salary number(8);
  v_name varchar2(20);
begin
  select salary, first_name into v_salary, v_name from employees
  where employee_id = 100;
  dbms_output.put_line(v_name ||' has salary '||v_salary);
end;


--anchored data type
set serveroutput on;
declare
  v_name employees.first_name%type;
begin
  select first_name into v_name from employees
  where employee_id = 100;
  dbms_output.put_line(v_name);
end;


--constant
set serveroutput on;
declare
  v_pi constant number(8,6) := 32.141592;
begin
  dbms_output.put_line(v_pi);
end;


--bind variable
variable v_bind varchar2(10);
exec :v_bind := 'rakib';
set serveroutput on;
begin
  :v_bind := 'habib';
  dbms_output.put_line(:v_bind);
end;

print :v_bind;

set autoprint on;
variable v_bind1 varchar2(10);
exec :v_bind1 := 'munaa';



--if condition
set serveroutput on;
declare
  v_num number := 9;
begin
  if v_num < 10 then
    dbms_output.put_line('inside the if');
  end if;
    dbms_output.put_line('outside the if');
end;

--if then else
set serveroutput on;
declare
  v_num number := &enter_number;
begin
  if mod(v_num,2) = 0 then
    dbms_output.put_line(v_num||' is even');
  else
    dbms_output.put_line(v_num||' is odd');
  end if;
    dbms_output.put_line('if then else construction complete');
end;

--if then elsif
set serveroutput on;
declare
  v_place varchar2(30) := '&enter_place';
begin
  if v_place = 'mettro' then
  dbms_output.put_line('mettro is here');
  elsif v_place = 'amazon' then
  dbms_output.put_line('amazon is here');
  elsif v_place = 'goat' then
  dbms_output.put_line('goat is here');
  else
  dbms_output.put_line('al are end here');
  end if;
  dbms_output.put_line('Thanks');
end;




--simple loop
set serveroutput on;
declare
  v_counter number := 0;
  v_result number;
begin
  loop
    v_counter := v_counter + 1;
    v_result := 19 * v_counter;
    dbms_output.put_line('19'||' x '||v_counter||' = '||v_result);
    exit when v_counter >=10;
  end loop;
end;


--while loop
set serveroutput on;
declare
  v_counter number := 1;
  v_result number;
begin
  while v_counter <= 10 loop
    v_result := 19 * v_counter;
    dbms_output.put_line('19'||' x '||v_counter||' = '||v_result);
    v_counter := v_counter + 1;
  end loop;
  dbms_output.put_line('loop out');
end;


--for loop
set serveroutput on;
begin
  for v_counter in reverse 1 .. 10 loop
  dbms_output.put_line(v_counter);
  end loop;
end;


--dml trigger
create table superheroes(
 sh_name varchar2(20)
);

set serveroutput on;
create or replace trigger tr_superheroes
before insert or update or delete on superheroes
for EACH ROW
enable
DECLARE
  v_user varchar2(20);
begin
  select user into v_user from dual;
  if inserting then
  DBMS_OUTPUT.PUT_LINE('one row inserted by Mr. '||v_user);
  elsif deleting then
  DBMS_OUTPUT.PUT_LINE('one row is deleted by Mr. '||v_user);
  elsif updating then
  DBMS_OUTPUT.PUT_LINE('one row is updated by Mr. '||v_user);
  end if;
end;

insert into SUPERHEROES VALUES ('batman');
update SUPERHEROES set sh_name = 'superman' where sh_name='batman';
select sh_name from SUPERHEROES;
delete from superheroes where sh_name = 'superman';
select * from superheroes;

--trigger
create TABLE sh_audit(
  new_name varchar2(30),
  old_name varchar2(30),
  user_name varchar2(30),
  entry_date varchar2(30),
  operation varchar2(30)
);

create or replace trigger superheroes_audit
before insert or delete or update on superheroes
for each row
enable
declare
  v_user varchar2(30);
  v_date varchar2(30);
begin
select user, to_char(sysdate,'DD/MON/YYYY HH24:MI:SS') into v_user, v_date from dual;
if inserting then
insert into sh_audit(new_name, old_name, user_name, entry_date, operation)
values (:NEW.sh_name, NULL, v_user, v_date, 'INSERT');
elsif deleting then
insert into sh_audit(new_name, old_name, user_name, entry_date, operation)
values (NULL, :OLD.sh_name, v_user, v_date, 'DELETE');
elsif updating then
insert into sh_audit(new_name, old_name, user_name, entry_date, operation)
values (:NEW.sh_name, :OLD.sh_name, v_user, v_date, 'UPDATE');
end if;
end;

insert into superheroes values ('ahosan');
update superheroes set sh_name='habib' where sh_name='ahosan';
delete from superheroes where SH_NAME='habib';

select * from sh_audit;
select * from superheroes;

--synchronized backup copy of a table using dml trigger
create table superheroes_backup as select * from superheroes where 1=2;

create or replace trigger sh_backup
before insert or delete or update on superheroes
for each row
enable
begin
  if inserting then
  insert into superheroes_backup (sh_name) values (:NEW.sh_name);
  elsif deleting then
  delete from superheroes_backup where sh_name = :OLD.sh_name;
  elsif updating then
  update superheroes_backup set sh_name = :NEW.sh_name where sh_name = :old.sh_name;
  end if;
end;

insert into superheroes values ('ahosan');
insert into superheroes values ('habib');

select * from superheroes;
select * from superheroes_backup;
update superheroes set sh_name = 'rakib' where sh_name = 'habib';
delete from superheroes where sh_name = 'rakib';

--ddl trigger with schema auditing example
create table schema_audit(
  ddl_date date,
  ddl_user varchar2(20),
  object_created VARCHAR2(20),
  object_name VARCHAR2(20),
  ddl_operation VARCHAR2(20)
);

create or replace trigger hr_audit_tr
after ddl on schema
begin
  insert into schema_audit (ddl_date, ddl_user, object_created, object_name, ddl_operation) values (
  sysdate,
  sys_context('userenv', 'current_user'),
  ora_dict_obj_type,
  ora_dict_obj_name,
  ora_sysevent
  );
end;

select * from schema_audit;
create table ahosan (a_num NUMBER);
INSERT INTO AHOSAN VALUES (9);
TRUNCATE table ahosan;
drop TABLE ahosan;




--DB event trigger/ system event trigger 'logon'
create table hr_ent_audit(
  event_type VARCHAR2(20),
  logon_date date,
  logon_time VARCHAR2(20),
  logof_date date,
  logof_time VARCHAR2(20)
);

create or replace trigger hr_lgon_audit
after logon on schema
begin
  insert into hr_ent_audit values(
  ora_sysevent,
  sysdate,
  to_char(sysdate, 'hh24:mi:ss'),
  null,
  null
  );
  commit;
end;

select * from HR_ENT_AUDIT;
disc;
conn hr/hr;

create or replace trigger hr_lgoff_audit
before logoff on schema
begin
  insert into hr_ent_audit values(
  ora_sysevent,
  null,
  null,
  sysdate,
  to_char(sysdate, 'hh24:mi:ss')
  );
  commit;
end;

select * from HR_ENT_AUDIT;
disc;
conn hr/hr;
--login with sys user then done those task
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



--startup trigger (from sys)
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

--instead of trigger
CREATE TABLE trainer(
  full_name VARCHAR2(20)
);
CREATE TABLE subject(
  subject_name VARCHAR2(15)
);
INSERT INTO trainer VALUES ('ahosan');
INSERT INTO subject VALUES ('oracle');

CREATE VIEW vw_instead AS
SELECT full_name, subject_name FROM trainer, subject;

select * from vw_instead;

CREATE OR REPLACE TRIGGER tr_instead
INSTEAD OF INSERT ON vw_instead
FOR EACH ROW
BEGIN
  INSERT INTO trainer (full_name) VALUES (:NEW.full_name);
  INSERT INTO subject (subject_name) VALUES (:NEW.subject_name);
END;
/

INSERT INTO vw_instead VALUES ('rakib', 'php');

select * from trainer;
select * from subject;
select * from vw_instead;

--instead of update trigger
CREATE OR REPLACE TRIGGER io_update
INSTEAD OF UPDATE ON vw_instead
FOR EACH ROW
BEGIN
  UPDATE trainer SET full_name = :NEW.full_name WHERE full_name= :OLD.full_name;
  UPDATE subject SET subject_name = :NEW.subject_name WHERE subject_name= :OLD.subject_name;
END;
/

UPDATE vw_instead SET full_name = 'tony' WHERE full_name= 'rakib';
select * from vw_instead;

--instead of delete
CREATE OR REPLACE TRIGGER io_delete
INSTEAD OF DELETE ON vw_instead
FOR EACH ROW
BEGIN
  DELETE FROM trainer WHERE full_name= :OLD.full_name;
  DELETE FROM subject WHERE subject_name= :OLD.subject_name;
END;
/

DELETE FROM vw_instead WHERE full_name= 'tony';
select * from vw_instead;

--explicit cursor
SET SERVEROUTPUT ON;
DECLARE
  v_name VARCHAR2(30);
  
  CURSOR cur_ahosan IS 
  SELECT first_name FROM employees
  WHERE employee_id < 105;
BEGIN
  OPEN cur_ahosan;
  LOOP
  FETCH cur_ahosan INTO v_name;
  DBMS_OUTPUT.PUT_LINE(v_name);
  EXIT WHEN cur_ahosan%NOTFOUND;
  END LOOP;
  CLOSE cur_ahosan;
END;

--cursor parameter
SET SERVEROUTPUT ON;
DECLARE
  v_name VARCHAR2(30);
  CURSOR p_cur_ahosan (var_e_id VARCHAR2) IS
  SELECT first_name FROM employees
  WHERE employee_id < var_e_id;
BEGIN
  OPEN p_cur_ahosan(105);
  LOOP
  FETCH p_cur_ahosan INTO v_name;
  EXIT WHEN p_cur_ahosan%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE(v_name);
  END LOOP;
  CLOSE p_cur_ahosan;
END;
/

--create cursor parameter with default value
SET SERVEROUTPUT ON;
DECLARE
  v_name VARCHAR2(30);
  v_eid VARCHAR2(30);
  cursor cur_ahosan(var_e_id NUMBER := 190) IS
  SELECT first_name, employee_id FROM employees
  WHERE employee_id > var_e_id;
BEGIN
  OPEN cur_ahosan(200);
  LOOP
  FETCH cur_ahosan INTO v_name, v_eid;
  EXIT WHEN cur_ahosan%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE(v_name||' '||v_eid);
  END LOOP;
  CLOSE cur_ahosan;
END;
/

--cursor for loop
SET SERVEROUTPUT ON;
DECLARE
  CURSOR cur_ahosan IS
  SELECT first_name, last_name FROM employees
  WHERE employee_id > 200;
BEGIN
  FOR L_IDX IN cur_ahosan
  LOOP
  DBMS_OUTPUT.PUT_LINE(L_IDX.first_name||' '||L_IDX.last_name);
  END LOOP;
END;
/

--parameterized cursor for loop
SET SERVEROUTPUT ON;
DECLARE
  CURSOR cur_ahosan (var_e_id NUMBER) IS
  SELECT first_name, last_name FROM employees
  WHERE employee_id > var_e_id;
BEGIN
  FOR L_IDX IN cur_ahosan(200)
  LOOP
  DBMS_OUTPUT.PUT_LINE(L_IDX.first_name||' '||L_IDX.last_name);
  END LOOP;
END;
/

--table based record datatype 1
SET SERVEROUTPUT ON;
DECLARE
v_emp employees%ROWTYPE;
BEGIN
  SELECT * INTO v_emp FROM employees
  WHERE employee_id = 200;
  DBMS_OUTPUT.PUT_LINE(v_emp.first_name||' '||v_emp.salary);
  DBMS_OUTPUT.PUT_LINE(v_emp.hire_date);
END;
/

--table based record datatype 2
SET SERVEROUTPUT ON;
DECLARE
v_emp employees%ROWTYPE;
BEGIN
  SELECT first_name, hire_date INTO v_emp.first_name, v_emp.hire_date FROM employees
  WHERE employee_id = 100;
  DBMS_OUTPUT.PUT_LINE(v_emp.first_name);
  DBMS_OUTPUT.PUT_LINE(v_emp.hire_date);
END;
/

--cursor based record data type 1
SET SERVEROUTPUT ON;
DECLARE
  CURSOR cur_ahosan IS
  SELECT first_name, salary FROM employees
  WHERE employee_id = 100;
  
  var_emp cur_ahosan%ROWTYPE;
BEGIN
  OPEN cur_ahosan;
  FETCH cur_ahosan INTO var_emp;
  DBMS_OUTPUT.PUT_LINE(var_emp.first_name);
  DBMS_OUTPUT.PUT_LINE(var_emp.salary);
  CLOSE cur_ahosan;
END;
/

--cursor based record data type 2
SET SERVEROUTPUT ON;
DECLARE
  CURSOR cur_ahosan IS
  SELECT first_name, salary FROM employees
  WHERE employee_id > 200;
  
  var_emp cur_ahosan%ROWTYPE;
BEGIN
  OPEN cur_ahosan;
  LOOP
  FETCH cur_ahosan INTO var_emp;
  EXIT WHEN cur_ahosan%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE(var_emp.first_name||' '||var_emp.salary);
  END LOOP;
  CLOSE cur_ahosan;
END;
/

--user define record data type
SET SERVEROUTPUT ON;
DECLARE
  TYPE rv_dept IS RECORD(
    f_name VARCHAR2(20),
    d_name DEPARTMENTS.department_name%TYPE
  );

  var1 rv_dept;
  
BEGIN
  SELECT first_name, department_name INTO var1.f_name, var1.d_name
  FROM employees JOIN departments USING (department_id) WHERE employee_id = 100;
  DBMS_OUTPUT.PUT_LINE(var1.f_name||' '||var1.d_name);
END;
/




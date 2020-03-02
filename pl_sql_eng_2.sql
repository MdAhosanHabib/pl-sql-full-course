--function for calculating the area of a circle
CREATE OR REPLACE FUNCTION circle_area (radius NUMBER)
RETURN NUMBER IS

pi CONSTANT NUMBER (7,3) := 3.141;
area NUMBER (7,3);
BEGIN
  area := pi*(radius*radius);
  RETURN area;
END;
/

SET SERVEROUTPUT ON;
BEGIN
  DBMS_OUTPUT.PUT_LINE(circle_area(25));
END;
/

SET SERVEROUTPUT ON;
DECLARE
  vr_area NUMBER(7,3);
BEGIN
  vr_area := circle_area(25);
  DBMS_OUTPUT.PUT_LINE(vr_area);
END;
/

--stored procedure part1
CREATE OR REPLACE PROCEDURE pr_ahosan IS
  var_name VARCHAR2(20) := 'AHOSAN';
  var_web VARCHAR2(20) := 'ahosandev.com';
BEGIN
  DBMS_OUTPUT.PUT_LINE('whats up internet? I am '||var_name||' from '||var_web);
END pr_ahosan;
/

SET SERVEROUTPUT ON;
EXECUTE pr_ahosan;
EXEC pr_ahosan;

BEGIN
  pr_ahosan;
END;
/

--stored procedure part2
CREATE OR REPLACE PROCEDURE emp_sal (dep_id NUMBER, sal_raise NUMBER)
IS
BEGIN
  UPDATE employees SET salary = salary * sal_raise WHERE department_id = dep_id;
END;
/

--calling notation for subroutines procedure
--positional notation
CREATE OR REPLACE PROCEDURE emp_sal (dep_id NUMBER, sal_raise NUMBER)
IS
BEGIN
  UPDATE employees SET salary = salary * sal_raise WHERE department_id = dep_id;
  DBMS_OUTPUT.PUT_LINE('SALARY UPDATED');
END;
/

EXECUTE emp_sal(40,2);
--named notation
CREATE OR REPLACE FUNCTION add_num
(var_1 NUMBER, var_2 NUMBER DEFAULT 0, var_3 NUMBER) RETURN NUMBER
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE('var_1 -> '||var_1);
  DBMS_OUTPUT.PUT_LINE('var_2 -> '||var_2);
  DBMS_OUTPUT.PUT_LINE('var_3 -> '||var_3);
  RETURN var_1+var_2+var_3;
END;
/

DECLARE
  var_result NUMBER;
BEGIN
  var_result := add_num(var_3=>5, var_1=>2);
  DBMS_OUTPUT.PUT_LINE('RESULT -> '||var_result);
END;
/

--packages
CREATE TABLE exm_pkg(
 f_name VARCHAR2(20),
 l_name VARCHAR2(20)
);

CREATE OR REPLACE PACKAGE pkg_ahosan IS
FUNCTION print_string RETURN VARCHAR2;
PROCEDURE proc_exm_pkg (f_name VARCHAR2, l_name VARCHAR2);
END pkg_ahosan;
/

CREATE OR REPLACE PACKAGE BODY pkg_ahosan IS
  FUNCTION print_string RETURN VARCHAR2 IS
    BEGIN
    RETURN 'ahosandev.com';
    END print_string;
  PROCEDURE proc_exm_pkg (f_name VARCHAR2, l_name VARCHAR2) IS
    BEGIN
      INSERT INTO exm_pkg (f_name, l_name) VALUES (f_name, l_name);
    END;
END pkg_ahosan;
/

SET SERVEROUTPUT ON;
BEGIN
  DBMS_OUTPUT.PUT_LINE(pkg_ahosan.print_string);
END;
/

SELECT * FROM exm_pkg;

BEGIN
  pkg_ahosan.proc_exm_pkg('ahosan','habib');
END;
/

--exception handling --user-define exception using a EXCEPTION variable
DECLARE
   var_dividend NUMBER := 24;
   var_divisor NUMBER := 0;
   var_result NUMBER;
   ex_divzero EXCEPTION;
BEGIN
  IF var_divisor = 0 THEN
  RAISE ex_divzero;
  END IF;
  var_result := var_dividend/ var_divisor;
  DBMS_OUTPUT.PUT_LINE('RESULT = '||var_result);
  
  EXCEPTION WHEN ex_divzero THEN
  DBMS_OUTPUT.PUT_LINE('ERROR- YOUR DIVISOR IS ZERO!');
END;
/

--User-Define Exception using RAISE_APPLICATION_ERROR
ACCEPT var_age NUMBER PROMPT 'What is your age?';
DECLARE
age NUMBER := &var_age;
BEGIN
  IF age<18 THEN
  RAISE_APPLICATION_ERROR(-20008,'YOU SHOULD BE 18 OR AVOBE!');
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('SURE, WHAT WOULD YOU LIKE TO HAVE?');
  
  EXCEPTION WHEN others THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- user define exception using PRAGMA EXCEPTION_INIT
DECLARE
  ex_age EXCEPTION;
  age NUMBER := 17;
  PRAGMA EXCEPTION_INIT (ex_age, -20008);
BEGIN
  IF age<18 THEN
  RAISE_APPLICATION_ERROR(-20008,'YOU SHOULD BE 18 OR AVOBE!');
  END IF;
  
  DBMS_OUTPUT.PUT_LINE('SURE, WHAT WOULD YOU LIKE TO HAVE?');
  
  EXCEPTION WHEN ex_age THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

--pl/sql created nasted table collections
SET SERVEROUTPUT ON;
DECLARE
  TYPE my_nested_table IS TABLE OF number;
  var_nt my_nested_table := my_nested_table(9,8,7,56,3,4,5,2);
BEGIN
  FOR i IN 1..var_nt.count
  LOOP
    DBMS_OUTPUT.PUT_LINE('value stored in index is '||var_nt(i));
  END LOOP;
END;
/

--created nasted table collections as database object
SET SERVEROUTPUT ON;
CREATE OR REPLACE TYPE my_nested_table IS TABLE OF VARCHAR2(10);
/
CREATE TABLE mt_subject(
  sub_id NUMBER,
  sub_name VARCHAR2(10),
  sub_schedule_day my_nested_table
)NESTED TABLE sub_schedule_day STORE AS nested_tab_space;
/

DESC mt_subject;

INSERT INTO mt_subject (sub_id, sub_name, sub_schedule_day)
VALUES (101, 'CSE', my_nested_table('fri'));

INSERT INTO mt_subject (sub_id, sub_name, sub_schedule_day)
VALUES (102, 'EEE', my_nested_table('sun', 'mon'));

--created nested table using user define data type
SET SERVEROUTPUT ON;
CREATE OR REPLACE TYPE object_type AS OBJECT(
  obj_id NUMBER,
  obj_name VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE my_nt IS TABLE OF object_type;
/

CREATE TABLE base_table(
  tab_id NUMBER,
  tab_ele my_nt
) NESTED TABLE tab_ele STORE AS store_tab_1;
/

INSERT INTO base_table (tab_id, tab_ele) VALUES
(801, My_NT (object_type (1,'Superman'))
);

UPDATE base_table SET tab_ele = My_NT(object_type(1,'SpiderMan')) WHERE tab_id = 801;

Select tab_id, tab_ele FROM base_table;
SELECT * FROM TABLE(
  SELECT tab_ele FROM Base_Table WHERE tab_id = 801
);

--create varrays inside pl/sql block
SET SERVEROUTPUT ON;
DECLARE
  TYPE inBlock_vry IS VARRAY (5) OF NUMBER;
  vry_obj inBlock_vry := inBlock_vry();
BEGIN
  vry_obj.EXTEND(5);
  FOR i IN 1..vry_obj.LIMIT
  LOOP
    --vry_obj.EXTEND;
    vry_obj(i) := 10*i;
    DBMS_OUTPUT.PUT_LINE(vry_obj(i));
  END LOOP;
END;
/

--create varrays AS DATABASE OBJECT
SET SERVEROUTPUT ON;
CREATE OR REPLACE TYPE dbobj_vry IS VARRAY (5) OF NUMBER;
CREATE TABLE calender(
  day_name VARCHAR2(10),
  day_date dbobj_vry
);

INSERT INTO calender (day_name, day_date)
VALUES ('sunday', dbobj_vry(7,8,9,10));

SELECT * FROM calender;

SELECT 
  tab1.day_name,
  vry.column_value
FROM calender tab1, TABLE (tab1.day_date) vry;

--collection associative array
SET SERVEROUTPUT ON;
DECLARE
  TYPE books IS TABLE OF NUMBER
    INDEX BY VARCHAR2(20);
  isbn books;
  flag VARCHAR2(20);
BEGIN
  isbn('oracle database') := 1234;
  isbn('mysql') := 9876;
  --DBMS_OUTPUT.PUT_LINE('Value '||isbn('oracle database'));
  flag := isbn.FIRST;
  WHILE flag IS NOT NULL
  LOOP
  DBMS_OUTPUT.PUT_LINE('Key -> '||flag||', value -> '||isbn(flag));
  flag := isbn.NEXT(flag);
  END LOOP;
END;
/

--COLLECTIONS COUNT METHOD
SET SERVEROUTPUT ON;
DECLARE
  TYPE my_nested_table IS TABLE OF NUMBER;
  var_nt my_nested_table := my_nested_table(9,18,27,35,45,23,45,57,67,23,90);

BEGIN
  FOR i IN 1..var_nt.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE('Value stored at index '||i||' is '||var_nt(i));
  END LOOP;
END;
/

--collection method exist
SET SERVEROUTPUT ON;
DECLARE
  TYPE  my_nested_table IS TABLE OF VARCHAR2(20);
  col_var_1 my_nested_table := my_nested_table('superman', 'ironman', 'batman');
BEGIN
  IF col_var_1.EXISTS(4) THEN
    DBMS_OUTPUT.PUT_LINE('HEY WE FOUND '||col_var_1(4));
  ELSE
    DBMS_OUTPUT.PUT_LINE('THIS INDEX IS EMPTY. NEW DATA INSERTING.....');
    col_var_1.EXTEND;
    col_var_1(4) := 'SPIDERMAN';
  END IF;
  DBMS_OUTPUT.PUT_LINE('Value stored at index 4 is '||col_var_1(4));
END;
/

-- COLECTION METHOD FIRST & LAST
SET SERVEROUTPUT ON;
DECLARE
  TYPE nt_tab IS TABLE OF NUMBER;
  col_var nt_tab := nt_tab(10,20,30,40,50);
BEGIN
  DBMS_OUTPUT.PUT_LINE('FIRST INDEX IS '||col_var.FIRST);
  DBMS_OUTPUT.PUT_LINE('LAST INDEX IS '||col_var.LAST);
  
  Col_var.DELETE(1);
  DBMS_OUTPUT.PUT_LINE('FIRST INDEX AFTER DELETE IS '||col_var.FIRST);
  
  Col_var.TRIM;
  DBMS_OUTPUT.PUT_LINE('LAST INDEX AFTER TRIM IS '||col_var.LAST);
END;
/

--COLLECTION METHOD LIMIT (IT IS FOR ONLY VARRAY)
SET SERVEROUTPUT ON;
DECLARE
  TYPE inBlock_vry IS VARRAY (5) OF NUMBER;
  vry_obj inBlock_vry := inBlock_vry();
BEGIN
  vry_obj.EXTEND;
  vry_obj(1) := 10;
  DBMS_OUTPUT.PUT_LINE('TOTAL INDEXES IS '||vry_obj.LIMIT);
  DBMS_OUTPUT.PUT_LINE('RESULT OF FUNCTION COUNT IS '||vry_obj.COUNT);
END;
/

--COLLECTION METHOD PRIOR & NEXT
SET SERVEROUTPUT ON;
DECLARE
  TYPE my_nested_table IS TABLE OF NUMBER;
  var_nt my_nested_table := my_nested_table(9,18,27,35,45,23,45,57,67,23,90);

BEGIN
  DBMS_OUTPUT.PUT_LINE('INDEX BEFORE 3RD INDEX IS '||var_nt.PRIOR(3));
  DBMS_OUTPUT.PUT_LINE('VALUE BEFORE 3RD INDEX IS '||var_nt(var_nt.PRIOR(3)));
  
  DBMS_OUTPUT.PUT_LINE('NEXT HIGHER INDEX OF 3RD INDEX IS '||var_nt.NEXT(3));
  DBMS_OUTPUT.PUT_LINE('VALUE AFTER 3RD INDEX IS '||var_nt(var_nt.NEXT(3)));
END;
/

--COLLECTION METHOD DELETE
SET SERVEROUTPUT ON;
DECLARE
  TYPE my_nested_table IS TABLE OF NUMBER;
  var_nt my_nested_table := my_nested_table(9,18,27,35,45,23,45,57,67,23,90);

BEGIN
  var_nt.DELETE(2,6);
  FOR i IN 1..var_nt.LAST LOOP
    IF var_nt.EXISTS(i) THEN
    DBMS_OUTPUT.PUT_LINE('VALUE AT INDEX ['||i||'] IS '||var_nt(i));
    END IF;
  END LOOP;
END;
/

--COLLECTION METHOD EXTEND
SET SERVEROUTPUT ON;
DECLARE
  TYPE my_nested_table IS TABLE OF NUMBER;
  nt_obj my_nested_table := my_nested_table();
BEGIN
  nt_obj.EXTEND;
  nt_obj(1) := 28;
  DBMS_OUTPUT.PUT_LINE('DATA AT INDEX 1 IS '||nt_obj(1));
  nt_obj.EXTEND(5, 1);
  DBMS_OUTPUT.PUT_LINE('DATA AT INDEX 3 IS '||nt_obj(3));
  DBMS_OUTPUT.PUT_LINE('DATA AT INDEX 4 IS '||nt_obj(4));
END;
/

--COLLECTION METHOD TRIM
SET SERVEROUTPUT ON;
DECLARE
  TYPE my_nested_table IS TABLE OF NUMBER;
  nt_obj my_nested_table := my_nested_table(1,2,3,4,5);
BEGIN
  nt_obj.TRIM(2);
  FOR i IN 1..nt_obj.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE(nt_obj(i));
  END LOOP;
END;
/

--STRONG REF CURSORS
SET SERVEROUTPUT ON;
DECLARE
  TYPE my_refcur IS REF CURSOR RETURN employees%ROWTYPE;
  cur_var my_refcur;
  rec_var employees%ROWTYPE;
BEGIN
  OPEN cur_var FOR SELECT * FROM employees WHERE employee_id = 100;
  FETCH cur_var  INTO rec_var;
  CLOSE cur_var;
DBMS_OUTPUT.PUT_LINE('EMPLOYEE '||rec_var.first_name||' HAS SALARY '||rec_var.salary);
END;
/

-- STRONG REF CURSOR WITH USER DEFINED RECORD DATATYPE
SET SERVEROUTPUT ON;;
DECLARE
  TYPE my_rec IS RECORD(
    emp_sal employees.salary%TYPE
  );
  TYPE refcur IS REF CURSOR RETURN my_rec;
  cur_var refcur;
  at_var employees.salary%TYPE;
BEGIN
  OPEN cur_var FOR SELECT salary FROM employees WHERE employee_id = 100;
  FETCH cur_var INTO at_var;
  CLOSE cur_var;
  DBMS_OUTPUT.PUT_LINE('Salary of the employee is '||at_var);
END;
/

--weak ref cursor
SET SERVEROUTPUT ON;
DECLARE
  TYPE wk_refcur IS REF CURSOR;
  cur_var wk_refcur;
  
  f_name employees.first_name%TYPE;
  emp_sal employees.salary%TYPE;
BEGIN
  OPEN cur_var FOR SELECT first_name, salary FROM employees WHERE employee_id=100;
  FETCH cur_var INTO f_name, emp_sal;
  CLOSE cur_var;
  DBMS_OUTPUT.PUT_LINE(f_name||' '||emp_sal);
END;
/

--sys_ref cursor
SET SERVEROUTPUT ON;
DECLARE
  cur_var SYS_REFCURSOR;
  
  f_name employees.first_name%TYPE;
  emp_sal employees.salary%TYPE;
BEGIN
  OPEN cur_var FOR SELECT first_name, salary FROM employees WHERE employee_id=100;
  FETCH cur_var INTO f_name, emp_sal;
  CLOSE cur_var;
  DBMS_OUTPUT.PUT_LINE(f_name||' '||emp_sal);
END;
/

--BULK COLLECT select-into
SET SERVEROUTPUT ON;
DECLARE
  TYPE nt_fname IS TABLE OF VARCHAR2(20);
  fname nt_fname;
BEGIN
  SELECT first_name BULK COLLECT INTO fname
  FROM employees;
  
  FOR idx IN 1..fname.COUNT
  LOOP
    DBMS_OUTPUT.PUT_LINE(idx||' - '||fname(idx));
  END LOOP;
END;
/

-- BULK COLLECT FETCH-INTO
SET SERVEROUTPUT ON;
DECLARE
  CURSOR exp_cur IS
  SELECT first_name FROM employees;
  
  TYPE nt_fname IS TABLE OF VARCHAR2(20);
  fname nt_fname;
BEGIN
  OPEN exp_cur;
  LOOP
    FETCH exp_cur BULK COLLECT INTO fname;
    EXIT WHEN fname.COUNT = 0;
    
    FOR idx IN fname.FIRST..fname.LAST
    LOOP
      DBMS_OUTPUT.PUT_LINE(idx||' '||fname(idx));
    END LOOP;
  END LOOP;
  CLOSE exp_cur;
END;
/

--BULK COLLECT WITH LIMIT CLAUSE
SET SERVEROUTPUT ON;
DECLARE
  CURSOR exp_cur IS
  SELECT first_name FROM employees;
  
  TYPE nt_fname IS TABLE OF VARCHAR2(20);
  fname nt_fname;
BEGIN
  OPEN exp_cur;
  FETCH exp_cur BULK COLLECT INTO fname LIMIT 10;
  CLOSE exp_cur;
  FOR idx IN fname.FIRST..fname.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE(idx||' '||fname(idx));
  END LOOP;
END;
/

--FORALL LOWER & UPPER BOUND -BULK COLLECT
SET SERVEROUTPUT ON;
CREATE TABLE tut_77(
  mul_tab NUMBER(5)
);
DECLARE
  TYPE my_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  col_var my_array;
  tot_rec NUMBER;
BEGIN
  FOR i IN 1..10 LOOP
    col_var (i) := 9*i;
  END LOOP;
  
  FORALL idx IN 1..10
    INSERT INTO tut_77 (mul_tab)
    VALUES (col_var(idx));
  
  SELECT COUNT(*) INTO tot_rec FROM tut_77;
  DBMS_OUTPUT.PUT_LINE('Total records inserted are '||tot_rec);
END;
/

--FORALL statement with INDICES OF clause -bulk collection
SET SERVEROUTPUT ON;
CREATE TABLE tut_78(
  mul_tab NUMBER(5)
);
DECLARE
  TYPE my_nested_table IS TABLE OF NUMBER;
  var_nt my_nested_table := my_nested_table(9,18,27,36,46,55,34,23,42,89);
  
  tot_rec NUMBER;
BEGIN
  var_nt.DELETE(3,6);
  FORALL idx IN INDICES OF var_nt
  INSERT INTO tut_78(mul_tab) VALUES (var_nt(idx));
  
  SELECT COUNT(*) INTO tot_rec FROM tut_78;
  DBMS_OUTPUT.PUT_LINE('Total records inserted are '||tot_rec);
END;
/

--FORALL STATEMENT WITH IN VALUES OF CLAUSE
CREATE TABLE tut_79(
  select_data NUMBER(4)
);
SELECT * FROM tut_79;

SET SERVEROUTPUT ON;
DECLARE
  TYPE my_nested_table IS TABLE OF NUMBER;
  source_col my_nested_table := my_nested_table(9,18,27,36,46,55,34,23,42,89);
  
  TYPE my_array IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
  index_col my_array;
BEGIN
  index_col (1) := 3;
  index_col (5) := 7;
  index_col (12) := 8;
  index_col (28) := 10;
  FORALL idx IN VALUES OF index_col
    INSERT INTO tut_79 VALUES (SOURCE_COL(idx));
END;
/

--DYNAMIC SQL EXECUTE IIMEDIATE WITH INTO CLAUSE
SET SERVEROUTPUT ON;
DECLARE
  sql_qry VARCHAR2(150);
  emp_tot NUMBER(3);
BEGIN
  sql_qry := 'SELECT COUNT(*) FROM employees';
  EXECUTE IMMEDIATE sql_qry INTO emp_tot;
  DBMS_OUTPUT.PUT_LINE('Totall employees are: '||emp_tot);
END;
/

--Execute DDL statements with Execute Immediate Dynamic SQL
SET SERVEROUTPUT ON;
DECLARE
  ddl_qry VARCHAR2(150);
BEGIN
  ddl_qry := 'CREATE TABLE tut_82(
              tut_num NUMBER(3),
              tu_name VARCHAR2(50)
              )';
  EXECUTE IMMEDIATE ddl_qry;
END;
/

--Create Table with Execute Immediate of Native Dynamic SQL
SET SERVEROUTPUT ON;
DECLARE
  ddl_qry VARCHAR2(150);
BEGIN
  ddl_qry := 'CREATE TABLE tut_83('
              ||'tut_num NUMBER(3),'
              ||'tu_name VARCHAR2(50)'
              ||')';
  EXECUTE IMMEDIATE ddl_qry;
END;
/

--ALTER & DROP table DDL with Execute Immediate of Dynamic SQL
SET SERVEROUTPUT ON;
DECLARE
  ddl_qry VARCHAR2(50);
BEGIN
  ddl_qry := 'ALTER TABLE tut_83 ADD tut_date DATE';
  --ddl_qry := 'DROP TABLE tut_83';
  EXECUTE IMMEDIATE ddl_qry;
END;
/

--BIND VARIABLE WITH Execute Immediate OF Native Dynamic SQL
CREATE TABLE stu_info(
  student_name VARCHAR2(20)
);
INSERT INTO stu_info (student_name) VALUES (:stu_name);

SET SERVEROUTPUT ON;
DECLARE
  sql_smt VARCHAR2(150);
BEGIN
  sql_smt := 'INSERT INTO stu_info(student_name) VALUES (:stu_name)';
  EXECUTE IMMEDIATE sql_smt USING 'STEVE';
END;
/

--Multiple Bind Variable with Execute Immediate of Dynamic SQL
SET SERVEROUTPUT ON;
DECLARE
  sql_smt VARCHAR2(150);
BEGIN
  sql_smt := 'UPDATE stu_info SET student_name = :new_name
              WHERE student_name = :old_name';
  EXECUTE IMMEDIATE sql_smt USING 'STRANGE', 'STEVE';
END;
/

--Bulk Collect Into with Execute Immediate -dynamic sql
SET SERVEROUTPUT ON;
DECLARE
  TYPE nt_fname IS TABLE OF VARCHAR2(60);
  fname nt_fname;
  sql_qry VARCHAR2(150);
BEGIN
  sql_qry := 'SELECT first_name FROM employees';
  EXECUTE IMMEDIATE sql_qry BULK COLLECT INTO fname;
  FOR idx IN 1..fname.COUNT
    LOOP
      DBMS_OUTPUT.PUT_LINE(idx||' - '||fname(idx));
    END LOOP;
END;
/

--PL?SQL Block using Execute Immediate of Dynamic SQL
SET SERVEROUTPUT ON;
DECLARE
  plsql_blk VARCHAR2(250);
BEGIN
    plsql_blk := 'DECLARE
                    var_user VARCHAR2(10);
                  BEGIN
                    SELECT user INTO var_user FROM dual;
                    DBMS_OUTPUT.PUT_LINE(''Current user is ''||var_user);
                  END;';
    EXECUTE IMMEDIATE plsql_blk;
END;
/




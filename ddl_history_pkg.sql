CREATE OR REPLACE PACKAGE ddl_history_pkg AS
  
-- adds a new entry to the DDL history table
  PROCEDURE add_ddl_history(p_object_type VARCHAR2, p_object_name VARCHAR2);
  
  -- truncates historical records older than the specified number of days for the specified object
  PROCEDURE truncate_history(p_object_type VARCHAR2, p_object_name VARCHAR2, p_days NUMBER default null);
  
END ddl_history_pkg;
/


CREATE OR REPLACE PACKAGE BODY ddl_history_pkg AS

PROCEDURE add_ddl_history(p_object_type VARCHAR2, p_object_name VARCHAR2) IS
  l_ddl_text CLOB;
  l_database_name VARCHAR2(100);
  l_object_version NUMBER;
BEGIN
  -- retrieve the DDL for the specified object
  SELECT dbms_metadata.get_ddl(p_object_type, p_object_name)
    INTO l_ddl_text
    FROM dual;

  -- retrieve the current database name and replace symbols with underscores
  SELECT REPLACE(TRANSLATE(global_name, '!@#$%^&*()+=}{[]|\:;"<>,.?/~`-', '_____________________'), '_', '')
    INTO l_database_name
    FROM global_name;

  -- generate the object version
  SELECT count(*)+1
    INTO l_object_version
    FROM ddl_history
    WHERE object_type = p_object_type
    AND object_name = p_object_name;
    
  -- store the DDL in the ddl_history table
  INSERT INTO ddl_history (object_type, object_name, ddl_text, database_name, object_version) 
    VALUES (p_object_type, p_object_name, l_ddl_text, l_database_name, l_object_version);
	
	COMMIT;
END add_ddl_history;


  PROCEDURE truncate_history(p_object_type VARCHAR2, p_object_name VARCHAR2, p_days NUMBER DEFAULT NULL) IS
    l_date DATE;
  BEGIN
    -- if p_days is not specified, delete all records for the specified object type and name
    IF p_days IS NULL THEN
      DELETE FROM ddl_history 
        WHERE object_type = UPPER(p_object_type) 
        AND object_name = UPPER(p_object_name);
    ELSE
      -- calculate the date that is p_days days ago
      l_date := SYSDATE - p_days;
      
      -- delete all records for the specified object type and name that are older than l_date
      DELETE FROM ddl_history 
        WHERE object_type = UPPER(p_object_type) 
        AND object_name = UPPER(p_object_name) 
        AND created_at < l_date;
    END IF;
	
	COMMIT;
	
  END truncate_history;

END ddl_history_pkg;
/


CREATE TABLE ddl_history (
  id        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  object_type VARCHAR2(100),
  object_name VARCHAR2(100),
  ddl_text   CLOB,
  created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Файл 00_create_database.sql
-- Выполнить один раз в Query Tool, подключившись к служебной БД postgres.
-- После создания БД подключитесь к academic_schedule_db и выполните 01_schema_3NF_revised.sql.

CREATE DATABASE academic_schedule_db
    WITH
    ENCODING = 'UTF8'
    TEMPLATE = template0;

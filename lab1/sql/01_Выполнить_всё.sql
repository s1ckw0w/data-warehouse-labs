-- ЭКСПРЕСС-ЗАПУСК ЛАБОРАТОРНОЙ №1: DATA VAULT, PostgreSQL
-- ВАЖНО: перед выполнением подключитесь в pgAdmin к БД academic_schedule_dv.
-- Выполните этот файл целиком один раз. Затем выполните sql/04_checks.sql.


------------------------------------------------------------------------------
-- СОЗДАНИЕ СХЕМЫ И ТАБЛИЦ
------------------------------------------------------------------------------
-- ЛР №1. Data Vault 2.0 (учебная реализация), PostgreSQL. Вариант №6.
-- 01_schema.sql: запускать в НОВОЙ БД academic_schedule_dv.
-- Структура Raw Data Vault; существующую 3NF-базу не удаляет.
CREATE SCHEMA IF NOT EXISTS dv;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE OR REPLACE FUNCTION dv.hk(p_key TEXT) RETURNS CHAR(32)
LANGUAGE SQL IMMUTABLE STRICT AS $$ SELECT md5(upper(btrim(p_key))); $$;
CREATE OR REPLACE FUNCTION dv.hashdiff(VARIADIC p_items TEXT[]) RETURNS CHAR(32)
LANGUAGE SQL IMMUTABLE AS $$
  SELECT md5(array_to_string(ARRAY(SELECT COALESCE(x, '<NULL>') FROM unnest(p_items) x), E'\x1f'));
$$;

-- HUB: faculty (business key faculty_code)
CREATE TABLE dv.hub_faculty (
    faculty_hk CHAR(32) PRIMARY KEY,
    faculty_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of faculty
CREATE TABLE dv.sat_faculty (
    faculty_hk CHAR(32) NOT NULL REFERENCES dv.hub_faculty(faculty_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    faculty_name VARCHAR(200),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (faculty_hk, load_dts)
);
CREATE INDEX ix_sat_faculty_last ON dv.sat_faculty (faculty_hk, load_dts DESC);

-- HUB: department (business key department_code)
CREATE TABLE dv.hub_department (
    department_hk CHAR(32) PRIMARY KEY,
    department_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of department
CREATE TABLE dv.sat_department (
    department_hk CHAR(32) NOT NULL REFERENCES dv.hub_department(department_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    department_name VARCHAR(200),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (department_hk, load_dts)
);
CREATE INDEX ix_sat_department_last ON dv.sat_department (department_hk, load_dts DESC);

-- HUB: program (business key program_code)
CREATE TABLE dv.hub_program (
    program_hk CHAR(32) PRIMARY KEY,
    program_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of program
CREATE TABLE dv.sat_program (
    program_hk CHAR(32) NOT NULL REFERENCES dv.hub_program(program_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    program_name VARCHAR(200),
    study_level VARCHAR(50),
    study_form VARCHAR(50),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (program_hk, load_dts)
);
CREATE INDEX ix_sat_program_last ON dv.sat_program (program_hk, load_dts DESC);

-- HUB: teacher (business key teacher_code)
CREATE TABLE dv.hub_teacher (
    teacher_hk CHAR(32) PRIMARY KEY,
    teacher_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of teacher
CREATE TABLE dv.sat_teacher (
    teacher_hk CHAR(32) NOT NULL REFERENCES dv.hub_teacher(teacher_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    teacher_full_name VARCHAR(200),
    teacher_email VARCHAR(254),
    teacher_position VARCHAR(100),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (teacher_hk, load_dts)
);
CREATE INDEX ix_sat_teacher_last ON dv.sat_teacher (teacher_hk, load_dts DESC);

-- HUB: discipline (business key discipline_code)
CREATE TABLE dv.hub_discipline (
    discipline_hk CHAR(32) PRIMARY KEY,
    discipline_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of discipline
CREATE TABLE dv.sat_discipline (
    discipline_hk CHAR(32) NOT NULL REFERENCES dv.hub_discipline(discipline_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    discipline_name VARCHAR(200),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (discipline_hk, load_dts)
);
CREATE INDEX ix_sat_discipline_last ON dv.sat_discipline (discipline_hk, load_dts DESC);

-- HUB: study_plan (business key plan_code)
CREATE TABLE dv.hub_study_plan (
    study_plan_hk CHAR(32) PRIMARY KEY,
    plan_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of study_plan
CREATE TABLE dv.sat_study_plan (
    study_plan_hk CHAR(32) NOT NULL REFERENCES dv.hub_study_plan(study_plan_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    plan_version SMALLINT,
    approved_on DATE,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (study_plan_hk, load_dts)
);
CREATE INDEX ix_sat_study_plan_last ON dv.sat_study_plan (study_plan_hk, load_dts DESC);

-- HUB: study_group (business key group_code)
CREATE TABLE dv.hub_study_group (
    study_group_hk CHAR(32) PRIMARY KEY,
    group_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of study_group
CREATE TABLE dv.sat_study_group (
    study_group_hk CHAR(32) NOT NULL REFERENCES dv.hub_study_group(study_group_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    admission_year SMALLINT,
    student_count INTEGER,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (study_group_hk, load_dts)
);
CREATE INDEX ix_sat_study_group_last ON dv.sat_study_group (study_group_hk, load_dts DESC);

-- HUB: semester (business key semester_code)
CREATE TABLE dv.hub_semester (
    semester_hk CHAR(32) PRIMARY KEY,
    semester_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of semester
CREATE TABLE dv.sat_semester (
    semester_hk CHAR(32) NOT NULL REFERENCES dv.hub_semester(semester_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    academic_year VARCHAR(20),
    semester_number SMALLINT,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (semester_hk, load_dts)
);
CREATE INDEX ix_sat_semester_last ON dv.sat_semester (semester_hk, load_dts DESC);

-- HUB: classroom (business key classroom_code)
CREATE TABLE dv.hub_classroom (
    classroom_hk CHAR(32) PRIMARY KEY,
    classroom_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of classroom
CREATE TABLE dv.sat_classroom (
    classroom_hk CHAR(32) NOT NULL REFERENCES dv.hub_classroom(classroom_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    building VARCHAR(100),
    room_number VARCHAR(20),
    capacity INTEGER,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (classroom_hk, load_dts)
);
CREATE INDEX ix_sat_classroom_last ON dv.sat_classroom (classroom_hk, load_dts DESC);

-- HUB: lesson_type (business key lesson_type_code)
CREATE TABLE dv.hub_lesson_type (
    lesson_type_hk CHAR(32) PRIMARY KEY,
    lesson_type_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of lesson_type
CREATE TABLE dv.sat_lesson_type (
    lesson_type_hk CHAR(32) NOT NULL REFERENCES dv.hub_lesson_type(lesson_type_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    lesson_type_name VARCHAR(100),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (lesson_type_hk, load_dts)
);
CREATE INDEX ix_sat_lesson_type_last ON dv.sat_lesson_type (lesson_type_hk, load_dts DESC);

-- HUB: schedule (business key schedule_code)
CREATE TABLE dv.hub_schedule (
    schedule_hk CHAR(32) PRIMARY KEY,
    schedule_code VARCHAR(100) NOT NULL UNIQUE,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL
);

-- SATELLITE: description/history of schedule
CREATE TABLE dv.sat_schedule (
    schedule_hk CHAR(32) NOT NULL REFERENCES dv.hub_schedule(schedule_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    weekday SMALLINT,
    start_time TIME,
    end_time TIME,
    week_parity VARCHAR(10),
    notes TEXT,
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (schedule_hk, load_dts)
);
CREATE INDEX ix_sat_schedule_last ON dv.sat_schedule (schedule_hk, load_dts DESC);

-- LINK: department_faculty
CREATE TABLE dv.lnk_department_faculty (
    department_faculty_hk CHAR(32) PRIMARY KEY,
    department_hk CHAR(32) NOT NULL REFERENCES dv.hub_department(department_hk),
    faculty_hk CHAR(32) NOT NULL REFERENCES dv.hub_faculty(faculty_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (department_hk, faculty_hk)
);

-- LINK: program_department
CREATE TABLE dv.lnk_program_department (
    program_department_hk CHAR(32) PRIMARY KEY,
    program_hk CHAR(32) NOT NULL REFERENCES dv.hub_program(program_hk),
    department_hk CHAR(32) NOT NULL REFERENCES dv.hub_department(department_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (program_hk, department_hk)
);

-- LINK: teacher_department
CREATE TABLE dv.lnk_teacher_department (
    teacher_department_hk CHAR(32) PRIMARY KEY,
    teacher_hk CHAR(32) NOT NULL REFERENCES dv.hub_teacher(teacher_hk),
    department_hk CHAR(32) NOT NULL REFERENCES dv.hub_department(department_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (teacher_hk, department_hk)
);

-- LINK: plan_program
CREATE TABLE dv.lnk_plan_program (
    plan_program_hk CHAR(32) PRIMARY KEY,
    study_plan_hk CHAR(32) NOT NULL REFERENCES dv.hub_study_plan(study_plan_hk),
    program_hk CHAR(32) NOT NULL REFERENCES dv.hub_program(program_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (study_plan_hk, program_hk)
);

-- LINK: group_plan
CREATE TABLE dv.lnk_group_plan (
    group_plan_hk CHAR(32) PRIMARY KEY,
    study_group_hk CHAR(32) NOT NULL REFERENCES dv.hub_study_group(study_group_hk),
    study_plan_hk CHAR(32) NOT NULL REFERENCES dv.hub_study_plan(study_plan_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (study_group_hk, study_plan_hk)
);

-- LINK: plan_discipline
CREATE TABLE dv.lnk_plan_discipline (
    plan_discipline_hk CHAR(32) PRIMARY KEY,
    study_plan_hk CHAR(32) NOT NULL REFERENCES dv.hub_study_plan(study_plan_hk),
    discipline_hk CHAR(32) NOT NULL REFERENCES dv.hub_discipline(discipline_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (study_plan_hk, discipline_hk)
);

-- LINK: schedule_assignment
CREATE TABLE dv.lnk_schedule_assignment (
    schedule_assignment_hk CHAR(32) PRIMARY KEY,
    schedule_hk CHAR(32) NOT NULL REFERENCES dv.hub_schedule(schedule_hk),
    study_group_hk CHAR(32) NOT NULL REFERENCES dv.hub_study_group(study_group_hk),
    discipline_hk CHAR(32) NOT NULL REFERENCES dv.hub_discipline(discipline_hk),
    teacher_hk CHAR(32) NOT NULL REFERENCES dv.hub_teacher(teacher_hk),
    semester_hk CHAR(32) NOT NULL REFERENCES dv.hub_semester(semester_hk),
    classroom_hk CHAR(32) NOT NULL REFERENCES dv.hub_classroom(classroom_hk),
    lesson_type_hk CHAR(32) NOT NULL REFERENCES dv.hub_lesson_type(lesson_type_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    UNIQUE (schedule_hk, study_group_hk, discipline_hk, teacher_hk, semester_hk, classroom_hk, lesson_type_hk)
);

-- История нагрузки и контроля в учебном плане хранится в satellite связи.
CREATE TABLE dv.sat_plan_discipline (
    plan_discipline_hk CHAR(32) NOT NULL REFERENCES dv.lnk_plan_discipline(plan_discipline_hk),
    load_dts TIMESTAMPTZ NOT NULL,
    hashdiff CHAR(32) NOT NULL,
    course_number SMALLINT,
    planned_semester SMALLINT,
    lecture_hours INTEGER,
    laboratory_hours INTEGER,
    credits NUMERIC(4,1),
    assessment_type VARCHAR(50),
    record_source VARCHAR(50) NOT NULL,
    PRIMARY KEY (plan_discipline_hk, load_dts)
);

-- Учебная staging-таблица: плоские снимки данных из одного источника.
CREATE TABLE stg.timetable_snapshot (
    batch_id VARCHAR(25) NOT NULL,
    load_dts TIMESTAMPTZ NOT NULL,
    record_source VARCHAR(50) NOT NULL,
    faculty_code VARCHAR(100) NOT NULL,
    faculty_name VARCHAR(200),
    department_code VARCHAR(100) NOT NULL,
    department_name VARCHAR(200),
    program_code VARCHAR(100) NOT NULL,
    program_name VARCHAR(200),
    study_level VARCHAR(50),
    study_form VARCHAR(50),
    teacher_code VARCHAR(100) NOT NULL,
    teacher_full_name VARCHAR(200),
    teacher_email VARCHAR(254),
    teacher_position VARCHAR(100),
    discipline_code VARCHAR(100) NOT NULL,
    discipline_name VARCHAR(200),
    plan_code VARCHAR(100) NOT NULL,
    plan_version SMALLINT,
    approved_on DATE,
    group_code VARCHAR(100) NOT NULL,
    admission_year SMALLINT,
    student_count INTEGER,
    semester_code VARCHAR(100) NOT NULL,
    academic_year VARCHAR(20),
    semester_number SMALLINT,
    classroom_code VARCHAR(100) NOT NULL,
    building VARCHAR(100),
    room_number VARCHAR(20),
    capacity INTEGER,
    lesson_type_code VARCHAR(100) NOT NULL,
    lesson_type_name VARCHAR(100),
    schedule_code VARCHAR(100) NOT NULL,
    weekday SMALLINT,
    start_time TIME,
    end_time TIME,
    week_parity VARCHAR(10),
    notes TEXT,
    course_number SMALLINT,
    planned_semester SMALLINT,
    lecture_hours INTEGER,
    laboratory_hours INTEGER,
    credits NUMERIC(4,1),
    assessment_type VARCHAR(50),
    PRIMARY KEY (batch_id, schedule_code)
);

-- Business-facing SQL view: текущие атрибуты из Raw Vault.
CREATE OR REPLACE VIEW dv.v_schedule_current AS
SELECT
    hs.schedule_code,
    hg.group_code,
    hd.discipline_code,
    sd.discipline_name,
    ht.teacher_code,
    st.teacher_full_name,
    st.teacher_email,
    hse.semester_code,
    hc.classroom_code,
    sc.building,
    sc.room_number,
    hlt.lesson_type_code,
    slt.lesson_type_name,
    ss.weekday, ss.start_time, ss.end_time, ss.week_parity, ss.notes
FROM dv.lnk_schedule_assignment l
JOIN dv.hub_schedule hs ON hs.schedule_hk = l.schedule_hk
JOIN dv.hub_study_group hg ON hg.study_group_hk = l.study_group_hk
JOIN dv.hub_discipline hd ON hd.discipline_hk = l.discipline_hk
JOIN dv.hub_teacher ht ON ht.teacher_hk = l.teacher_hk
JOIN dv.hub_semester hse ON hse.semester_hk = l.semester_hk
JOIN dv.hub_classroom hc ON hc.classroom_hk = l.classroom_hk
JOIN dv.hub_lesson_type hlt ON hlt.lesson_type_hk = l.lesson_type_hk
JOIN LATERAL (
    SELECT weekday, start_time, end_time, week_parity, notes
    FROM dv.sat_schedule x WHERE x.schedule_hk = hs.schedule_hk
    ORDER BY load_dts DESC LIMIT 1
) ss ON TRUE
JOIN LATERAL (
    SELECT teacher_full_name, teacher_email
    FROM dv.sat_teacher x WHERE x.teacher_hk = ht.teacher_hk
    ORDER BY load_dts DESC LIMIT 1
) st ON TRUE
JOIN LATERAL (
    SELECT discipline_name FROM dv.sat_discipline x
    WHERE x.discipline_hk = hd.discipline_hk
    ORDER BY load_dts DESC LIMIT 1
) sd ON TRUE
JOIN LATERAL (
    SELECT building, room_number FROM dv.sat_classroom x
    WHERE x.classroom_hk = hc.classroom_hk
    ORDER BY load_dts DESC LIMIT 1
) sc ON TRUE
JOIN LATERAL (
    SELECT lesson_type_name FROM dv.sat_lesson_type x
    WHERE x.lesson_type_hk = hlt.lesson_type_hk
    ORDER BY load_dts DESC LIMIT 1
) slt ON TRUE;

CREATE OR REPLACE VIEW dv.v_plan_current AS
SELECT hp.plan_code, hd.discipline_code, sd.discipline_name,
       p.course_number, p.planned_semester, p.lecture_hours,
       p.laboratory_hours, p.credits, p.assessment_type
FROM dv.lnk_plan_discipline l
JOIN dv.hub_study_plan hp ON hp.study_plan_hk = l.study_plan_hk
JOIN dv.hub_discipline hd ON hd.discipline_hk = l.discipline_hk
JOIN LATERAL (
  SELECT course_number, planned_semester, lecture_hours,
         laboratory_hours, credits, assessment_type
  FROM dv.sat_plan_discipline x WHERE x.plan_discipline_hk = l.plan_discipline_hk
  ORDER BY load_dts DESC LIMIT 1
) p ON TRUE
JOIN LATERAL (
  SELECT discipline_name FROM dv.sat_discipline x WHERE x.discipline_hk=hd.discipline_hk
  ORDER BY load_dts DESC LIMIT 1
) sd ON TRUE;



------------------------------------------------------------------------------
-- ПРОЦЕДУРА ЗАГРУЗКИ
------------------------------------------------------------------------------
-- 02_load_batch.sql: ETL загрузка одной staging-партии в Raw Data Vault.
-- Используется snapshot entity per batch; повторный запуск той же партии безопасен.
CREATE OR REPLACE PROCEDURE dv.load_batch(p_batch VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
  -- HUB faculty
  INSERT INTO dv.hub_faculty (faculty_hk, faculty_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(faculty_code)) dv.hk(faculty_code), faculty_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(faculty_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB department
  INSERT INTO dv.hub_department (department_hk, department_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(department_code)) dv.hk(department_code), department_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(department_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB program
  INSERT INTO dv.hub_program (program_hk, program_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(program_code)) dv.hk(program_code), program_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(program_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB teacher
  INSERT INTO dv.hub_teacher (teacher_hk, teacher_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(teacher_code)) dv.hk(teacher_code), teacher_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(teacher_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB discipline
  INSERT INTO dv.hub_discipline (discipline_hk, discipline_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(discipline_code)) dv.hk(discipline_code), discipline_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(discipline_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB study_plan
  INSERT INTO dv.hub_study_plan (study_plan_hk, plan_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(plan_code)) dv.hk(plan_code), plan_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(plan_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB study_group
  INSERT INTO dv.hub_study_group (study_group_hk, group_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(group_code)) dv.hk(group_code), group_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(group_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB semester
  INSERT INTO dv.hub_semester (semester_hk, semester_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(semester_code)) dv.hk(semester_code), semester_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(semester_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB classroom
  INSERT INTO dv.hub_classroom (classroom_hk, classroom_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(classroom_code)) dv.hk(classroom_code), classroom_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(classroom_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB lesson_type
  INSERT INTO dv.hub_lesson_type (lesson_type_hk, lesson_type_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(lesson_type_code)) dv.hk(lesson_type_code), lesson_type_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(lesson_type_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- HUB schedule
  INSERT INTO dv.hub_schedule (schedule_hk, schedule_code, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk(schedule_code)) dv.hk(schedule_code), schedule_code, load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk(schedule_code), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- LINK department_faculty
  INSERT INTO dv.lnk_department_faculty (department_faculty_hk, department_hk, faculty_hk, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk('LNK_DEPARTMENT_FACULTY|' || dv.hk(department_code) || '|' || dv.hk(faculty_code))) dv.hk('LNK_DEPARTMENT_FACULTY|' || dv.hk(department_code) || '|' || dv.hk(faculty_code)), dv.hk(department_code), dv.hk(faculty_code), load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk('LNK_DEPARTMENT_FACULTY|' || dv.hk(department_code) || '|' || dv.hk(faculty_code)), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- LINK program_department
  INSERT INTO dv.lnk_program_department (program_department_hk, program_hk, department_hk, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk('LNK_PROGRAM_DEPARTMENT|' || dv.hk(program_code) || '|' || dv.hk(department_code))) dv.hk('LNK_PROGRAM_DEPARTMENT|' || dv.hk(program_code) || '|' || dv.hk(department_code)), dv.hk(program_code), dv.hk(department_code), load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk('LNK_PROGRAM_DEPARTMENT|' || dv.hk(program_code) || '|' || dv.hk(department_code)), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- LINK teacher_department
  INSERT INTO dv.lnk_teacher_department (teacher_department_hk, teacher_hk, department_hk, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk('LNK_TEACHER_DEPARTMENT|' || dv.hk(teacher_code) || '|' || dv.hk(department_code))) dv.hk('LNK_TEACHER_DEPARTMENT|' || dv.hk(teacher_code) || '|' || dv.hk(department_code)), dv.hk(teacher_code), dv.hk(department_code), load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk('LNK_TEACHER_DEPARTMENT|' || dv.hk(teacher_code) || '|' || dv.hk(department_code)), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- LINK plan_program
  INSERT INTO dv.lnk_plan_program (plan_program_hk, study_plan_hk, program_hk, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk('LNK_PLAN_PROGRAM|' || dv.hk(plan_code) || '|' || dv.hk(program_code))) dv.hk('LNK_PLAN_PROGRAM|' || dv.hk(plan_code) || '|' || dv.hk(program_code)), dv.hk(plan_code), dv.hk(program_code), load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk('LNK_PLAN_PROGRAM|' || dv.hk(plan_code) || '|' || dv.hk(program_code)), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- LINK group_plan
  INSERT INTO dv.lnk_group_plan (group_plan_hk, study_group_hk, study_plan_hk, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk('LNK_GROUP_PLAN|' || dv.hk(group_code) || '|' || dv.hk(plan_code))) dv.hk('LNK_GROUP_PLAN|' || dv.hk(group_code) || '|' || dv.hk(plan_code)), dv.hk(group_code), dv.hk(plan_code), load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk('LNK_GROUP_PLAN|' || dv.hk(group_code) || '|' || dv.hk(plan_code)), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- LINK plan_discipline
  INSERT INTO dv.lnk_plan_discipline (plan_discipline_hk, study_plan_hk, discipline_hk, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk('LNK_PLAN_DISCIPLINE|' || dv.hk(plan_code) || '|' || dv.hk(discipline_code))) dv.hk('LNK_PLAN_DISCIPLINE|' || dv.hk(plan_code) || '|' || dv.hk(discipline_code)), dv.hk(plan_code), dv.hk(discipline_code), load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk('LNK_PLAN_DISCIPLINE|' || dv.hk(plan_code) || '|' || dv.hk(discipline_code)), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- LINK schedule_assignment
  INSERT INTO dv.lnk_schedule_assignment (schedule_assignment_hk, schedule_hk, study_group_hk, discipline_hk, teacher_hk, semester_hk, classroom_hk, lesson_type_hk, load_dts, record_source)
  SELECT DISTINCT ON (dv.hk('LNK_SCHEDULE_ASSIGNMENT|' || dv.hk(schedule_code) || '|' || dv.hk(group_code) || '|' || dv.hk(discipline_code) || '|' || dv.hk(teacher_code) || '|' || dv.hk(semester_code) || '|' || dv.hk(classroom_code) || '|' || dv.hk(lesson_type_code))) dv.hk('LNK_SCHEDULE_ASSIGNMENT|' || dv.hk(schedule_code) || '|' || dv.hk(group_code) || '|' || dv.hk(discipline_code) || '|' || dv.hk(teacher_code) || '|' || dv.hk(semester_code) || '|' || dv.hk(classroom_code) || '|' || dv.hk(lesson_type_code)), dv.hk(schedule_code), dv.hk(group_code), dv.hk(discipline_code), dv.hk(teacher_code), dv.hk(semester_code), dv.hk(classroom_code), dv.hk(lesson_type_code), load_dts, record_source
  FROM stg.timetable_snapshot WHERE batch_id = p_batch
  ORDER BY dv.hk('LNK_SCHEDULE_ASSIGNMENT|' || dv.hk(schedule_code) || '|' || dv.hk(group_code) || '|' || dv.hk(discipline_code) || '|' || dv.hk(teacher_code) || '|' || dv.hk(semester_code) || '|' || dv.hk(classroom_code) || '|' || dv.hk(lesson_type_code)), load_dts DESC, schedule_code DESC
  ON CONFLICT DO NOTHING;

  -- SATELLITE faculty (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(faculty_code))
      dv.hk(faculty_code) AS item_hk, load_dts, record_source, dv.hashdiff(faculty_name::TEXT) AS hashdiff,
      faculty_name
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(faculty_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_faculty s
      WHERE s.faculty_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_faculty (faculty_hk, load_dts, hashdiff, faculty_name, record_source)
  SELECT item_hk, load_dts, hashdiff, faculty_name, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE department (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(department_code))
      dv.hk(department_code) AS item_hk, load_dts, record_source, dv.hashdiff(department_name::TEXT) AS hashdiff,
      department_name
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(department_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_department s
      WHERE s.department_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_department (department_hk, load_dts, hashdiff, department_name, record_source)
  SELECT item_hk, load_dts, hashdiff, department_name, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE program (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(program_code))
      dv.hk(program_code) AS item_hk, load_dts, record_source, dv.hashdiff(program_name::TEXT, study_level::TEXT, study_form::TEXT) AS hashdiff,
      program_name, study_level, study_form
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(program_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_program s
      WHERE s.program_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_program (program_hk, load_dts, hashdiff, program_name, study_level, study_form, record_source)
  SELECT item_hk, load_dts, hashdiff, program_name, study_level, study_form, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE teacher (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(teacher_code))
      dv.hk(teacher_code) AS item_hk, load_dts, record_source, dv.hashdiff(teacher_full_name::TEXT, teacher_email::TEXT, teacher_position::TEXT) AS hashdiff,
      teacher_full_name, teacher_email, teacher_position
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(teacher_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_teacher s
      WHERE s.teacher_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_teacher (teacher_hk, load_dts, hashdiff, teacher_full_name, teacher_email, teacher_position, record_source)
  SELECT item_hk, load_dts, hashdiff, teacher_full_name, teacher_email, teacher_position, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE discipline (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(discipline_code))
      dv.hk(discipline_code) AS item_hk, load_dts, record_source, dv.hashdiff(discipline_name::TEXT) AS hashdiff,
      discipline_name
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(discipline_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_discipline s
      WHERE s.discipline_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_discipline (discipline_hk, load_dts, hashdiff, discipline_name, record_source)
  SELECT item_hk, load_dts, hashdiff, discipline_name, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE study_plan (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(plan_code))
      dv.hk(plan_code) AS item_hk, load_dts, record_source, dv.hashdiff(plan_version::TEXT, approved_on::TEXT) AS hashdiff,
      plan_version, approved_on
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(plan_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_study_plan s
      WHERE s.study_plan_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_study_plan (study_plan_hk, load_dts, hashdiff, plan_version, approved_on, record_source)
  SELECT item_hk, load_dts, hashdiff, plan_version, approved_on, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE study_group (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(group_code))
      dv.hk(group_code) AS item_hk, load_dts, record_source, dv.hashdiff(admission_year::TEXT, student_count::TEXT) AS hashdiff,
      admission_year, student_count
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(group_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_study_group s
      WHERE s.study_group_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_study_group (study_group_hk, load_dts, hashdiff, admission_year, student_count, record_source)
  SELECT item_hk, load_dts, hashdiff, admission_year, student_count, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE semester (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(semester_code))
      dv.hk(semester_code) AS item_hk, load_dts, record_source, dv.hashdiff(academic_year::TEXT, semester_number::TEXT) AS hashdiff,
      academic_year, semester_number
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(semester_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_semester s
      WHERE s.semester_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_semester (semester_hk, load_dts, hashdiff, academic_year, semester_number, record_source)
  SELECT item_hk, load_dts, hashdiff, academic_year, semester_number, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE classroom (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(classroom_code))
      dv.hk(classroom_code) AS item_hk, load_dts, record_source, dv.hashdiff(building::TEXT, room_number::TEXT, capacity::TEXT) AS hashdiff,
      building, room_number, capacity
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(classroom_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_classroom s
      WHERE s.classroom_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_classroom (classroom_hk, load_dts, hashdiff, building, room_number, capacity, record_source)
  SELECT item_hk, load_dts, hashdiff, building, room_number, capacity, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE lesson_type (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(lesson_type_code))
      dv.hk(lesson_type_code) AS item_hk, load_dts, record_source, dv.hashdiff(lesson_type_name::TEXT) AS hashdiff,
      lesson_type_name
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(lesson_type_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_lesson_type s
      WHERE s.lesson_type_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_lesson_type (lesson_type_hk, load_dts, hashdiff, lesson_type_name, record_source)
  SELECT item_hk, load_dts, hashdiff, lesson_type_name, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE schedule (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk(schedule_code))
      dv.hk(schedule_code) AS item_hk, load_dts, record_source, dv.hashdiff(weekday::TEXT, start_time::TEXT, end_time::TEXT, week_parity::TEXT, notes::TEXT) AS hashdiff,
      weekday, start_time, end_time, week_parity, notes
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk(schedule_code), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_schedule s
      WHERE s.schedule_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_schedule (schedule_hk, load_dts, hashdiff, weekday, start_time, end_time, week_parity, notes, record_source)
  SELECT item_hk, load_dts, hashdiff, weekday, start_time, end_time, week_parity, notes, record_source FROM changed
  ON CONFLICT DO NOTHING;

  -- SATELLITE plan_discipline (вставляем только изменившийся набор атрибутов)
  WITH dedup AS (
    SELECT DISTINCT ON (dv.hk('LNK_PLAN_DISCIPLINE|' || dv.hk(plan_code) || '|' || dv.hk(discipline_code)))
      dv.hk('LNK_PLAN_DISCIPLINE|' || dv.hk(plan_code) || '|' || dv.hk(discipline_code)) AS item_hk, load_dts, record_source, dv.hashdiff(course_number::TEXT, planned_semester::TEXT, lecture_hours::TEXT, laboratory_hours::TEXT, credits::TEXT, assessment_type::TEXT) AS hashdiff,
      course_number, planned_semester, lecture_hours, laboratory_hours, credits, assessment_type
    FROM stg.timetable_snapshot WHERE batch_id = p_batch
    ORDER BY dv.hk('LNK_PLAN_DISCIPLINE|' || dv.hk(plan_code) || '|' || dv.hk(discipline_code)), load_dts DESC, schedule_code DESC
  ), changed AS (
    SELECT d.* FROM dedup d
    LEFT JOIN LATERAL (
      SELECT s.hashdiff FROM dv.sat_plan_discipline s
      WHERE s.plan_discipline_hk = d.item_hk ORDER BY s.load_dts DESC LIMIT 1
    ) last_sat ON TRUE
    WHERE last_sat.hashdiff IS DISTINCT FROM d.hashdiff
  )
  INSERT INTO dv.sat_plan_discipline (plan_discipline_hk, load_dts, hashdiff, course_number, planned_semester, lecture_hours, laboratory_hours, credits, assessment_type, record_source)
  SELECT item_hk, load_dts, hashdiff, course_number, planned_semester, lecture_hours, laboratory_hours, credits, assessment_type, record_source FROM changed
  ON CONFLICT DO NOTHING;

END;
$$;



------------------------------------------------------------------------------
-- ТЕСТОВЫЕ ДАННЫЕ И ДВЕ ПАРТИИ
------------------------------------------------------------------------------
-- 03_demo_data.sql: вымышленные учебные данные. Запускать после 01 и 02.
-- B1 = первоначальный снимок. B2 = новое состояние email одного преподавателя.
INSERT INTO stg.timetable_snapshot (
   batch_id, load_dts, record_source, faculty_code, faculty_name, department_code, department_name, program_code, program_name, study_level, study_form, teacher_code, teacher_full_name, teacher_email, teacher_position, discipline_code, discipline_name, plan_code, plan_version, approved_on, group_code, admission_year, student_count, semester_code, academic_year, semester_number, classroom_code, building, room_number, capacity, lesson_type_code, lesson_type_name, schedule_code, weekday, start_time, end_time, week_parity, notes, course_number, planned_semester, lecture_hours, laboratory_hours, credits, assessment_type
) VALUES
('B1', TIMESTAMPTZ '2026-10-23 09:00:00+00', 'DEMO_STUDENT', 'FIT', 'Факультет информационных технологий', 'IT', 'Кафедра информационных технологий', '09.03.04', 'Программная инженерия', 'бакалавриат', 'очная', 'T-001', 'Иванов Алексей Сергеевич', 'a.ivanov@example.edu', 'доцент', 'DB-101', 'Базы данных', 'PI-2026', 1, DATE '2026-06-30', '223-321', 2023, 24, '2026-S1', '2026/2027', 1, 'A-305', 'Главный корпус', '305', 30, 'LEC', 'Лекция', 'S-001', 2, TIME '10:00:00', TIME '11:30:00', 'EVERY', 'Учебная демонстрация', 4, 1, 32, 16, 3.0, 'Экзамен'),
('B1', TIMESTAMPTZ '2026-10-23 09:00:00+00', 'DEMO_STUDENT', 'FIT', 'Факультет информационных технологий', 'IT', 'Кафедра информационных технологий', '09.03.04', 'Программная инженерия', 'бакалавриат', 'очная', 'T-001', 'Иванов Алексей Сергеевич', 'a.ivanov@example.edu', 'доцент', 'DB-101', 'Базы данных', 'PI-2026', 1, DATE '2026-06-30', '223-321', 2023, 24, '2026-S1', '2026/2027', 1, 'A-305', 'Главный корпус', '305', 30, 'LEC', 'Лекция', 'S-002', 4, TIME '12:00:00', TIME '13:30:00', 'EVERY', 'Повторное занятие', 4, 1, 32, 16, 3.0, 'Экзамен'),
('B1', TIMESTAMPTZ '2026-10-23 09:00:00+00', 'DEMO_STUDENT', 'FIT', 'Факультет информационных технологий', 'IT', 'Кафедра информационных технологий', '09.03.04', 'Программная инженерия', 'бакалавриат', 'очная', 'T-002', 'Петрова Анна Игоревна', 'a.petrova@example.edu', 'старший преподаватель', 'DW-201', 'Хранилища данных', 'PI-2026', 1, DATE '2026-06-30', '223-321', 2023, 24, '2026-S1', '2026/2027', 1, 'A-306', 'Главный корпус', '306', 30, 'LAB', 'Лабораторная работа', 'S-003', 3, TIME '14:00:00', TIME '15:30:00', 'EVERY', 'Учебная демонстрация', 4, 1, 16, 32, 3.0, 'Зачёт'),
('B1', TIMESTAMPTZ '2026-10-23 09:00:00+00', 'DEMO_STUDENT', 'FIT', 'Факультет информационных технологий', 'IT', 'Кафедра информационных технологий', '09.03.04', 'Программная инженерия', 'бакалавриат', 'очная', 'T-001', 'Иванов Алексей Сергеевич', 'a.ivanov@example.edu', 'доцент', 'DB-101', 'Базы данных', 'PI-2026', 1, DATE '2026-06-30', '223-322', 2023, 21, '2026-S1', '2026/2027', 1, 'A-305', 'Главный корпус', '305', 30, 'LEC', 'Лекция', 'S-004', 5, TIME '09:00:00', TIME '10:30:00', 'EVERY', 'Учебная демонстрация', 4, 1, 32, 16, 3.0, 'Экзамен');
CALL dv.load_batch('B1');

-- Историзация: второй снимок обновляет email T-001; старый satellite остаётся.
INSERT INTO stg.timetable_snapshot (
   batch_id, load_dts, record_source, faculty_code, faculty_name, department_code, department_name, program_code, program_name, study_level, study_form, teacher_code, teacher_full_name, teacher_email, teacher_position, discipline_code, discipline_name, plan_code, plan_version, approved_on, group_code, admission_year, student_count, semester_code, academic_year, semester_number, classroom_code, building, room_number, capacity, lesson_type_code, lesson_type_name, schedule_code, weekday, start_time, end_time, week_parity, notes, course_number, planned_semester, lecture_hours, laboratory_hours, credits, assessment_type
) VALUES
('B2', TIMESTAMPTZ '2026-10-23 09:30:00+00', 'DEMO_STUDENT', 'FIT', 'Факультет информационных технологий', 'IT', 'Кафедра информационных технологий', '09.03.04', 'Программная инженерия', 'бакалавриат', 'очная', 'T-001', 'Иванов Алексей Сергеевич', 'ivanov.new@example.edu', 'доцент', 'DB-101', 'Базы данных', 'PI-2026', 1, DATE '2026-06-30', '223-321', 2023, 24, '2026-S1', '2026/2027', 1, 'A-305', 'Главный корпус', '305', 30, 'LEC', 'Лекция', 'S-001', 2, TIME '10:00:00', TIME '11:30:00', 'EVERY', 'Учебная демонстрация', 4, 1, 32, 16, 3.0, 'Экзамен');
CALL dv.load_batch('B2');


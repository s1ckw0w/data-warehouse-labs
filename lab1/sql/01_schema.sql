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

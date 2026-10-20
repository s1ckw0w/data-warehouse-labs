-- Лабораторная работа № 1
-- Вариант: «Система составления учебного графика дисциплин, изучаемых на факультете»
-- СУБД: PostgreSQL
--
-- Порядок запуска:
-- 1. Создать БД с помощью 00_create_database.sql.
-- 2. Подключиться к academic_schedule_db.
-- 3. Выполнить этот файл целиком.
--
-- Модель построена в третьей нормальной форме (3NF).
-- Справочные сведения вынесены в отдельные таблицы, чтобы не дублировать их
-- в расписании и учебных планах.

-- 1. Факультеты
CREATE TABLE faculties (
    faculty_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_code VARCHAR(20)  NOT NULL UNIQUE,
    faculty_name VARCHAR(200) NOT NULL UNIQUE
);

-- 2. Кафедры факультетов
CREATE TABLE departments (
    department_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    faculty_id      BIGINT       NOT NULL REFERENCES faculties(faculty_id),
    department_code VARCHAR(20)  NOT NULL,
    department_name VARCHAR(200) NOT NULL,
    CONSTRAINT uq_department_code_per_faculty UNIQUE (faculty_id, department_code),
    CONSTRAINT uq_department_name_per_faculty UNIQUE (faculty_id, department_name)
);

-- 3. Образовательные программы
CREATE TABLE education_programs (
    program_id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id       BIGINT       NOT NULL REFERENCES departments(department_id),
    program_code        VARCHAR(30)  NOT NULL UNIQUE,
    program_name        VARCHAR(200) NOT NULL,
    qualification_level VARCHAR(30) NOT NULL
        CHECK (qualification_level IN ('бакалавриат', 'специалитет', 'магистратура', 'аспирантура')),
    study_form          VARCHAR(30) NOT NULL
        CHECK (study_form IN ('очная', 'очно-заочная', 'заочная')),
    CONSTRAINT uq_program_name_per_department UNIQUE (department_id, program_name)
);

-- 4. Преподаватели
CREATE TABLE teachers (
    teacher_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_id  BIGINT       NOT NULL REFERENCES departments(department_id),
    last_name      VARCHAR(100) NOT NULL,
    first_name     VARCHAR(100) NOT NULL,
    middle_name    VARCHAR(100),
    email          VARCHAR(254) UNIQUE,
    academic_degree VARCHAR(100),
    position       VARCHAR(100),
    CONSTRAINT chk_teacher_last_name_not_empty CHECK (BTRIM(last_name) <> ''),
    CONSTRAINT chk_teacher_first_name_not_empty CHECK (BTRIM(first_name) <> '')
);

-- 5. Дисциплины
CREATE TABLE disciplines (
    discipline_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    discipline_code VARCHAR(30)  NOT NULL UNIQUE,
    discipline_name VARCHAR(200) NOT NULL UNIQUE,
    description     TEXT
);

-- 6. Виды контроля знаний
CREATE TABLE assessment_types (
    assessment_type_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    assessment_type_name VARCHAR(100) NOT NULL UNIQUE
);

-- 7. Учебные планы образовательных программ
CREATE TABLE study_plans (
    study_plan_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    program_id    BIGINT       NOT NULL REFERENCES education_programs(program_id),
    plan_code     VARCHAR(40)  NOT NULL UNIQUE,
    version_number INTEGER     NOT NULL CHECK (version_number > 0),
    approved_on   DATE,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_study_plan_version UNIQUE (program_id, version_number)
);

-- 8. Учебные группы. Учебный план определяет образовательную программу группы.
CREATE TABLE study_groups (
    group_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    study_plan_id  BIGINT      NOT NULL REFERENCES study_plans(study_plan_id),
    group_code     VARCHAR(30) NOT NULL UNIQUE,
    admission_year SMALLINT    NOT NULL CHECK (admission_year BETWEEN 2000 AND 2100),
    student_count  INTEGER     NOT NULL DEFAULT 0 CHECK (student_count >= 0)
);

-- 9. Учебные годы
CREATE TABLE academic_years (
    academic_year_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    start_year       SMALLINT NOT NULL,
    end_year         SMALLINT NOT NULL,
    CONSTRAINT chk_academic_year_range CHECK (end_year = start_year + 1),
    CONSTRAINT uq_academic_year_start UNIQUE (start_year)
);

-- 10. Семестры конкретного учебного года
CREATE TABLE semesters (
    semester_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    academic_year_id BIGINT NOT NULL REFERENCES academic_years(academic_year_id),
    semester_number  SMALLINT NOT NULL CHECK (semester_number IN (1, 2)),
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    CONSTRAINT chk_semester_dates CHECK (start_date <= end_date),
    CONSTRAINT uq_semester_per_year UNIQUE (academic_year_id, semester_number)
);

-- 11. Дисциплины в учебном плане.
-- Общая трудоёмкость отдельно не хранится, а рассчитывается в представлении,
-- чтобы не дублировать значение, выводимое из отдельных видов часов.
CREATE TABLE study_plan_disciplines (
    plan_discipline_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    study_plan_id      BIGINT NOT NULL REFERENCES study_plans(study_plan_id),
    discipline_id      BIGINT NOT NULL REFERENCES disciplines(discipline_id),
    course_number      SMALLINT NOT NULL CHECK (course_number BETWEEN 1 AND 6),
    semester_number    SMALLINT NOT NULL CHECK (semester_number IN (1, 2)),
    lecture_hours      INTEGER NOT NULL DEFAULT 0 CHECK (lecture_hours >= 0),
    practical_hours    INTEGER NOT NULL DEFAULT 0 CHECK (practical_hours >= 0),
    laboratory_hours   INTEGER NOT NULL DEFAULT 0 CHECK (laboratory_hours >= 0),
    independent_hours  INTEGER NOT NULL DEFAULT 0 CHECK (independent_hours >= 0),
    credits            NUMERIC(4,1) NOT NULL DEFAULT 0 CHECK (credits >= 0),
    assessment_type_id BIGINT NOT NULL REFERENCES assessment_types(assessment_type_id),
    CONSTRAINT uq_plan_discipline_term
        UNIQUE (study_plan_id, discipline_id, course_number, semester_number)
);

-- 12. Аудитории
CREATE TABLE classrooms (
    classroom_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    building     VARCHAR(100) NOT NULL,
    room_number  VARCHAR(20)  NOT NULL,
    capacity     INTEGER      NOT NULL CHECK (capacity > 0),
    room_type    VARCHAR(30)  NOT NULL
        CHECK (room_type IN ('аудитория', 'лекционная', 'лаборатория', 'компьютерный класс', 'другое')),
    CONSTRAINT uq_classroom_location UNIQUE (building, room_number)
);

-- 13. Типы занятий
CREATE TABLE lesson_types (
    lesson_type_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lesson_type_name VARCHAR(100) NOT NULL UNIQUE
);

-- 14. Расписание занятий.
-- weekday: 1 = понедельник, ..., 7 = воскресенье.
-- week_parity: EVERY = каждую неделю, ODD = нечётная, EVEN = чётная.
-- Плановая дисциплина задаётся через study_plan_disciplines, чтобы расписание
-- не могло ссылаться на дисциплину вне учебного плана группы.
CREATE TABLE schedule_entries (
    schedule_entry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id          BIGINT NOT NULL REFERENCES study_groups(group_id),
    plan_discipline_id BIGINT NOT NULL
        REFERENCES study_plan_disciplines(plan_discipline_id),
    teacher_id        BIGINT NOT NULL REFERENCES teachers(teacher_id),
    semester_id       BIGINT NOT NULL REFERENCES semesters(semester_id),
    classroom_id      BIGINT NOT NULL REFERENCES classrooms(classroom_id),
    lesson_type_id    BIGINT NOT NULL REFERENCES lesson_types(lesson_type_id),
    weekday           SMALLINT NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    start_time        TIME NOT NULL,
    end_time          TIME NOT NULL,
    week_parity       VARCHAR(10) NOT NULL DEFAULT 'EVERY'
        CHECK (week_parity IN ('EVERY', 'ODD', 'EVEN')),
    notes             TEXT,
    CONSTRAINT chk_lesson_time CHECK (start_time < end_time)
);

-- Проверка согласованности расписания:
-- дисциплина должна входить в учебный план группы, а номер семестра в плане
-- должен соответствовать семестру записи расписания.
CREATE OR REPLACE FUNCTION validate_schedule_entry()
RETURNS TRIGGER AS $$
DECLARE
    v_group_plan_id BIGINT;
    v_discipline_plan_id BIGINT;
    v_planned_semester SMALLINT;
    v_actual_semester SMALLINT;
BEGIN
    SELECT study_plan_id
      INTO v_group_plan_id
      FROM study_groups
     WHERE group_id = NEW.group_id;

    SELECT study_plan_id, semester_number
      INTO v_discipline_plan_id, v_planned_semester
      FROM study_plan_disciplines
     WHERE plan_discipline_id = NEW.plan_discipline_id;

    SELECT semester_number
      INTO v_actual_semester
      FROM semesters
     WHERE semester_id = NEW.semester_id;

    IF v_group_plan_id IS DISTINCT FROM v_discipline_plan_id THEN
        RAISE EXCEPTION 'Дисциплина не входит в учебный план выбранной группы.';
    END IF;

    IF v_planned_semester IS DISTINCT FROM v_actual_semester THEN
        RAISE EXCEPTION 'Семестр расписания не соответствует семестру дисциплины в учебном плане.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_schedule_entry
BEFORE INSERT OR UPDATE ON schedule_entries
FOR EACH ROW
EXECUTE FUNCTION validate_schedule_entry();

-- Индексы для часто используемых соединений и поиска расписания.
CREATE INDEX idx_departments_faculty
    ON departments(faculty_id);

CREATE INDEX idx_programs_department
    ON education_programs(department_id);

CREATE INDEX idx_teachers_department
    ON teachers(department_id);

CREATE INDEX idx_study_groups_plan
    ON study_groups(study_plan_id);

CREATE INDEX idx_plan_disciplines_plan
    ON study_plan_disciplines(study_plan_id);

CREATE INDEX idx_plan_disciplines_discipline
    ON study_plan_disciplines(discipline_id);

CREATE INDEX idx_semesters_academic_year
    ON semesters(academic_year_id);

CREATE INDEX idx_schedule_group_semester_time
    ON schedule_entries(group_id, semester_id, weekday, start_time);

CREATE INDEX idx_schedule_teacher_semester_time
    ON schedule_entries(teacher_id, semester_id, weekday, start_time);

CREATE INDEX idx_schedule_classroom_semester_time
    ON schedule_entries(classroom_id, semester_id, weekday, start_time);

CREATE INDEX idx_schedule_discipline_semester
    ON schedule_entries(plan_discipline_id, semester_id);

-- Представление: учебный план с рассчитанной общей трудоёмкостью.
CREATE VIEW v_study_plan_disciplines AS
SELECT
    sp.plan_code,
    ep.program_code,
    ep.program_name,
    d.discipline_code,
    d.discipline_name,
    spd.course_number,
    spd.semester_number,
    spd.lecture_hours,
    spd.practical_hours,
    spd.laboratory_hours,
    spd.independent_hours,
    (spd.lecture_hours + spd.practical_hours
        + spd.laboratory_hours + spd.independent_hours) AS total_hours,
    spd.credits,
    at.assessment_type_name
FROM study_plan_disciplines AS spd
JOIN study_plans AS sp
    ON sp.study_plan_id = spd.study_plan_id
JOIN education_programs AS ep
    ON ep.program_id = sp.program_id
JOIN disciplines AS d
    ON d.discipline_id = spd.discipline_id
JOIN assessment_types AS at
    ON at.assessment_type_id = spd.assessment_type_id;

-- Представление: расписание в удобном для просмотра виде.
CREATE VIEW v_schedule AS
SELECT
    (ay.start_year::TEXT || '/' || ay.end_year::TEXT) AS academic_year,
    s.semester_number,
    sg.group_code,
    d.discipline_name,
    lt.lesson_type_name,
    CONCAT_WS(' ', t.last_name, t.first_name, t.middle_name) AS teacher_full_name,
    c.building,
    c.room_number,
    se.weekday,
    se.start_time,
    se.end_time,
    se.week_parity,
    se.notes
FROM schedule_entries AS se
JOIN study_groups AS sg
    ON sg.group_id = se.group_id
JOIN study_plan_disciplines AS spd
    ON spd.plan_discipline_id = se.plan_discipline_id
JOIN disciplines AS d
    ON d.discipline_id = spd.discipline_id
JOIN teachers AS t
    ON t.teacher_id = se.teacher_id
JOIN semesters AS s
    ON s.semester_id = se.semester_id
JOIN academic_years AS ay
    ON ay.academic_year_id = s.academic_year_id
JOIN classrooms AS c
    ON c.classroom_id = se.classroom_id
JOIN lesson_types AS lt
    ON lt.lesson_type_id = se.lesson_type_id;

-- Примеры запросов для проверки после добавления данных:
-- SELECT * FROM v_study_plan_disciplines ORDER BY plan_code, course_number, semester_number;
-- SELECT * FROM v_schedule ORDER BY academic_year, semester_number, weekday, start_time;

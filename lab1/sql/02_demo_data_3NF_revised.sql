-- Файл 02_demo_data.sql
-- Необязательный демонстрационный набор данных для проверки структуры.
-- Данные вымышлены. Выполнять после 01_schema.sql в БД academic_schedule_db.

INSERT INTO faculties (faculty_code, faculty_name)
VALUES ('FIT', 'Факультет информационных технологий');

INSERT INTO departments (faculty_id, department_code, department_name)
SELECT faculty_id, 'IT', 'Кафедра информационных технологий'
FROM faculties WHERE faculty_code = 'FIT';

INSERT INTO education_programs
    (department_id, program_code, program_name, qualification_level, study_form)
SELECT department_id, '09.03.04', 'Программная инженерия', 'бакалавриат', 'очная'
FROM departments WHERE department_code = 'IT';

INSERT INTO teachers
    (department_id, last_name, first_name, middle_name, email, academic_degree, position)
SELECT department_id, 'Иванов', 'Алексей', 'Сергеевич',
       'a.ivanov@example.edu', 'кандидат технических наук', 'доцент'
FROM departments WHERE department_code = 'IT';

INSERT INTO disciplines (discipline_code, discipline_name, description)
VALUES ('DB-101', 'Базы данных', 'Основы проектирования и использования баз данных');

INSERT INTO assessment_types (assessment_type_name)
VALUES ('Экзамен'), ('Зачёт'), ('Дифференцированный зачёт');

INSERT INTO study_plans (program_id, plan_code, version_number, approved_on, is_active)
SELECT program_id, 'PI-2026', 1, DATE '2026-06-30', TRUE
FROM education_programs WHERE program_code = '09.03.04';

INSERT INTO study_groups (study_plan_id, group_code, admission_year, student_count)
SELECT study_plan_id, 'ПИ-223', 2023, 24
FROM study_plans WHERE plan_code = 'PI-2026';

INSERT INTO academic_years (start_year, end_year)
VALUES (2026, 2027);

INSERT INTO semesters (academic_year_id, semester_number, start_date, end_date)
SELECT academic_year_id, 1, DATE '2026-09-01', DATE '2027-01-25'
FROM academic_years WHERE start_year = 2026 AND end_year = 2027;

INSERT INTO study_plan_disciplines
    (study_plan_id, discipline_id, course_number, semester_number,
     lecture_hours, practical_hours, laboratory_hours, independent_hours,
     credits, assessment_type_id)
SELECT sp.study_plan_id, d.discipline_id, 4, 1, 32, 16, 16, 40, 3.0, at.assessment_type_id
FROM study_plans AS sp
JOIN disciplines AS d ON d.discipline_code = 'DB-101'
JOIN assessment_types AS at ON at.assessment_type_name = 'Экзамен'
WHERE sp.plan_code = 'PI-2026';

INSERT INTO classrooms (building, room_number, capacity, room_type)
VALUES ('Главный корпус', '305', 30, 'компьютерный класс');

INSERT INTO lesson_types (lesson_type_name)
VALUES ('Лекция'), ('Практическое занятие'), ('Лабораторная работа');

INSERT INTO schedule_entries
    (group_id, plan_discipline_id, teacher_id, semester_id, classroom_id, lesson_type_id,
     weekday, start_time, end_time, week_parity, notes)
SELECT
    sg.group_id,
    spd.plan_discipline_id,
    t.teacher_id,
    s.semester_id,
    c.classroom_id,
    lt.lesson_type_id,
    2,
    TIME '10:00',
    TIME '11:30',
    'EVERY',
    'Демонстрационная запись расписания'
FROM study_groups AS sg
JOIN study_plans AS sp ON sp.study_plan_id = sg.study_plan_id
JOIN study_plan_disciplines AS spd ON spd.study_plan_id = sp.study_plan_id
JOIN disciplines AS d ON d.discipline_id = spd.discipline_id
JOIN teachers AS t ON t.email = 'a.ivanov@example.edu'
JOIN semesters AS s ON s.semester_number = spd.semester_number
JOIN academic_years AS ay ON ay.academic_year_id = s.academic_year_id
JOIN classrooms AS c ON c.building = 'Главный корпус' AND c.room_number = '305'
JOIN lesson_types AS lt ON lt.lesson_type_name = 'Лекция'
WHERE sg.group_code = 'ПИ-223'
  AND sp.plan_code = 'PI-2026'
  AND d.discipline_code = 'DB-101'
  AND ay.start_year = 2026
  AND ay.end_year = 2027;

-- Проверка:
-- SELECT * FROM v_study_plan_disciplines;
-- SELECT * FROM v_schedule;

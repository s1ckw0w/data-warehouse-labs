-- 03_migrate_existing_schema.sql
-- Выполнять в academic_schedule_db, если ранее был запущен старый 01_schema.sql.
-- ВАЖНО: миграция рассчитана на пустую таблицу schedule_entries (демо-данные ещё не добавлялись).
-- Она меняет связь занятия с дисциплиной: теперь она проходит через учебный план.

BEGIN;

DROP VIEW IF EXISTS v_schedule;
DROP INDEX IF EXISTS idx_schedule_discipline_semester;

ALTER TABLE schedule_entries
    DROP COLUMN discipline_id;

ALTER TABLE schedule_entries
    ADD COLUMN plan_discipline_id BIGINT NOT NULL
        REFERENCES study_plan_disciplines(plan_discipline_id);

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

DROP TRIGGER IF EXISTS trg_validate_schedule_entry ON schedule_entries;

CREATE TRIGGER trg_validate_schedule_entry
BEFORE INSERT OR UPDATE ON schedule_entries
FOR EACH ROW
EXECUTE FUNCTION validate_schedule_entry();

CREATE INDEX idx_schedule_discipline_semester
    ON schedule_entries(plan_discipline_id, semester_id);

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

COMMIT;

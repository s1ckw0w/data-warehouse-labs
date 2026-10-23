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

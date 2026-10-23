-- 04_checks.sql: запросы, которые нужно выполнить в pgAdmin.
-- A. Текущее расписание: ожидается 4 строки после демоданных.
SELECT * FROM dv.v_schedule_current ORDER BY group_code, weekday, start_time;
-- B. Состав учебного плана: ожидается 2 дисциплины.
SELECT * FROM dv.v_plan_current ORDER BY discipline_code;
-- C. История изменений email T-001: ожидается 2 строки, старый и новый email.
SELECT h.teacher_code, s.teacher_email, s.load_dts, s.record_source, s.hashdiff
FROM dv.hub_teacher h
JOIN dv.sat_teacher s ON h.teacher_hk=s.teacher_hk
WHERE h.teacher_code='T-001'
ORDER BY s.load_dts;
-- D. Сводное число элементов Raw Data Vault:
SELECT 'hub' AS class, 11 AS tables_number, (
 (SELECT COUNT(*) FROM dv.hub_faculty)+
 (SELECT COUNT(*) FROM dv.hub_department)+
 (SELECT COUNT(*) FROM dv.hub_program)+
 (SELECT COUNT(*) FROM dv.hub_teacher)+
 (SELECT COUNT(*) FROM dv.hub_discipline)+
 (SELECT COUNT(*) FROM dv.hub_study_plan)+
 (SELECT COUNT(*) FROM dv.hub_study_group)+
 (SELECT COUNT(*) FROM dv.hub_semester)+
 (SELECT COUNT(*) FROM dv.hub_classroom)+
 (SELECT COUNT(*) FROM dv.hub_lesson_type)+
 (SELECT COUNT(*) FROM dv.hub_schedule)) AS rows_total
UNION ALL
SELECT 'link', 7, (
 (SELECT COUNT(*) FROM dv.lnk_department_faculty)+
 (SELECT COUNT(*) FROM dv.lnk_program_department)+
 (SELECT COUNT(*) FROM dv.lnk_teacher_department)+
 (SELECT COUNT(*) FROM dv.lnk_plan_program)+
 (SELECT COUNT(*) FROM dv.lnk_group_plan)+
 (SELECT COUNT(*) FROM dv.lnk_plan_discipline)+
 (SELECT COUNT(*) FROM dv.lnk_schedule_assignment))
UNION ALL
SELECT 'satellite', 12, (
 (SELECT COUNT(*) FROM dv.sat_faculty)+
 (SELECT COUNT(*) FROM dv.sat_department)+
 (SELECT COUNT(*) FROM dv.sat_program)+
 (SELECT COUNT(*) FROM dv.sat_teacher)+
 (SELECT COUNT(*) FROM dv.sat_discipline)+
 (SELECT COUNT(*) FROM dv.sat_study_plan)+
 (SELECT COUNT(*) FROM dv.sat_study_group)+
 (SELECT COUNT(*) FROM dv.sat_semester)+
 (SELECT COUNT(*) FROM dv.sat_classroom)+
 (SELECT COUNT(*) FROM dv.sat_lesson_type)+
 (SELECT COUNT(*) FROM dv.sat_schedule)+
 (SELECT COUNT(*) FROM dv.sat_plan_discipline));
-- E. Идемпотентность: повторите CALL dv.load_batch('B2');
-- число строк в sat_teacher не должно возрасти.
CALL dv.load_batch('B2');
SELECT COUNT(*) AS history_rows FROM dv.sat_teacher WHERE teacher_hk=dv.hk('T-001');

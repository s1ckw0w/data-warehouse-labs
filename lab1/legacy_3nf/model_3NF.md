# ER-модель лабораторной работы № 1

Вариант № 6: система составления учебного графика дисциплин факультета. Диаграмма ниже соответствует актуальной схеме PostgreSQL: занятие ссылается на дисциплину через `study_plan_disciplines`.

```mermaid
erDiagram
    FACULTIES ||--o{ DEPARTMENTS : contains
    DEPARTMENTS ||--o{ EDUCATION_PROGRAMS : offers
    DEPARTMENTS ||--o{ TEACHERS : employs
    EDUCATION_PROGRAMS ||--o{ STUDY_PLANS : has
    STUDY_PLANS ||--o{ STUDY_GROUPS : used_by
    STUDY_PLANS ||--o{ STUDY_PLAN_DISCIPLINES : includes
    DISCIPLINES ||--o{ STUDY_PLAN_DISCIPLINES : planned_in
    ASSESSMENT_TYPES ||--o{ STUDY_PLAN_DISCIPLINES : assessed_by
    ACADEMIC_YEARS ||--o{ SEMESTERS : consists_of
    STUDY_GROUPS ||--o{ SCHEDULE_ENTRIES : attends
    STUDY_PLAN_DISCIPLINES ||--o{ SCHEDULE_ENTRIES : scheduled_as
    TEACHERS ||--o{ SCHEDULE_ENTRIES : teaches
    SEMESTERS ||--o{ SCHEDULE_ENTRIES : occurs_in
    CLASSROOMS ||--o{ SCHEDULE_ENTRIES : hosted_in
    LESSON_TYPES ||--o{ SCHEDULE_ENTRIES : typed_as
```

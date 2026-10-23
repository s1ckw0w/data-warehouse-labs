-- Запускается из postgres или другой БД (без транзакции).
-- Создаёт отдельную БД и не затрагивает старую 3NF-версию.
CREATE DATABASE academic_schedule_dv ENCODING 'UTF8';
-- В pgAdmin далее подключитесь к academic_schedule_dv.

-- V2: Розширення сутності Session новими атрибутами
ALTER TABLE Session
ADD COLUMN cancellation_reason VARCHAR(255);

ALTER TABLE Session
ADD COLUMN internal_notes TEXT;
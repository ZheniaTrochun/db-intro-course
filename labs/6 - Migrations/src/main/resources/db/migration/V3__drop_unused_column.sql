-- V3: Очищення структури Session від неактуального стовпця
ALTER TABLE Session
DROP COLUMN internal_notes;
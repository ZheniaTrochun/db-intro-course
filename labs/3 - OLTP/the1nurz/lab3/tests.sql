BEGIN;

SELECT member_id, first_name, last_name
FROM member WHERE member_id = 1;

DO $$
BEGIN
    IF (SELECT COUNT(*) FROM member) <> 5
        OR (SELECT COUNT(*) FROM author) <> 5
        OR (SELECT COUNT(*) FROM book) <> 5
        OR (SELECT COUNT(*) FROM book_author) <> 6
        OR (SELECT COUNT(*) FROM loan) <> 5 THEN
        RAISE EXCEPTION 'T1 FAIL: unexpected row counts';
    END IF;

    IF EXISTS (
        SELECT 1 FROM book b
        WHERE NOT EXISTS (
            SELECT 1 FROM book_author ba WHERE ba.book_id = b.book_id
        )
    ) THEN
        RAISE EXCEPTION 'T1 FAIL: a book has no author';
    END IF;
    RAISE NOTICE 'T1 PASS: row counts 5/5/5/6/5; every book has an author';

    BEGIN
        INSERT INTO loan (loan_id, member_id, book_id, loan_date, due_date)
        VALUES (1002, 1, 1, '2026-11-25', '2026-12-09');
        RAISE EXCEPTION 'T2 FAIL: a second open loan was accepted';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'T2 PASS: a second open loan is rejected (%)', SQLSTATE;
    END;

    BEGIN
        INSERT INTO loan (loan_id, member_id, book_id, loan_date, due_date)
        VALUES (1002, 999999, 5, '2026-11-25', '2026-12-09');
        RAISE EXCEPTION 'T3 FAIL: an unknown member was accepted';
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'T3 PASS: an unknown member is rejected (%)', SQLSTATE;
    END;

    BEGIN
        INSERT INTO loan (loan_id, member_id, book_id, loan_date, due_date)
        VALUES (1002, 1, 5, '2026-11-25', '2026-11-24');
        RAISE EXCEPTION 'T4 FAIL: an invalid due date was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'T4 PASS: an invalid due date is rejected (%)', SQLSTATE;
    END;

    BEGIN
        INSERT INTO loan (loan_id, member_id, book_id, loan_date, due_date, return_date)
        VALUES (1002, 1, 5, '2026-11-25', '2026-12-09', '2026-11-24');
        RAISE EXCEPTION 'T5 FAIL: an invalid return date was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'T5 PASS: an invalid return date is rejected (%)', SQLSTATE;
    END;

    BEGIN
        DELETE FROM member WHERE member_id = 1;
        RAISE EXCEPTION 'T6 FAIL: a member with loans was deleted';
    EXCEPTION WHEN foreign_key_violation OR SQLSTATE '23001' THEN
        RAISE NOTICE 'T6 PASS: a member with loans cannot be deleted (%)', SQLSTATE;
    END;
END;
$$;

ROLLBACK;

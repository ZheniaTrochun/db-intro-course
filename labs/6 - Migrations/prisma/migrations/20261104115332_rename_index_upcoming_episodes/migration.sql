-- DropIndex
DROP INDEX "users_email_key";

-- DropIndex
DROP INDEX "users_nickname_key";

-- RenameIndex
ALTER INDEX "idx_upcoming_episodes_date" RENAME TO "idx_upcoming_episode_date";

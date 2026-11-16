/*
  Warnings:

  - A unique constraint covering the columns `[email]` on the table `security_employee` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "security_employee" ADD COLUMN     "email" VARCHAR(150);

-- CreateIndex
CREATE UNIQUE INDEX "security_employee_email_key" ON "security_employee"("email");

-- CreateTable
CREATE TABLE "incident" (
    "incident_id" SERIAL NOT NULL,
    "visit_id" INTEGER NOT NULL,
    "type_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "status_id" INTEGER NOT NULL DEFAULT 1,
    "description" TEXT,
    "occurred_at" TIMESTAMP(6) NOT NULL,
    "severity" VARCHAR(20) NOT NULL,

    CONSTRAINT "incident_pkey" PRIMARY KEY ("incident_id")
);

-- CreateTable
CREATE TABLE "incident_participant" (
    "incident_id" INTEGER NOT NULL,
    "visit_id" INTEGER NOT NULL,
    "role_id" INTEGER NOT NULL,

    CONSTRAINT "pk_incident_participant" PRIMARY KEY ("incident_id","visit_id")
);

-- CreateTable
CREATE TABLE "incident_status" (
    "status_id" SERIAL NOT NULL,
    "name" VARCHAR(30) NOT NULL,

    CONSTRAINT "incident_status_pkey" PRIMARY KEY ("status_id")
);

-- CreateTable
CREATE TABLE "incident_type" (
    "type_id" SERIAL NOT NULL,
    "name" VARCHAR(100) NOT NULL,

    CONSTRAINT "incident_type_pkey" PRIMARY KEY ("type_id")
);

-- CreateTable
CREATE TABLE "participant_role" (
    "role_id" SERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL,

    CONSTRAINT "participant_role_pkey" PRIMARY KEY ("role_id")
);

-- CreateTable
CREATE TABLE "security_employee" (
    "employee_id" SERIAL NOT NULL,
    "full_name" VARCHAR(150) NOT NULL,
    "position" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,

    CONSTRAINT "security_employee_pkey" PRIMARY KEY ("employee_id")
);

-- CreateTable
CREATE TABLE "student" (
    "student_id" SERIAL NOT NULL,
    "group_id" INTEGER NOT NULL,
    "full_name" VARCHAR(150) NOT NULL,

    CONSTRAINT "student_pkey" PRIMARY KEY ("student_id")
);

-- CreateTable
CREATE TABLE "visit" (
    "visit_id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "category" VARCHAR(50) NOT NULL DEFAULT 'Відпочинок',
    "started_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ended_at" TIMESTAMP(6),

    CONSTRAINT "visit_pkey" PRIMARY KEY ("visit_id")
);

-- CreateTable
CREATE TABLE "faculty" (
    "faculty_id" SERIAL NOT NULL,
    "name" VARCHAR(150) NOT NULL,

    CONSTRAINT "faculty_pkey" PRIMARY KEY ("faculty_id")
);

-- CreateTable
CREATE TABLE "student_group" (
    "group_id" SERIAL NOT NULL,
    "faculty_id" INTEGER NOT NULL,
    "name" VARCHAR(50) NOT NULL,

    CONSTRAINT "student_group_pkey" PRIMARY KEY ("group_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "incident_status_name_key" ON "incident_status"("name");

-- CreateIndex
CREATE UNIQUE INDEX "incident_type_name_key" ON "incident_type"("name");

-- CreateIndex
CREATE UNIQUE INDEX "participant_role_name_key" ON "participant_role"("name");

-- CreateIndex
CREATE UNIQUE INDEX "security_employee_phone_key" ON "security_employee"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "faculty_name_key" ON "faculty"("name");

-- CreateIndex
CREATE UNIQUE INDEX "student_group_name_key" ON "student_group"("name");

-- AddForeignKey
ALTER TABLE "incident" ADD CONSTRAINT "fk_incident_employee" FOREIGN KEY ("employee_id") REFERENCES "security_employee"("employee_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident" ADD CONSTRAINT "fk_incident_status" FOREIGN KEY ("status_id") REFERENCES "incident_status"("status_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident" ADD CONSTRAINT "fk_incident_type" FOREIGN KEY ("type_id") REFERENCES "incident_type"("type_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident" ADD CONSTRAINT "fk_incident_visit" FOREIGN KEY ("visit_id") REFERENCES "visit"("visit_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident_participant" ADD CONSTRAINT "fk_participant_incident" FOREIGN KEY ("incident_id") REFERENCES "incident"("incident_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident_participant" ADD CONSTRAINT "fk_participant_role" FOREIGN KEY ("role_id") REFERENCES "participant_role"("role_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident_participant" ADD CONSTRAINT "fk_participant_visit" FOREIGN KEY ("visit_id") REFERENCES "visit"("visit_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "student" ADD CONSTRAINT "fk_student_group" FOREIGN KEY ("group_id") REFERENCES "student_group"("group_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "visit" ADD CONSTRAINT "fk_visit_student" FOREIGN KEY ("student_id") REFERENCES "student"("student_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "student_group" ADD CONSTRAINT "fk_student_group_faculty" FOREIGN KEY ("faculty_id") REFERENCES "faculty"("faculty_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

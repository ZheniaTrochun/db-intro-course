-- CreateTable
CREATE TABLE "incident_comment" (
    "comment_id" SERIAL NOT NULL,
    "incident_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "text" TEXT NOT NULL,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "incident_comment_pkey" PRIMARY KEY ("comment_id")
);

-- AddForeignKey
ALTER TABLE "incident_comment" ADD CONSTRAINT "fk_comment_incident" FOREIGN KEY ("incident_id") REFERENCES "incident"("incident_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "incident_comment" ADD CONSTRAINT "fk_comment_employee" FOREIGN KEY ("employee_id") REFERENCES "security_employee"("employee_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

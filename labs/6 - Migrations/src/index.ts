import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../prisma/generated/prisma/client";

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

async function main() {
  const incident = await prisma.incident.findFirstOrThrow();
  const employee = await prisma.security_employee.findFirstOrThrow();

  await prisma.incident_comment.create({
    data: {
      incident_id: incident.incident_id,
      employee_id: employee.employee_id,
      text: "Перевірка після міграцій",
    },
  });

  // Нове поле email (міграція add-employee-email)
  await prisma.security_employee.update({
    where: { employee_id: employee.employee_id },
    data: { email: "updated@example.com" },
  });

  const incidents = await prisma.incident.findMany({
    include: { incident_comment: true },
  });
  console.log(JSON.stringify(incidents, null, 2));
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
// test: пробую prisma client — include щоб не було N+1
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany({
    include: { videos: true },
  });
  console.log(users.map(u => `${u.username}: ${u.videos.length} videos`));
}

main().finally(() => prisma.$disconnect());

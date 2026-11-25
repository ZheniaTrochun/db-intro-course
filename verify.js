require('dotenv/config');
const { PrismaPg } = require('@prisma/adapter-pg');
const { PrismaClient } = require('@prisma/client');
const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

const show = (title, data) => {
  console.log(`\n=== ${title} ===`);
  console.log(
    JSON.stringify(data, (_, v) => (typeof v === 'bigint' ? v.toString() : v), 2)
  );
};

async function main() {
  await prisma.achievement.createMany({
    data: [
      { app_id: 1, name: 'First Blood', description: 'Win the first battle', points: 10 },
      { app_id: 1, name: 'Master Tactician', description: 'Finish the campaign on hard', points: 50 },
      { app_id: 2, name: 'Empire Fallen', description: 'Reach the final chapter', points: 100 },
    ],
    skipDuplicates: true,
  });

  await prisma.app.update({
    where: { app_id: 4 },
    data: { is_available: false, rating: 4.25 },
  });

  await prisma.app.update({
    where: { app_id: 1 },
    data: { rating: 4.95 },
  });

  const apps = await prisma.app.findMany({
    select: {
      app_id: true,
      title: true,
      is_available: true,
      rating: true,
      achievements: { select: { name: true, points: true } },
    },
    orderBy: { app_id: 'asc' },
  });
  show('app + is_available + rating + achievement', apps);

  const createdReview = await prisma.review.upsert({
    where: { user_id_app_id: { user_id: 4, app_id: 1 } },
    update: {},
    create: {
      user_id: 4,
      app_id: 1,
      is_recommended: true,
      playtime_at_review: 29,
      content: 'Great!',
    },
  });

  await prisma.review_comments.create({
    data: {
      review_id: createdReview.review_id,
      user_id: 1,
      content: 'Totally agree!',
    },
  });

  const appWithReviewsAndComments = await prisma.app.findMany({
    where: { review: { some: {} } },
    select: {
      title: true,
      rating: true,
      review: {
        select: {
          review_id: true,
          user_id: true,
          is_recommended: true,
          content: true,
          reviewComments: {
            select: {
              comment_id: true,
              user_id: true,
              content: true,
              created_at: true,
            },
          },
        },
      },
    },
  });
  show('app + review + review_comments (new table)', appWithReviewsAndComments);

  const categories = await prisma.category.findMany({ orderBy: { category_id: 'asc' } });
  show('category (без description)', categories);

  const stats = await prisma.achievement.groupBy({
    by: ['app_id'],
    _count: { _all: true },
    _sum: { points: true },
  });
  show('achievement:', stats);
}

main()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
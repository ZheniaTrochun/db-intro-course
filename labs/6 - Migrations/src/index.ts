import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@lab6-orm/client";
import { config } from "../config";

const prisma = new PrismaClient({
  adapter: new PrismaPg(config.DB_URL),
});

async function main() {
  // Anime instance insertion
  const anime = await prisma.anime.create({
    data: {
      slug: "frieren-beyond-journeys-end-season-two",
      titleUa: "Фрірен, що проводжає в останню путь сезон 2",
      titleEn: "Frieren: Beyond Journey's End",
      titleOriginal: "葬送のフリーレン",
      yearReleased: 2023,
      episodeCount: 28,
      avgEpisodeDuration: 24,
      ageRestriction: "pg13",
      animeStatus: "finished",
      animeFormat: "tv",
      genres: {
        create: [
          { genreType: "adventure", isPrimary: true },
          { genreType: "fantasy" },
          { genreType: "drama" },
        ],
      },
    },
    include: { genres: true },
  });
  console.log("Anime entry:", anime);

  // Find anime titles with fantasy genre with pagination
  const catalog = await prisma.anime.findMany({
    where: {
      available: true,
      animeStatus: { in: ["ongoing", "finished"] },
      genres: { some: { genreType: "fantasy" } },
    },
    select: {
      animeId: true,
      slug: true,
      titleUa: true,
      coverUrl: true,
      yearReleased: true,
      genres: { select: { genreType: true, isPrimary: true } },
    },
    orderBy: { yearReleased: "desc" },
    skip: 0,
    take: 20,
  });
  console.log("Page animes:", catalog);

  // Upcoming episodes that are about to upcome
  const upcoming = await prisma.upcomingEpisode.findMany({
    where: { episodeDate: { gte: new Date() } },
    include: { anime: { select: { slug: true, titleUa: true } } },
    orderBy: { episodeDate: "asc" },
    take: 10,
  });
  console.log("Upcoming episodes:", upcoming);

  // Update user's list entry or create a new one
  const userId = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa";
  const listUnit = await prisma.animeListUnit.upsert({
    where: {
      userId_animeId: { userId, animeId: anime.animeId },
    },
    create: {
      userId,
      animeId: anime.animeId,
      watchedEpisodes: 5,
      listUnitStatus: "watching",
      grade: 9,
    },
    update: {
      watchedEpisodes: { increment: 1 },
      grade: 9,
    },
  });
  console.log("Anime list unit:", listUnit);

  // Find dubbed episodes of specified anime
  const dubbedEpisodes = await prisma.episode.findMany({
    where: { animeId: anime.animeId, localizationType: "dub" },
    orderBy: { episodeId: "asc" },
  });
  console.log("Dubbed episodes:", dubbedEpisodes);

  // Delete expired sessions
  const deleted = await prisma.session.deleteMany({
    where: { expireTime: { lt: new Date() } },
  });
  console.log("Removed sessions:", deleted.count);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

-- CreateEnum
CREATE TYPE "MpaaRating" AS ENUM ('g', 'pg', 'pg13', 'r', 'nc17');

-- CreateEnum
CREATE TYPE "AnimeStatus" AS ENUM ('upcoming', 'ongoing', 'finished');

-- CreateEnum
CREATE TYPE "AnimeFormat" AS ENUM ('tv', 'ova', 'ona', 'movie', 'special', 'music', 'other');

-- CreateEnum
CREATE TYPE "GenreType" AS ENUM ('action', 'adventure', 'avant_garde', 'boys_love', 'comedy', 'demons', 'drama', 'ecchi', 'fantasy', 'girls_love', 'gourmet', 'harem', 'hentai', 'historical', 'horror', 'isekai', 'josei', 'kids', 'magic', 'martial_arts', 'mecha', 'military', 'music', 'mystery', 'parody', 'psychological', 'romance', 'samurai', 'school', 'sci_fi', 'seinen', 'shoujo', 'shoujo_ai', 'shounen', 'shounen_ai', 'slice_of_life', 'space', 'sports', 'supernatural', 'super_power', 'suspense');

-- CreateTable
CREATE TABLE "animes" (
    "anime_id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "title_ua" TEXT NOT NULL,
    "title_en" TEXT NOT NULL,
    "title_original" TEXT NOT NULL,
    "anime_description" TEXT NOT NULL DEFAULT '',
    "cover_url" TEXT,
    "production_studio" TEXT,
    "mal_id" TEXT,
    "anilist_id" TEXT,
    "hikka_id" TEXT,
    "imdb_id" TEXT,
    "year_released" INTEGER,
    "avg_episode_duration" INTEGER NOT NULL,
    "episode_count" INTEGER NOT NULL,
    "age_restriction" "MpaaRating",
    "anime_status" "AnimeStatus",
    "anime_format" "AnimeFormat" NOT NULL DEFAULT 'tv',
    "is_exist" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "animes_pkey" PRIMARY KEY ("anime_id")
);

-- CreateTable
CREATE TABLE "genres" (
    "anime_id" TEXT NOT NULL,
    "genre_type" "GenreType" NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "genres_pkey" PRIMARY KEY ("anime_id","genre_type")
);

-- CreateTable
CREATE TABLE "upcoming_episodes" (
    "anime_id" TEXT NOT NULL,
    "episode_name" TEXT NOT NULL,
    "episode_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "upcoming_episodes_pkey" PRIMARY KEY ("anime_id","episode_name")
);

-- CreateIndex
CREATE UNIQUE INDEX "animes_slug_key" ON "animes"("slug");

-- AddForeignKey
ALTER TABLE "genres" ADD CONSTRAINT "genres_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "upcoming_episodes" ADD CONSTRAINT "upcoming_episodes_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE RESTRICT ON UPDATE CASCADE;

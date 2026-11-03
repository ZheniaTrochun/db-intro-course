-- CreateEnum
CREATE TYPE "genre_type_enum" AS ENUM ('action', 'adventure', 'avant_garde', 'boys_love', 'comedy', 'demons', 'drama', 'ecchi', 'fantasy', 'girls_love', 'gourmet', 'harem', 'hentai', 'historical', 'horror', 'isekai', 'josei', 'kids', 'magic', 'martial_arts', 'mecha', 'military', 'music', 'mystery', 'parody', 'psychological', 'romance', 'samurai', 'school', 'sci_fi', 'seinen', 'shoujo', 'shoujo_ai', 'shounen', 'shounen_ai', 'slice_of_life', 'space', 'sports', 'supernatural', 'super_power', 'suspense');

-- CreateTable
CREATE TABLE "genres" (
    "anime_id" UUID NOT NULL,
    "genre_type" "genre_type_enum" NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "genres_pkey" PRIMARY KEY ("anime_id","genre_type")
);

-- AddForeignKey
ALTER TABLE "genres" ADD CONSTRAINT "genres_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "animes"("anime_id") ON DELETE RESTRICT ON UPDATE CASCADE;

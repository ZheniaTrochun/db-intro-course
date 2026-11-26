-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "class" AS ENUM ('cleric', 'fighter', 'rogue', 'wizard');

-- CreateEnum
CREATE TYPE "monster_state" AS ENUM ('wander', 'attack');

-- CreateEnum
CREATE TYPE "race" AS ENUM ('human', 'orc', 'elf', 'dwarf', 'khajiit');

-- CreateEnum
CREATE TYPE "sex" AS ENUM ('male', 'female', 'croissant', 'non-binary');

-- CreateEnum
CREATE TYPE "item_type" AS ENUM ('weapon', 'food', 'armor', 'tool');

-- CreateTable
CREATE TABLE "monster_type" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "description" VARCHAR(500),

    CONSTRAINT "monster_type_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stats" (
    "id" SERIAL NOT NULL,
    "strength" INTEGER NOT NULL,
    "dexterity" INTEGER NOT NULL,
    "intelligence" INTEGER NOT NULL,
    "defense" INTEGER NOT NULL,
    "agility" INTEGER NOT NULL,

    CONSTRAINT "stats_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "world_entity" (
    "id" SERIAL NOT NULL,
    "zone_id" INTEGER NOT NULL,
    "position_x" DECIMAL NOT NULL,
    "position_y" DECIMAL NOT NULL,
    "position_z" DECIMAL NOT NULL,
    "max_hp" INTEGER NOT NULL,
    "level" INTEGER NOT NULL,

    CONSTRAINT "world_entity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "zone" (
    "id" SERIAL NOT NULL,
    "level_requirement" INTEGER,
    "zone_name" VARCHAR(100),

    CONSTRAINT "zone_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "character" (
    "id" SERIAL NOT NULL,
    "worldentity_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "stats_id" INTEGER NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "experience" INTEGER NOT NULL DEFAULT 0,
    "current_hp" INTEGER NOT NULL,
    "current_mana" INTEGER NOT NULL,
    "max_mana" INTEGER NOT NULL,
    "skin_color_hex" CHAR(7) NOT NULL,
    "sex" "sex" NOT NULL,
    "race" "race" NOT NULL,
    "class" "class" NOT NULL,

    CONSTRAINT "character_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "character_spell" (
    "character_id" INTEGER NOT NULL,
    "spell_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "character_spell_pkey" PRIMARY KEY ("character_id","spell_id")
);

-- CreateTable
CREATE TABLE "enchantment" (
    "item_id" INTEGER NOT NULL,
    "ench_level" INTEGER NOT NULL,
    "effect" VARCHAR(255) NOT NULL,

    CONSTRAINT "enchantment_pkey" PRIMARY KEY ("item_id")
);

-- CreateTable
CREATE TABLE "inventory" (
    "id" SERIAL NOT NULL,
    "character_id" INTEGER NOT NULL,
    "gold" INTEGER NOT NULL DEFAULT 0,
    "capacity" INTEGER NOT NULL DEFAULT 20,

    CONSTRAINT "inventory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "item" (
    "id" SERIAL NOT NULL,
    "item_tmpl_id" INTEGER NOT NULL,
    "inv_id" INTEGER NOT NULL,
    "inventory_slot" SMALLINT NOT NULL,
    "quantity" SMALLINT NOT NULL DEFAULT 1,
    "damage" INTEGER,
    "attack_speed" DECIMAL,
    "protect" INTEGER,
    "up_health" INTEGER,

    CONSTRAINT "item_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "item_template" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "description" VARCHAR(128) NOT NULL,
    "max_stack" SMALLINT NOT NULL DEFAULT 1,
    "rarity" SMALLINT NOT NULL DEFAULT 0,
    "type" "item_type" NOT NULL,

    CONSTRAINT "item_template_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "monster_drop" (
    "monster_id" INTEGER NOT NULL,
    "item_id" INTEGER NOT NULL,

    CONSTRAINT "monster_drop_pkey" PRIMARY KEY ("monster_id","item_id")
);

-- CreateTable
CREATE TABLE "monster_entity" (
    "id" SERIAL NOT NULL,
    "entity_id" INTEGER NOT NULL,
    "state" "monster_state" NOT NULL DEFAULT 'wander',
    "stats_id" INTEGER NOT NULL,
    "type_id" INTEGER NOT NULL,
    "target_id" INTEGER,

    CONSTRAINT "monster_entity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "npc" (
    "id" SERIAL NOT NULL,
    "entity_id" INTEGER NOT NULL,
    "name" VARCHAR(128) NOT NULL,

    CONSTRAINT "npc_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "npc_item_relation" (
    "npc_id" INTEGER NOT NULL,
    "item_id" INTEGER NOT NULL,
    "sell_price" INTEGER,
    "buy_price" INTEGER,

    CONSTRAINT "npc_item_relation_pkey" PRIMARY KEY ("npc_id","item_id")
);

-- CreateTable
CREATE TABLE "spell" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(128) NOT NULL,
    "description" VARCHAR(512) NOT NULL,
    "mana_cost" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "spell_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_ban" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "ban_until" TIMESTAMPTZ(6) NOT NULL,
    "ban_reason" VARCHAR(420) NOT NULL,

    CONSTRAINT "user_ban_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "username" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(128) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "spell_name_key" ON "spell"("name");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- AddForeignKey
ALTER TABLE "world_entity" ADD CONSTRAINT "world_entity_zone_id_fkey" FOREIGN KEY ("zone_id") REFERENCES "zone"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "character" ADD CONSTRAINT "character_stats_id_fkey" FOREIGN KEY ("stats_id") REFERENCES "stats"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "character" ADD CONSTRAINT "character_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "character" ADD CONSTRAINT "character_worldentity_id_fkey" FOREIGN KEY ("worldentity_id") REFERENCES "world_entity"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "character_spell" ADD CONSTRAINT "character_spell_character_id_fkey" FOREIGN KEY ("character_id") REFERENCES "character"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "character_spell" ADD CONSTRAINT "character_spell_spell_id_fkey" FOREIGN KEY ("spell_id") REFERENCES "spell"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "enchantment" ADD CONSTRAINT "enchantment_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "item"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_character_id_fkey" FOREIGN KEY ("character_id") REFERENCES "character"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "item" ADD CONSTRAINT "item_inv_id_fkey" FOREIGN KEY ("inv_id") REFERENCES "inventory"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "item" ADD CONSTRAINT "item_item_tmpl_id_fkey" FOREIGN KEY ("item_tmpl_id") REFERENCES "item_template"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "monster_drop" ADD CONSTRAINT "monster_drop_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "item_template"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "monster_drop" ADD CONSTRAINT "monster_drop_monster_id_fkey" FOREIGN KEY ("monster_id") REFERENCES "monster_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "monster_entity" ADD CONSTRAINT "monster_entity_entity_id_fkey" FOREIGN KEY ("entity_id") REFERENCES "world_entity"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "monster_entity" ADD CONSTRAINT "monster_entity_stats_id_fkey" FOREIGN KEY ("stats_id") REFERENCES "stats"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "monster_entity" ADD CONSTRAINT "monster_entity_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "character"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "monster_entity" ADD CONSTRAINT "monster_entity_type_id_fkey" FOREIGN KEY ("type_id") REFERENCES "monster_type"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "npc" ADD CONSTRAINT "npc_entity_id_fkey" FOREIGN KEY ("entity_id") REFERENCES "world_entity"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "npc_item_relation" ADD CONSTRAINT "npc_item_relation_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "item_template"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "npc_item_relation" ADD CONSTRAINT "npc_item_relation_npc_id_fkey" FOREIGN KEY ("npc_id") REFERENCES "npc"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "user_ban" ADD CONSTRAINT "user_ban_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE public.""character"" ADD CONSTRAINT character_check CHECK ((current_mana <= max_mana));
ALTER TABLE public.""character"" ADD CONSTRAINT character_experience_check CHECK ((experience >= 0));
ALTER TABLE public.""character"" ADD CONSTRAINT character_max_mana_check CHECK ((max_mana >= 0));
ALTER TABLE public.""character"" ADD CONSTRAINT character_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text));
ALTER TABLE public.""character"" ADD CONSTRAINT character_skin_color_hex_check CHECK ((skin_color_hex ~ '^#[0-9a-fA-F]{6}$'::text));
ALTER TABLE public.character_spell ADD CONSTRAINT character_spell_quantity_check CHECK ((quantity >= 0));
ALTER TABLE public.enchantment ADD CONSTRAINT enchantment_ench_level_check CHECK ((ench_level > 0));
ALTER TABLE public.item ADD CONSTRAINT item_attack_speed_check CHECK ((attack_speed > (0)::numeric));
ALTER TABLE public.item ADD CONSTRAINT item_damage_check CHECK ((damage >= 0));
ALTER TABLE public.item ADD CONSTRAINT item_protect_check CHECK ((protect >= 0));
ALTER TABLE public.item ADD CONSTRAINT item_up_health_check CHECK ((up_health >= 0));
ALTER TABLE public.spell ADD CONSTRAINT spell_description_check CHECK ((TRIM(BOTH FROM description) <> ''::text));
ALTER TABLE public.spell ADD CONSTRAINT spell_mana_cost_check CHECK ((mana_cost >= 0));
ALTER TABLE public.spell ADD CONSTRAINT spell_name_check CHECK ((TRIM(BOTH FROM name) <> ''::text));
ALTER TABLE public.user_ban ADD CONSTRAINT user_ban_ban_reason_check CHECK ((TRIM(BOTH FROM ban_reason) <> ''::text));
ALTER TABLE public.users ADD CONSTRAINT users_email_check CHECK (((email)::text ~~ '_%@_%._%'::text));
ALTER TABLE public.users ADD CONSTRAINT users_password_hash_check CHECK ((TRIM(BOTH FROM password_hash) <> ''::text));
ALTER TABLE public.world_entity ADD CONSTRAINT world_entity_level_check CHECK ((level >= 0));
ALTER TABLE public.world_entity ADD CONSTRAINT world_entity_max_hp_check CHECK ((max_hp > 0));
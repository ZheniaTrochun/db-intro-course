#!/usr/bin/env python3
"""
Генератор INSERT-запитів для схеми аніме-сайту (PostgreSQL).

Залежність:  pip install faker
Приклад:     python gen_seed.py --users 200 --animes 100 --seed 42 -o seed.sql
             psql -d mydb -f seed.sql

Порядок вставки (враховує FK):
  users -> animes -> genres -> episodes -> upcoming_episodes
        -> comments -> anime_list_units -> sessions
Колонки GENERATED ALWAYS AS IDENTITY (comment_id, episode_id, session_id)
пропускаються — їх генерує БД. UUID (v7-подібні) генеруються тут, щоб FK були узгодженими.
"""
# Claude generated code
import argparse
import random
import time
from datetime import date, datetime, timedelta, timezone

from faker import Faker
from faker.utils.text import slugify

# ----------------------------------------------------------------- enums
ANIME_FORMATS = ["tv", "ova", "ona", "movie", "special", "music", "other"]
FORMAT_WEIGHTS = [60, 10, 8, 10, 5, 3, 4]
ANIME_STATUSES = ["upcoming", "ongoing", "cancelled", "finished"]
MPAA = ["g", "pg", "pg13", "r", "nc17"]
LIST_STATUSES = ["finished", "watching", "delayed", "dropped"]
LOC_TYPES = ["sub", "dub"]
USER_STATUSES = ["active", "banned", "deactivated"]

GENRES = [
    "action", "adventure", "avant_garde", "award_winning", "boys_love", "comedy",
    "drama", "fantasy", "girls_love", "gourmet", "horror", "mystery", "romance",
    "sci_fi", "slice_of_life", "sports", "supernatural", "suspense", "ecchi",
    "erotica", "hentai", "adult_cast", "anthropomorphic", "cgdct", "childcare",
    "combat_sports", "crossdressing", "delinquents", "detective", "educational",
    "gag_humor", "gore", "harem", "high_stakes_game", "historical", "idols_female",
    "idols_male", "isekai", "iyashikei", "love_polygon", "love_status_quo",
    "fantasy_sex_shift", "mahou_shoujo", "martial_arts", "mecha", "medical",
    "military", "music", "mythology", "organized_crime", "otaku_culture", "parody",
    "performing_arts", "pets", "psychological", "racing", "reincarnation",
    "reverse_harem", "samurai", "school", "showbiz", "space", "strategy_game",
    "super_power", "survival", "team_sports", "time_travel", "urban_fantasy",
    "vampire", "video_game", "villainess", "visual_arts", "workplace", "josei",
    "kids", "seinen", "shoujo", "shounen",
]
ADULT_GENRES = {"erotica", "hentai", "ecchi"}

STUDIOS = ["Madhouse", "Bones", "Kyoto Animation", "MAPPA", "Wit Studio", "Ufotable",
           "Sunrise", "Trigger", "A-1 Pictures", "CloverWorks", "Production I.G",
           "Studio Ghibli", "Toei Animation", "Shaft", "J.C.Staff"]
LOC_STUDIOS = ["Gembird", "Amanogawa", "Ukrainian Voice", "FanVoxUA", "AniUA", "Moon Dub", "Clan Kaizoku"]
BROWSERS = ["Chrome", "Firefox", "Safari", "Edge", "Opera"]
OSES = ["Windows 11", "macOS 14", "Ubuntu 24.04", "Android 14", "iOS 17"]
DEVICE_TYPES = ["desktop", "mobile", "tablet"]


# ----------------------------------------------------------------- helpers
def uuid7(ts: datetime) -> str:
    """UUID v7 (48 біти мс-часу + випадкові) на основі глобального random (відтворюється через --seed)."""
    ms = int(ts.timestamp() * 1000) & ((1 << 48) - 1)
    rand_a = random.getrandbits(12)
    rand_b = random.getrandbits(62)
    n = (ms << 80) | (0x7 << 76) | (rand_a << 64) | (0b10 << 62) | rand_b
    h = f"{n:032x}"
    return f"{h[:8]}-{h[8:12]}-{h[12:16]}-{h[16:20]}-{h[20:]}"


def q(v) -> str:
    """Екранування значення в SQL-літерал."""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, datetime):
        return f"'{v.isoformat(sep=' ')}'"
    if isinstance(v, date):
        return f"'{v.isoformat()}'"
    if isinstance(v, list):
        if not v:
            return "ARRAY[]::TEXT[]"
        return "ARRAY[" + ", ".join(q(x) for x in v) + "]::TEXT[]"
    if isinstance(v, bytes):
        return f"decode('{v.hex()}', 'hex')"
    return "'" + str(v).replace("'", "''") + "'"


def emit(out, table, cols, rows, batch=500):
    if not rows:
        return
    out.write(f"\n-- {table}: {len(rows)} rows\n")
    for i in range(0, len(rows), batch):
        chunk = rows[i:i + batch]
        out.write(f"INSERT INTO public.{table} ({', '.join(cols)}) VALUES\n")
        out.write(",\n".join("  (" + ", ".join(q(v) for v in r) + ")" for r in chunk))
        out.write(";\n")


def rand_dt(start: datetime, end: datetime) -> datetime:
    if end <= start:
        return start
    return start + timedelta(seconds=random.randint(0, int((end - start).total_seconds())))


def cap(s: str, n: int) -> str:
    return s[:n].rstrip()


# ----------------------------------------------------------------- generators
def gen_users(n, fake, now):
    rows, ids = [], []
    for i in range(n):
        created = rand_dt(now - timedelta(days=900), now - timedelta(days=1))
        updated = rand_dt(created, now)
        uid = uuid7(created)
        base = fake.user_name().replace(".", "_")
        nickname = cap(f"{base}_{i}", 30)  # суфікс i гарантує унікальність (за умови base < ~25 символів)
        if len(nickname) < len(f"_{i}"):
            nickname = f"user_{i}"
        email = f"{slugify(base) or 'user'}.{i}@{fake.free_email_domain()}"
        has_google = random.random() < 0.35
        has_pass = (not has_google) or random.random() < 0.4
        google_id = str(random.getrandbits(66)) if has_google else None
        password_hash = (
            "$argon2id$v=19$m=65536,t=3,p=4$" + fake.pystr(22, 22) + "$" + fake.pystr(43, 43)
            if has_pass else None
        )
        last_watch = streak_start = None
        max_streak = 0
        if random.random() < 0.7:
            last_watch = (now - timedelta(days=random.randint(0, 60))).date()
            max_streak = random.randint(1, 120)
            streak_start = last_watch - timedelta(days=random.randint(0, max_streak))
        role = "admin" if random.random() < 0.03 else "user"
        status = random.choices(USER_STATUSES, weights=[90, 5, 5])[0]
        rows.append([
            uid, nickname, cap(fake.name(), 100), email, google_id,
            fake.sentence(nb_words=8) if random.random() < 0.5 else "",
            password_hash,
            f"https://i.pravatar.cc/200?u={uid}" if random.random() < 0.7 else None,
            [f"https://t.me/{base}"] if random.random() < 0.3 else [],
            max_streak, fake.timezone(), streak_start, last_watch,
            None, None, role, status, created, updated,
        ])
        ids.append((uid, created))
    cols = ["user_id", "nickname", "full_name", "email", "google_id", "bio",
            "password_hash", "avatar_url", "social_networks", "max_streak", "timezone",
            "streak_start_date", "last_watch_date", "profile_frame_url",
            "profile_background_url", "user_role", "user_status", "created_at", "updated_at"]
    return cols, rows, ids


def gen_animes(n, fake_ua, fake_en, fake_jp, now, adult):
    rows, meta = [], []
    for i in range(n):
        fmt = random.choices(ANIME_FORMATS, weights=FORMAT_WEIGHTS)[0]
        status = random.choice(ANIME_STATUSES) if random.random() < 0.95 else None
        year = random.randint(1985, now.year + (1 if status == "upcoming" else 0))
        if status == "upcoming":
            year = now.year + random.randint(0, 1)
        if fmt == "movie":
            episodes, duration = 1, random.randint(60, 150)
        elif fmt in ("tv", "ona"):
            episodes, duration = random.choice([12, 12, 13, 24, 25, 26, 50]), random.choice([23, 24, 25])
        else:
            episodes, duration = random.randint(1, 6), random.randint(10, 50)
        title_en = " ".join(w.capitalize() for w in fake_en.words(random.randint(2, 4)))
        title_ua = " ".join(w.capitalize() for w in fake_ua.words(random.randint(2, 4)))
        title_jp = "".join(fake_jp.word() for _ in range(2))
        aid = uuid7(now - timedelta(days=random.randint(1, 1000)))
        slug = f"{slugify(title_en)}-{year}-{i}"
        rows.append([
            aid, slug, title_ua, title_en, title_jp,
            fake_ua.paragraph(nb_sentences=4), f"https://picsum.photos/seed/{slug}/300/450",
            random.choice(STUDIOS),
            random.randint(1, 60000) if random.random() < 0.9 else None,
            random.randint(1, 180000) if random.random() < 0.9 else None,
            slug if random.random() < 0.6 else None,
            f"tt{random.randint(1000000, 9999999)}" if random.random() < 0.4 else None,
            year, duration, episodes,
            random.choice(MPAA[:-1] if not adult else MPAA) if random.random() < 0.9 else None,
            status, fmt, random.random() < 0.95,
        ])
        meta.append({"id": aid, "episodes": episodes, "status": status, "year": year})
    cols = ["anime_id", "slug", "title_ua", "title_en", "title_original", "anime_description",
            "cover_url", "production_studio", "mal_id", "anilist_id", "hikka_id", "imdb_id",
            "year_released", "avg_episode_duration", "episodes_count", "age_restriction",
            "anime_status", "anime_format", "available"]
    return cols, rows, meta


def gen_genres(animes, adult):
    pool = [g for g in GENRES if adult or g not in ADULT_GENRES]
    rows = []
    for a in animes:
        for g in random.sample(pool, random.randint(1, 5)):  # sample -> без дублів (PK)
            rows.append([a["id"], g])
    return ["anime_id", "genre_type"], rows


def gen_episodes(animes, fake_ua, max_eps):
    rows = []
    for a in animes:
        if a["status"] == "upcoming":
            continue
        total = min(a["episodes"], max_eps)
        studio = random.choice(LOC_STUDIOS) if random.random() < 0.8 else ""
        ltype = random.choice(LOC_TYPES) if studio else None
        for ep in range(1, total + 1):
            rows.append([
                a["id"], f"https://cdn.example.com/video/{a['id']}/{ep}.m3u8",
                f"Серія {ep}: {fake_ua.sentence(nb_words=3).rstrip('.')}",
                studio, ltype,
            ])
    return ["anime_id", "source_url", "episode_name", "localization_studio",
            "localization_type"], rows


def gen_upcoming(animes, now):
    rows = []
    for a in animes:
        if a["status"] not in ("ongoing", "upcoming"):
            continue
        start = a["episodes"] + 1 if a["status"] == "ongoing" else 1
        for k in range(random.randint(1, 3)):
            rows.append([a["id"], f"Серія {start + k}",
                         now + timedelta(days=7 * (k + 1), hours=random.randint(0, 23))])
    return ["anime_id", "episode_name", "episode_date"], rows


def gen_comments(users, animes, fake_ua, now, n):
    rows = []
    for _ in range(n):
        uid, ucreated = random.choice(users)
        created = rand_dt(ucreated, now)
        rows.append([uid, random.choice(animes)["id"], fake_ua.paragraph(nb_sentences=random.randint(1, 3)),
                     created, random.random() < 0.1])
    rows.sort(key=lambda r: r[3])  # щоб identity зростав разом із часом
    return ["author_id", "anime_id", "content", "created_at", "is_edited"], rows


def gen_list_units(users, animes, now, per_user_max):
    rows = []
    for uid, ucreated in users:
        for a in random.sample(animes, min(len(animes), random.randint(0, per_user_max))):
            status = random.choices(LIST_STATUSES, weights=[40, 30, 15, 15])[0]
            total = a["episodes"]
            if status == "finished":
                watched = total
            elif a["status"] == "upcoming":
                watched = 0
            else:
                watched = random.randint(0, max(total - 1, 0))
            repeat = random.choice([0, 0, 0, 1, 2]) if status == "finished" else 0
            started = rand_dt(max(ucreated, now - timedelta(days=700)), now).date()
            grade = random.randint(-5, 5) if (status != "watching" or random.random() < 0.3) else None
            rows.append([uid, a["id"], watched, repeat, started, status, grade])
    return ["user_id", "anime_id", "watched_episodes", "repeat_times", "started_watching",
            "list_unit_status", "grade"], rows


def gen_sessions(users, fake, now):
    rows, used = [], set()
    for uid, ucreated in users:
        for _ in range(random.randint(0, 3)):
            token = random.getrandbits(96 * 8).to_bytes(96, "big")  # рівно 96 байт
            if token in used:
                continue
            used.add(token)
            os_, br = random.choice(OSES), random.choice(BROWSERS)
            ua = fake.user_agent()
            rows.append([
                uid, token, now + timedelta(days=random.randint(1, 365)),
                random.choice(DEVICE_TYPES), f"{os_} / {br}", os_, br, ua,
                f"{fake.city()}, UA", fake.ipv4_public(),
            ])
    return ["user_id", "refresh_token", "expire_time", "device_type", "device_name",
            "os", "browser", "user_agent", "user_location", "ip_address"], rows


# ----------------------------------------------------------------- main
def main():
    p = argparse.ArgumentParser(description="Генератор seed-даних (INSERT) для PostgreSQL")
    p.add_argument("--users", type=int, default=100)
    p.add_argument("--animes", type=int, default=50)
    p.add_argument("--comments", type=int, default=500)
    p.add_argument("--max-episodes", type=int, default=26, help="макс. серій на аніме в таблиці episodes")
    p.add_argument("--list-per-user", type=int, default=15, help="макс. записів у списку на користувача")
    p.add_argument("--adult", action="store_true", help="включити ecchi/erotica/hentai та nc17")
    p.add_argument("--seed", type=int, default=None)
    p.add_argument("-o", "--output", default="seed.sql")
    args = p.parse_args()

    if args.seed is not None:
        random.seed(args.seed)
        Faker.seed(args.seed)
    fake_ua, fake_en, fake_jp = Faker("uk_UA"), Faker("en_US"), Faker("ja_JP")
    now = datetime.now(timezone.utc).replace(microsecond=0)
    now = now.replace(tzinfo=timezone.utc)

    u_cols, u_rows, users = gen_users(args.users, fake_en, now)
    a_cols, a_rows, animes = gen_animes(args.animes, fake_ua, fake_en, fake_jp, now, args.adult)

    with open(args.output, "w", encoding="utf-8") as out:
        out.write("-- Згенеровано gen_seed.py\nBEGIN;\n")
        out.write("\n-- Clear entries\n" + "\n".join([f"DELETE FROM {table};" for table in [
            "sessions", "anime_list_units", "comments", "upcoming_episodes", "episodes", "genres", "animes", "users"
        ]]) + "\n")
        emit(out, "users", u_cols, u_rows)
        emit(out, "animes", a_cols, a_rows)
        emit(out, "genres", *gen_genres(animes, args.adult))
        emit(out, "episodes", *gen_episodes(animes, fake_ua, args.max_episodes))
        emit(out, "upcoming_episodes", *gen_upcoming(animes, now))
        emit(out, "comments", *gen_comments(users, animes, fake_ua, now, args.comments))
        emit(out, "anime_list_units", *gen_list_units(users, animes, now, args.list_per_user))
        emit(out, "sessions", *gen_sessions(users, fake_en, now))
        out.write("\nCOMMIT;\n")
    print(f"Готово: {args.output}")


if __name__ == "__main__":
    main()

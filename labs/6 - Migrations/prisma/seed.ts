import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../generated/prisma/client";

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error("DATABASE_URL is not set");
}

const adapter = new PrismaPg({ connectionString });
const prisma = new PrismaClient({ adapter });

const PASSWORD_HASH =
  "$2b$12$LJ3m4ys3Lk0TDcUOqMRqGeAEIM4fP0Fv3sSzfMxHU0v4munYE2mKe";

async function main() {
  const existingUsers = await prisma.users.count();
  if (existingUsers > 0) {
    console.log("Database already seeded, skipping.");
    return;
  }

  await prisma.$transaction(async (tx) => {
    const [bilozorov, palamar, kryzhanovskyi, stalev, director] =
      await tx.users.createManyAndReturn({
        data: [
          {
            first_name: "Дмитро",
            last_name: "Білозеров",
            email: "bilozorov@example.com",
            password_hash: PASSWORD_HASH,
            date_of_birth: new Date("1994-07-28"),
          },
          {
            first_name: "Олександр",
            last_name: "Паламар",
            email: "palamar@example.com",
            password_hash: PASSWORD_HASH,
            date_of_birth: new Date("1987-06-15"),
          },
          {
            first_name: "Сергій",
            last_name: "Крижановський",
            email: "kryzhanovskyi@example.com",
            password_hash: PASSWORD_HASH,
            date_of_birth: new Date("1997-07-06"),
          },
          {
            first_name: "Євген",
            last_name: "Сталєв",
            email: "stalev@example.com",
            password_hash: PASSWORD_HASH,
            date_of_birth: new Date("1979-05-19"),
          },
          {
            first_name: "Андрій",
            last_name: "Шевченко",
            email: "shevchenko@example.com",
            password_hash: PASSWORD_HASH,
            date_of_birth: new Date("1980-01-30"),
          },
        ],
      });

    const [player1, player2, player3, player4] =
      await tx.player.createManyAndReturn({
        data: [
          {
            person_id: bilozorov.user_id,
            rating: 2600,
            sports_title: "INTERNATIONAL_MASTER_OF_SPORTS",
          },
          {
            person_id: palamar.user_id,
            rating: 2500,
            sports_title: "HONORED_MASTER_OF_SPORTS",
          },
          {
            person_id: kryzhanovskyi.user_id,
            rating: 2450,
            sports_title: "INTERNATIONAL_MASTER_OF_SPORTS",
          },
          {
            person_id: stalev.user_id,
            rating: 2550,
            sports_title: "HONORED_MASTER_OF_SPORTS",
          },
        ],
      });

    const [clubPyramida, clubBrooklyn] = await tx.club.createManyAndReturn({
      data: [
        {
          club_name: 'Більярдний клуб "Піраміда"',
          city: "Київ",
          address: "вул. Хрещатик, 22",
          is_active: true,
        },
        {
          club_name: "Brooklyn Billiards",
          city: "Одеса",
          address: "вул. Дерибасівська, 15",
          is_active: true,
        },
        {
          club_name: "CueSport Arena",
          city: "Харків",
          address: "вул. Сумська, 48",
          is_active: false,
        },
      ],
    });

    const [table1, table2] = await tx.billiard_table.createManyAndReturn({
      data: [
        {
          club_id: clubPyramida.club_id,
          table_number: 1,
          table_type: "PYRAMID_12FT",
          table_status: "AVAILABLE",
        },
        {
          club_id: clubPyramida.club_id,
          table_number: 2,
          table_type: "POOL_9FT",
          table_status: "AVAILABLE",
        },
        {
          club_id: clubPyramida.club_id,
          table_number: 3,
          table_type: "SNOOKER_12FT",
          table_status: "MAINTENANCE",
        },
        {
          club_id: clubBrooklyn.club_id,
          table_number: 1,
          table_type: "PYRAMID_12FT",
          table_status: "AVAILABLE",
        },
        {
          club_id: clubBrooklyn.club_id,
          table_number: 2,
          table_type: "POOL_8FT",
          table_status: "OCCUPIED",
        },
      ],
    });

    const [teamLegends, teamChampions] = await tx.team.createManyAndReturn({
      data: [
        { team_name: "Київські Легенди", captain_id: player2.player_id },
        { team_name: "Чемпіони Піраміди", captain_id: player1.player_id },
      ],
    });

    await tx.team_member.createMany({
      data: [
        { team_id: teamLegends.team_id, player_id: player2.player_id },
        { team_id: teamLegends.team_id, player_id: player4.player_id },
        { team_id: teamChampions.team_id, player_id: player1.player_id },
        { team_id: teamChampions.team_id, player_id: player3.player_id },
      ],
    });

    const [tournament1, tournament2, tournament3] =
      await tx.tournament.createManyAndReturn({
        data: [
          {
            club_id: clubPyramida.club_id,
            director_id: director.user_id,
            tournament_name: "Кубок Чемпіонів — Піраміда",
            max_participants: 16,
            entry_fee: 500.0,
            prize_pool: 30000.0,
            discipline: "FREE_PYRAMID",
            format: "SINGLE_ELIMINATION",
            tournament_status: "ONGOING",
            registration_deadline: new Date("2026-09-01T18:00:00+03:00"),
            start_date: new Date("2026-09-15T10:00:00+03:00"),
            end_date: null,
          },
          {
            club_id: clubBrooklyn.club_id,
            director_id: director.user_id,
            tournament_name: "Одеський Турнір — Пул 9-ка",
            max_participants: 8,
            entry_fee: 300.0,
            prize_pool: 12000.0,
            discipline: "POOL_9_BALL",
            format: "ROUND_ROBIN",
            tournament_status: "ANNOUNCED",
            registration_deadline: new Date("2026-10-20T23:59:00+03:00"),
            start_date: new Date("2026-11-01T10:00:00+03:00"),
            end_date: new Date("2026-11-03T20:00:00+03:00"),
          },
          {
            club_id: clubPyramida.club_id,
            director_id: director.user_id,
            tournament_name: "Командна Битва Титанів",
            max_participants: 8,
            entry_fee: 1000.0,
            prize_pool: 50000.0,
            discipline: "COMBINED_PYRAMID",
            format: "SINGLE_ELIMINATION",
            tournament_status: "REGISTRATION_OPEN",
            registration_deadline: new Date("2026-10-10T23:59:00+03:00"),
            start_date: new Date("2026-10-20T10:00:00+03:00"),
            end_date: new Date("2026-10-22T20:00:00+03:00"),
          },
        ],
      });

    const [predator, aramith, simonis] = await tx.sponsor.createManyAndReturn({
      data: [
        {
          sponsor_name: "Predator Cues",
          website_url: "https://www.predatorcues.com",
          contact_email: "events@predatorcues.com",
        },
        {
          sponsor_name: "Aramith",
          website_url: "https://www.aramith.com",
          contact_email: "partners@aramith.com",
        },
        {
          sponsor_name: "Simonis Cloth",
          website_url: "https://www.iwansimonis.com",
          contact_email: "sponsorship@iwansimonis.com",
        },
      ],
    });

    await tx.tournament_sponsor.createMany({
      data: [
        {
          tournament_id: tournament1.tournament_id,
          sponsor_id: predator.sponsor_id,
          contribution_amount: 15000.0,
        },
        {
          tournament_id: tournament1.tournament_id,
          sponsor_id: aramith.sponsor_id,
          contribution_amount: 10000.0,
        },
        {
          tournament_id: tournament2.tournament_id,
          sponsor_id: aramith.sponsor_id,
          contribution_amount: 5000.0,
        },
        {
          tournament_id: tournament3.tournament_id,
          sponsor_id: predator.sponsor_id,
          contribution_amount: 20000.0,
        },
        {
          tournament_id: tournament3.tournament_id,
          sponsor_id: simonis.sponsor_id,
          contribution_amount: 15000.0,
        },
      ],
    });

    await tx.tournament_registration.createMany({
      data: [
        {
          tournament_id: tournament1.tournament_id,
          player_id: player1.player_id,
          seed_number: 1,
          payment_status: "PAID",
          final_placement: 1,
          prize_won: 15000.0,
        },
        {
          tournament_id: tournament1.tournament_id,
          player_id: player2.player_id,
          seed_number: 2,
          payment_status: "PAID",
          final_placement: 2,
          prize_won: 9000.0,
        },
        {
          tournament_id: tournament1.tournament_id,
          player_id: player3.player_id,
          seed_number: 3,
          payment_status: "PAID",
          final_placement: 3,
          prize_won: 6000.0,
        },
        {
          tournament_id: tournament1.tournament_id,
          player_id: player4.player_id,
          seed_number: 4,
          payment_status: "PAID",
          final_placement: 4,
          prize_won: 0.0,
        },
        {
          tournament_id: tournament2.tournament_id,
          player_id: player1.player_id,
          payment_status: "PAID",
          prize_won: 0.0,
        },
        {
          tournament_id: tournament2.tournament_id,
          player_id: player2.player_id,
          payment_status: "PENDING",
          prize_won: 0.0,
        },
        {
          tournament_id: tournament2.tournament_id,
          player_id: player3.player_id,
          payment_status: "PENDING",
          prize_won: 0.0,
        },
        {
          tournament_id: tournament3.tournament_id,
          team_id: teamLegends.team_id,
          payment_status: "PAID",
          prize_won: 0.0,
        },
        {
          tournament_id: tournament3.tournament_id,
          team_id: teamChampions.team_id,
          payment_status: "PENDING",
          prize_won: 0.0,
        },
      ],
    });

    const [match1, match2, match3] = await tx.match.createManyAndReturn({
      data: [
        {
          tournament_id: tournament1.tournament_id,
          table_id: table1.table_id,
          stage: "SEMIFINAL",
          race_to_frames: 5,
          match_status: "COMPLETED",
          scheduled_at: new Date("2026-09-15T10:00:00+03:00"),
          started_at: new Date("2026-09-15T10:05:00+03:00"),
          finished_at: new Date("2026-09-15T11:30:00+03:00"),
        },
        {
          tournament_id: tournament1.tournament_id,
          table_id: table2.table_id,
          stage: "SEMIFINAL",
          race_to_frames: 5,
          match_status: "COMPLETED",
          scheduled_at: new Date("2026-09-15T10:00:00+03:00"),
          started_at: new Date("2026-09-15T10:10:00+03:00"),
          finished_at: new Date("2026-09-15T12:00:00+03:00"),
        },
        {
          tournament_id: tournament1.tournament_id,
          table_id: table1.table_id,
          stage: "FINAL",
          race_to_frames: 7,
          match_status: "COMPLETED",
          scheduled_at: new Date("2026-09-15T14:00:00+03:00"),
          started_at: new Date("2026-09-15T14:10:00+03:00"),
          finished_at: new Date("2026-09-15T16:45:00+03:00"),
        },
      ],
    });

    await tx.match_participant.createMany({
      data: [
        {
          match_id: match1.match_id,
          player_id: player1.player_id,
          frames_won: 5,
          side: "SIDE_1",
          is_winner: true,
        },
        {
          match_id: match1.match_id,
          player_id: player4.player_id,
          frames_won: 3,
          side: "SIDE_2",
          is_winner: false,
        },
        {
          match_id: match2.match_id,
          player_id: player2.player_id,
          frames_won: 5,
          side: "SIDE_1",
          is_winner: true,
        },
        {
          match_id: match2.match_id,
          player_id: player3.player_id,
          frames_won: 4,
          side: "SIDE_2",
          is_winner: false,
        },
        {
          match_id: match3.match_id,
          player_id: player1.player_id,
          frames_won: 7,
          side: "SIDE_1",
          is_winner: true,
        },
        {
          match_id: match3.match_id,
          player_id: player2.player_id,
          frames_won: 5,
          side: "SIDE_2",
          is_winner: false,
        },
      ],
    });
  });

  const [clubs, tournaments, sponsors, matches] = await Promise.all([
    prisma.club.count(),
    prisma.tournament.count(),
    prisma.sponsor.count(),
    prisma.match.count(),
  ]);

  console.log("Database seeded successfully:", {
    clubs,
    tournaments,
    sponsors,
    matches,
  });
}

main()
  .catch((err) => {
    console.error("Seed failed:", err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

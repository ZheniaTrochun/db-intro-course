import { prisma } from "./prisma";

interface PlayerPair {
  player_1_id: number;
  player_1_name: string;
  player_2_id: number;
  player_2_name: string;
}

async function getPossiblePlayerPairs(): Promise<PlayerPair[]> {
  const players = await prisma.player.findMany({
    select: {
      player_id: true,
      users: {
        select: {
          first_name: true,
          last_name: true,
        },
      },
    },
    orderBy: {
      player_id: "asc",
    },
  });

  const pairs: PlayerPair[] = [];

  for (let i = 0; i < players.length; i++) {
    for (let j = i + 1; j < players.length; j++) {
      const p1 = players[i]!;
      const p2 = players[j]!;

      pairs.push({
        player_1_id: p1.player_id,
        player_1_name: `${p1.users.first_name} ${p1.users.last_name}`,
        player_2_id: p2.player_id,
        player_2_name: `${p2.users.first_name} ${p2.users.last_name}`,
      });
    }
  }

  return pairs;
}

async function main() {
  const pairs = await getPossiblePlayerPairs();
  console.table(pairs);
}

main()
  .catch((err) => {
    console.error("Query failed:", err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

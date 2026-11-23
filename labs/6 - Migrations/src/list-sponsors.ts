import { prisma } from "./prisma";

async function main() {
  const sponsors = await prisma.sponsor.findMany({
    orderBy: { sponsor_id: "asc" },
    include: {
      tournament_sponsor: {
        orderBy: { tournament_id: "asc" },
        include: {
          tournament: {
            select: {
              tournament_name: true,
              club: {
                select: {
                  club_name: true,
                  is_active: true,
                },
              },
            },
          },
        },
      },
    },
  });

  const rows = sponsors.flatMap((s) =>
    s.tournament_sponsor.map((ts) => ({
      sponsor_id: s.sponsor_id,
      sponsor_name: s.sponsor_name,
      contact_email: s.contact_email,
      tournament: ts.tournament.tournament_name,
      club: ts.tournament.club.club_name,
      club_active: ts.tournament.club.is_active,
      contribution: Number(ts.contribution_amount),
    }))
  );

  console.table(rows);
}

main()
  .catch((err) => {
    console.error("Query failed:", err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

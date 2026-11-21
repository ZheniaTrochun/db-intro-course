import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../../generated/prisma/client";

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

async function main() {
  const item = await prisma.wishlist_items.findFirst();
  if (!item) {
    throw new Error("У wishlist_items немає рядків. Спочатку додайте товар.");
  }

  await prisma.comments.create({
    data: {
      item_id: item.item_id,
      author_name: "Олена",
      rating: 5,
      text: "Саме те, що хотіла",
    },
  });

  const items = await prisma.wishlist_items.findMany({
    include: { comments: true },
  });
  console.log(JSON.stringify(items, null, 2));
}

main()
  .finally(() => prisma.$disconnect());

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from './generated/prisma/client';

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});
const prisma = new PrismaClient({ adapter });

async function main() {
  const product = await prisma.product.findFirst();
  const client = await prisma.client.findFirst();

  if (!product || !client) {
    throw new Error('У базі немає тестових товарів або клієнтів');
  }

  // 1. Перевірка Міграції №2 (поле is_featured)
  const updatedProduct = await prisma.product.update({
    where: { product_id: product.product_id },
    data: { is_featured: true },
  });
  console.log('Оновлений товар (is_featured):', {
    id: updatedProduct.product_id,
    name: updatedProduct.product_name,
    is_featured: updatedProduct.is_featured,
  });

  // 2. Перевірка Міграції №1 (створення запису в новій таблиці review)
  const review = await prisma.review.create({
    data: {
      rating: 5,
      comment: 'Чудовий товар, швидка доставка!',
      product_id: product.product_id,
      client_id: client.client_id,
    },
  });
  console.log('Створений відгук:', review);

  // 3. Запит пов'язаних записів через include (product -> review)
  const withReviews = await prisma.product.findMany({
    where: { review: { some: {} } },
    include: { review: true },
  });
  console.log('Товари з відгуками (include):');
  console.log(JSON.stringify(withReviews, null, 2));

  // 4. Перевірка CHECK-обмеження (рейтинг 10 має відхилитися базою PostgreSQL)
  try {
    await prisma.review.create({
      data: {
        rating: 10,
        comment: 'Невалідний рейтинг',
        product_id: product.product_id,
        client_id: client.client_id,
      },
    });
    console.log('ПОМИЛКА: рейтинг 10 збережено!');
  } catch (e) {
    console.log('Відхилено базою:', (e as Error).message);
  }
}

main()
  .catch((e) => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });
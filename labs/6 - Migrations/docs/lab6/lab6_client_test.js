const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function main() {
  // 1. Створюємо категорію товару (нова таблиця з міграції add-product-category)
  const category = await prisma.product_category.create({
    data: {
      name: 'Кабелі та конектори',
      description: 'Кабельна продукція та аксесуари',
    },
  });
  console.log('Created category:', category);

  // 2. Оновлюємо наявний товар: призначаємо категорію, встановлюємо reorder_quantity, зберігаємо notes
  const updated = await prisma.product.update({
    where: { sku_code: 'SKU-UTP-5E' },
    data: {
      category_id: category.category_id,
      reorder_quantity: 5,
    },
    include: { product_category: true },
  });
  console.log('Updated product:', {
    product_id: updated.product_id,
    sku_code: updated.sku_code,
    notes: updated.notes,
    reorder_quantity: updated.reorder_quantity,
    category: updated.product_category?.name,
  });

  // 3. Читаємо товари з їхньою категорією (перевірка зв'язку)
  const products = await prisma.product.findMany({
    where: { category_id: category.category_id },
    include: { product_category: true },
  });
  console.log('Products in category:', products.map((p) => `${p.sku_code} (${p.product_category?.name})`));

  // 4. Очищаємо демонстраційний рядок, щоб не засмічувати БД (необов'язково)
  await prisma.product.update({
    where: { sku_code: 'SKU-UTP-5E' },
    data: { category_id: null, reorder_quantity: 0 },
  });
  await prisma.product_category.delete({ where: { category_id: category.category_id } });
  console.log('Cleanup done.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

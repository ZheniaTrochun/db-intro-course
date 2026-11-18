// Скрипт перевірки роботи схеми та міграцій за допомогою Prisma Client
// Лабораторна робота №6 — Інтернет-магазин електроніки «TechStore»

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    console.log('--- 1. Додавання нових відгуків у таблицю reviews ---');
    await prisma.$executeRawUnsafe('TRUNCATE TABLE reviews RESTART IDENTITY;');

    const review1 = await prisma.reviews.create({
        data: {
            product_id: 1,
            customer_id: 1,
            rating: 5,
            comment: 'Чудовий ігровий ноутбук ASUS ROG, тягне всі сучасні ігри та роботу з графікою!'
        }
    });
    console.log('Створено відгук №1:', review1);

    const review2 = await prisma.reviews.create({
        data: {
            product_id: 3,
            customer_id: 2,
            rating: 5,
            comment: 'iPhone 16 Pro працює дуже швидко, камера та автономність на найвищому рівні.'
        }
    });
    console.log('Створено відгук №2:', review2);

    console.log('\n--- 2. Вибірка товарів разом із новими відгуками та прапорцем is_available ---');

    const productsWithReviews = await prisma.products.findMany({
        where: {
            product_id: { in: [1, 3] }
        },
        include: {
            categories: true,
            reviews: {
                include: {
                    customers: {
                        select: { full_name: true, email: true }
                    }
                }
            }
        }
    });

    console.log(JSON.stringify(productsWithReviews, null, 2));
}

main()
    .catch((e) => {
        console.error('Помилка під час виконання запитів Prisma:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });


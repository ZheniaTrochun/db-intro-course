## Опис міграцій

### Міграція 1: `add-review-table`
* **Опис змін:** Додано модель `review` для відгуків та зв'язок з `product`.
* **Код ДО:** Таблиці не існувало.
* **Код ПІСЛЯ:**
```prisma
model review {
  id         Int     @id @default(autoincrement())
  rating     Int
  comment    String?
  product    product @relation(fields: [product_id], references: [product_id])
  product_id Int
}
```

### Міграція 2: `add-product-field`
* **Опис змін:** До моделі `product` додано логічне поле `inStock`.
* **Код ДО:**
```prisma
model product {
  product_id                 Int                @id @default(autoincrement())
  brand_id                   Int
  product_title              String             @db.VarChar(100)
  product_price              Decimal            @db.Decimal(8, 2)
  product_expiration_date    DateTime?          @db.Date
  product_volume             String             @db.VarChar(50)
  product_pao_months         Int?
  product_application_method String?
  order_item                 order_item[]
  brand                      brand              @relation(fields: [brand_id], references: [brand_id], onDelete: NoAction, onUpdate: NoAction)
  product_category           product_category[]
  review                     review[]
}
```
* **Код ПІСЛЯ:**
```prisma
model product {
  product_id                 Int                @id @default(autoincrement())
  brand_id                   Int
  product_title              String             @db.VarChar(100)
  product_price              Decimal            @db.Decimal(8, 2)
  product_expiration_date    DateTime?          @db.Date
  product_volume             String             @db.VarChar(50)
  product_application_method String?
  order_item                 order_item[]
  brand                      brand              @relation(fields: [brand_id], references: [brand_id], onDelete: NoAction, onUpdate: NoAction)
  product_category           product_category[]
  review                     review[]
  inStock                    Boolean            @default(true)
}
```

### Міграція 3: `drop-old-column`
* **Опис змін:** З моделі `product` видалено колонку `product_pao_months`.
* **Код ДО:**
```prisma
model product {
  product_id                 Int                @id @default(autoincrement())
  brand_id                   Int
  product_title              String             @db.VarChar(100)
  product_price              Decimal            @db.Decimal(8, 2)
  product_expiration_date    DateTime?          @db.Date
  product_volume             String             @db.VarChar(50)
  product_pao_months         Int?
  product_application_method String?
  order_item                 order_item[]
  brand                      brand              @relation(fields: [brand_id], references: [brand_id], onDelete: NoAction, onUpdate: NoAction)
  product_category           product_category[]
  review                     review[]
  inStock                    Boolean            @default(true)
}
```
* **Код ПІСЛЯ:**
```prisma
model product {
  product_id                 Int                @id @default(autoincrement())
  brand_id                   Int
  product_title              String             @db.VarChar(100)
  product_price              Decimal            @db.Decimal(8, 2)
  product_expiration_date    DateTime?          @db.Date
  product_volume             String             @db.VarChar(50)
  product_application_method String?
  order_item                 order_item[]
  brand                      brand              @relation(fields: [brand_id], references: [brand_id], onDelete: NoAction, onUpdate: NoAction)
  product_category           product_category[]
  review                     review[]
  inStock                    Boolean            @default(true)
}
```

### Міграція 4: `add-supplier-table`
* **Опис змін:** Додано нову самостійну модель `supplier` для постачальників косметики.
* **Код ДО:** Моделі не існувало.
* **Код ПІСЛЯ:**
```prisma
model supplier {
  supplier_id  Int     @id @default(autoincrement())
  name         String  @db.VarChar(100)
  phone_number String  @unique @db.VarChar(100)
  email        String  @unique @db.VarChar(100)
  brand        brand[]
}
```

### Міграція 5: `add-brand-country`
* **Опис змін:** До моделі `brand` додано необов'язкове поле країни `brand_country`.
* **Код ДО:**
```prisma
model brand {
  brand_id    Int    @id @default(autoincrement())
  brand_title String @unique @db.VarChar(100)
}
```
* **Код ПІСЛЯ:**
```prisma
model brand {
  brand_id      Int     @id @default(autoincrement())
  brand_title   String  @unique @db.VarChar(100)
  brand_country String?
}
```

### Міграція 6: `add-bonuses`
* **Опис змін:** До моделі `customer` додано поле бонусів `bonuses` із дефолтним значенням 0.
* **Код ДО:**
```prisma
model customer {
  customer_id           Int      @id @default(autoincrement())
  customer_first_name   String   @db.VarChar(100)
  customer_last_name    String   @db.VarChar(100)
  customer_email        String   @unique @db.VarChar(100)
  customer_phone_number String   @unique @db.VarChar(100)
  customer_birth_date   DateTime @db.Date
  orders                orders[]
}
```
* **Код ПІСЛЯ:**
```prisma
model customer {
  customer_id           Int      @id @default(autoincrement())
  customer_first_name   String   @db.VarChar(100)
  customer_last_name    String   @db.VarChar(100)
  customer_email        String   @unique @db.VarChar(100)
  customer_phone_number String   @unique @db.VarChar(100)
  customer_birth_date   DateTime @db.Date
  orders                orders[]
  bonuses				Int?	 @default(0)
}
```

### Міграція 7: `make-supplier-fields-unique`
* **Опис змін:** Полям `phone_number` та `email` постачальника додано унікальність `@unique`.
* **Код ДО:** Поля були звичайними рядками.
* **Код ПІСЛЯ:**
```prisma
model supplier {
  supplier_id		    Int		@id @default(autoincrement())
  name	        String  @db.VarChar(100)
  phone_number	String  @unique @db.VarChar(100)
  email	        String  @unique @db.VarChar(100)
  brand         brand[]
}
```

### Міграція 8: `brand-supplier-connection`
* **Опис змін:** Зв'язано бренд та постачальника через обов'язковий `supplier_id` з правилом `onDelete: NoAction`.
* **Код ДО:** Бренди та постачальники не були зв'язані.
* **Код ПІСЛЯ:**
```prisma
model brand {
  brand_id      Int      @id @default(autoincrement())
  brand_title   String   @unique @db.VarChar(100)
  brand_country String?
  product       product[]
  supplier_id   Int
  supplier      supplier @relation(fields: [supplier_id], references: [supplier_id], onDelete: NoAction)
}
```

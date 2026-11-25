- ## 1NF:
  - `property`-
  - `property_owner`-
  - `tenant`-
  - `realtor`-
  - `lease_agreement`-
  - `applications`-

- ## 2NF:
  - `property`-
  - `property_owner`-
  - `tenant`-
  - `realtor`-
  - `lease_agreement`-
  - `applications`-

- ## 3NF:
  - `property`- Вимоги порушено :
    - Можливе порушення після розбиття адреси: Якщо виділити city (місто) та street (вулицю), або якщо індекс/район залежить від міста/вулиці, виникає транзитивна залежність property_id -> city_id -> city_name або дублювання назв міст (аномалія оновлення при перейменуванні міста).

  - `property_owner`- Вимоги виконані.
  - `tenant`- Вимоги виконані.
  - `realtor`- Вимоги виконані.

  - `lease_agreement`- Вимоги порушено :
    - Неключовий атрибут agency_commission транзитивно залежить від lease_id через realtor_id (який визначає commission_rate у REALTOR) та rental_amount. Якщо змінити rental_amount (як ти зробив у запиті №7: змінив 15000.00 на 17000.00, але agency_commission залишилася 750.00 замість 850.00!), виникає аномалія оновлення та суперечність даних.
    - Крім того, якщо договір укладається на основі схваленої заявки (APPLICATION), то пара (tenant_id, property_id) дублюється між APPLICATION та LEASE_AGREEMENT (або в LEASE_AGREEMENT варто посилатися на application_id, якщо договір завжди випливає із заявки).

  - `applications`- Вимоги порушено :
    - Текстове поле status ('в обробці', 'схвалено', 'відхилено') повторюється в кожному рядку. Винесення статусів у окрему таблицю-довідник APPLICATION_STATUS(status_id, status_name) усуває дублювання рядкових літералів та аномалії при перейменуванні статусу.

- ## Виправлення:
  - `property`:
    1. Розбити adress на атомарні стовпці: city, street, building_number, apartment_number;
    2.
  - `property_owner`:
    1. Розбити full_name на last_name, first_name, middle_name;
    2.
  - `tenant`:
    1. Розбити full_name на last_name, first_name, middle_name;
    2.
  - `realtor`:
    1. Розбити full_name на last_name, first_name, middle_name;
    2.
  - `lease_agreement`:
    1. прибрати надлишковий стовпець agency_commission (оскільки ставка комісії commission_rate зберігається в REALTOR, а сума комісії однозначно обчислюється як rental_amount \* commission_rate / 100 у VIEW або запиті) — це повністю усуває аномалію розсинхронізації комісії при зміні орендної плати.;
    2.
  - `applications`:
    1. ;
    2.

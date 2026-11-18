

# Repositorio del curso "Bases de datos"

Este repositorio contiene recursos y configuraciones del entorno para el curso de bases de datos.

## PCO "Bases de datos" (flujo IM)

- 6 trabajos de laboratorio (10 puntos cada uno)
- Examen (20 puntos)
- Examen (20 puntos)
- Presentaciones (20 puntos) - opcionales
- Puntos extra por participación en las clases

## PCO "Organización de bases de datos" (flujo IO)

- 6 trabajos de laboratorio (10 puntos cada uno)
- Examen (20 puntos)
- Puntos extra por participación en las clases
- Puntos extra por ejercicios de SQL

Nota final = (`puntos de laboratorio` + `puntos del examen`) * 1.25 + `puntos extra`

## Material del curso

El material de las clases está disponible en el directorio [lectures](lectures/):

- [Clase 1 - Introducción](lectures/01%20-%20intro)
- [Clase 2 - Diagramas ER](lectures/02%20-%20ER%20diagrams)
- [Clase 3 - Tablas, filas, columnas](lectures/03%20-%20Tables,%20rows,%20columns)
- [Clase 4 - SQL parte 1](lectures/04%20-%20DML%20basics)
- [Clase 5 - SQL parte 2 - JOIN y operaciones de conjuntos](lectures/05%20-%20JOINs%20and%20set%20operations)
- [Clase 6 - SQL parte 3 - GROUP BY y funciones de ventana](lectures/06%20-%20GROUP%20BY%20and%20window%20functions)
- [Clase 7 - SQL parte 4 - Subconsultas y CTE](lectures/07%20-%20Subqueries%20and%20CTE)
- [Clase 8 - Normalización](lectures/08%20-%20Normalisation)
- [Clase 9 - Migraciones](lectures/09%20-%20Migrations)
- [Clase 10 - Transacciones](lectures/10%20-%20Transactions)
- [Clase 11-12 - Índices](lectures/11-12%20-%20Indices)
- [Clase 13 - Desnormalización](lectures/13%20-%20Denormalisation)
- [Clase 14 - Organización física de datos en disco](lectures/14%20-%20Data%20storage%20on%20disk)
- [Clase 15 - Bases de datos no relacionales (NoSQL)](lectures/15%20-%20Non-relational%20DBMS)

Las instrucciones y materiales para los trabajos de laboratorio están disponibles en el directorio [labs](labs/):

- [Trabajo de laboratorio 1 - Diagramas ER](labs/1%20-%20ER%20Diagram/lab_1.md)
- [Trabajo de laboratorio 2 - DDL](labs/2%20-%20DDL/lab_2.md)
- [Trabajo de laboratorio 3 - OLTP](labs/3%20-%20OLTP/lab_3.md)
- [Trabajo de laboratorio 4 - OLAP](labs/4%20-%20OLAP/lab_4.md)
- [Trabajo de laboratorio 5 - Normalización](labs/5%20-%20Normalization/lab_5.md)
- [Trabajo de laboratorio 6 - Migraciones](labs/6%20-%20Migrations/lab_6.md)

[Guía rápida del material](./sql-cheat-sheet.md)  
[Glosario de términos](./glossary.md)

El material adicional del curso y las tareas se agregarán a este repositorio durante el semestre.

## Descripción

Este repositorio proporciona un entorno de base de datos listo para usar mediante contenedores Docker.  
El entorno incluye:

- Servidor de base de datos PostgreSQL
- Interfaz web pgAdmin para la administración de la base de datos

## Prerrequisitos

Antes de comenzar, asegúrate de haber instalado las siguientes herramientas:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Inicio

### Configuración del entorno

1. Clona este repositorio:
   ```bash
   git clone https://github.com/ZheniaTrochun/db-intro-course.git
   cd db-intro-course
   ```

2. Inicia los contenedores:
   ```bash
   docker-compose up -d
   ```

3. Para detener los contenedores, ejecuta:
   ```bash
   docker-compose down
   ```

## Servicios

### PostgreSQL

- **Puerto**: 5432
- **Usuario**: postgres
- **Contraseña**: password123
- **Scripts de inicialización**: Coloca tus scripts SQL en el directorio `init-scripts` para que se ejecuten al iniciar el contenedor

### pgAdmin

- **URL**: http://localhost:8080
- **Correo electrónico**: root@kpi.edu
- **Contraseña**: password123

## Conexión a la base de datos

### Usar pgAdmin

1. Abre http://localhost:8080 en tu navegador
2. Inicia sesión con las credenciales indicadas anteriormente
3. Agrega un nuevo servidor con la siguiente configuración:
   - Nombre: Cualquier nombre a tu elección
   - Host: postgres
   - Puerto: 5432
   - Usuario: postgres
   - Contraseña: password123

### Usar la línea de comandos

```bash
docker exec -it db-intro-course_postgres_1 psql -U postgres
```

## Persistencia de datos

Los datos de la base de datos se almacenan en un volumen de Docker:
- `postgres_data`: Datos de PostgreSQL
- `pgadmin_data`: Configuración de pgAdmin

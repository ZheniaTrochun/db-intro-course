# Introduction to Databases Course Repository

This repository contains resources and environment setup for the Introduction to Databases course.

## Course Materials

Lecture materials are available in the [lectures](lectures/) directory:

- [Lecture 1 - Introduction](lectures/1%20-%20intro)
- [Lecture 2 - ER Diagrams](lectures/2%20-%20ER%20diagrams)
- [Lecture 3 - Tables, rows, columns](lectures/3%20-%20Tables,%20rows,%20columns)
- [Lecture 4 - SQL part 1](lectures/4%20-%20DML%20basics)
- [Lecture 5 - SQL part 2 - JOINs and set operations](lectures/5%20-%20JOINs%20and%20set%20operations)
- [Lecture 6 - SQL part 3 - GROUP BY and Window Functions](lectures/6%20-%20GROUP%20BY%20and%20window%20functions)
- [Lecture 7 - SQL part 4 - Subqueries and CTE](lectures/7%20-%20Subqueries%20and%20CTE)
- [Lecture 8-9 - Indices](lectures/8-9%20-%20Indices)
- [Lecture 10 - Transactions](lectures/10%20-%20Transactions)
- [Lecture 11 - Normalisation](lectures/11%20-%20Normalisation)

Additional course materials and assignments will be added to this repository throughout the semester.

## Overview

This repository provides a ready-to-use database environment using Docker containers. It includes:

- PostgreSQL database server
- pgAdmin web interface for database management

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

### Setting Up the Environment

1. Clone this repository:
   ```
   git clone https://github.com/ZheniaTrochun/db-intro-course.git
   cd db-intro-course
   ```

2. Start the Docker containers:
   ```
   docker-compose up -d
   ```

3. To stop the containers:
   ```
   docker-compose down
   ```

## Services

### PostgreSQL

- **Port**: 5432
- **Username**: postgres
- **Password**: password123
- **Initialization Scripts**: Place your SQL scripts in the `init-scripts` directory to have them executed when the container starts

### pgAdmin

- **URL**: http://localhost:8080
- **Email**: root@kpi.edu
- **Password**: password123

## Connecting to the Database

### Using pgAdmin

1. Open http://localhost:8080 in your browser
2. Log in with the credentials mentioned above
3. Add a new server with the following details:
   - Name: Any name you prefer
   - Host: postgres
   - Port: 5432
   - Username: postgres
   - Password: password123

### Using Command Line

```bash
docker exec -it db-intro-course_postgres_1 psql -U postgres
```

## Data Persistence

The database data is persisted in Docker volumes:
- `postgres_data`: PostgreSQL data
- `pgadmin_data`: pgAdmin configuration

## License

This project is licensed for educational purposes only.

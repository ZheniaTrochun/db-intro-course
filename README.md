# Introduction to Databases Course Repository

This repository contains resources and environment setup for the Introduction to Databases course.

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
   git clone <repository-url>
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

## Course Materials

Additional course materials and assignments will be added to this repository throughout the semester.

## License

This project is licensed for educational purposes only.

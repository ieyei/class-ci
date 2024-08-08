# flyway example

This project is a practical guide to understanding and using Flyway. Follow the steps below to proceed.

## Environment

- H2 DB
- Gradle
- Java 11
- Spring Boot 3.2.3

## Step 1: Project Setup

Clone this project to your local system. Then, navigate to the root directory of the project.

## Step 2: Database Migration

This project uses Flyway to manage database migrations. The migration scripts are located in the `src/main/resources/db/migration` directory.

The first script creates a `PERSON` table:

```sql:src/main/resources/db/migration/V1_1_0__my_first_migration.sql
create table PERSON (
    ID int not null,
    NAME varchar(100) not null
);
```

The second script inserts some data into the `PERSON` table:

```sql:src/main/resources/db/migration/V2_1_0__my_first_migration2.sql
insert into PERSON (ID, NAME) values (1, 'Neal');
insert into PERSON (ID, NAME) values (2, 'Mr. Foo');
insert into PERSON (ID, NAME) values (3, 'Ms. Bar');
```

## Step 3: Build and Run the Application

After completing the migrations, you can build and run the application. The application is written in Spring Boot, with `FlywayExampleApplication` as the main class.

To build the application, run the following command in the project root directory:

```bash
./gradlew build
```

This will compile the application and run any tests. If the build is successful, it will also create an executable JAR file in the `build/libs` directory.

To run the application, you can use the `bootJar` task:

```bash
./gradlew bootJar
```

This will start the application. If it starts successfully, you should see output indicating that the application is running.

## Step 4: Verify the Results

After starting the application, open a web browser and navigate to `http://localhost:8080` to verify the results.



hello
hello

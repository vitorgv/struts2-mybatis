# Struts2 + MyBatis Person Registry

A lightweight CRUD sample that demonstrates how to combine **Apache Struts 2** with **MyBatis** to persist `Person` records (id, name, surname, birth date, age, insert/update timestamps) in an in-memory H2 database.

## Features

- Full CRUD flow (list, create, edit, delete) for `Person` entities.
- MyBatis mapper layer with SQL mappings, automatic schema bootstrap, and flash messages after save/delete.
- Custom Struts type converter for seamless HTML5 date inputs mapped to `java.time.LocalDate`.
- Preloaded sample data plus automatic age calculation from the supplied birth date.

## Tech Stack

- Java 17
- Apache Struts 2.5+ (6.3.0) with JSP views
- MyBatis 3.5
- H2 in-memory database
- Maven (WAR packaging) + Jetty Maven Plugin for local runs

## Getting Started

### Prerequisites

- Java 17 JDK on your PATH (`java -version`)
- Apache Maven 3.9+

### Build

```bash
mvn clean package
```

The command produces `target/struts2-mybatis-app.war` that you can deploy to any Servlet 5+ container.

### Run locally (Jetty)

```bash
mvn jetty:run
```

Then open `http://localhost:8080/struts2-mybatis-app/persons` to interact with the UI.

The embedded H2 database is in-memory; restarting the app will recreate the schema and repopulate the sample rows defined in `src/main/resources/db/schema.sql`.

## Project Layout

```
src
├── main
│   ├── java
│   │   └── com.example.struts2mybatis
│   │       ├── action        # Struts actions
│   │       ├── converter     # LocalDate converter for forms
│   │       ├── model         # Person entity
│   │       └── persistence   # MyBatis mapper + service helpers
│   ├── resources
│   │   ├── db/schema.sql     # H2 bootstrap script
│   │   ├── mappers           # MyBatis XML mappers
│   │   ├── mybatis-config.xml
│   │   ├── struts.xml
│   │   └── xwork-conversion.properties
│   └── webapp
│       ├── WEB-INF/jsp       # JSP pages (list + form)
│       └── WEB-INF/web.xml
└── test (not used)
```

## Useful Maven Commands

| Command | Purpose |
| --- | --- |
| `mvn clean package` | Compile and produce a WAR artifact. |
| `mvn jetty:run` | Launch the app on Jetty at `http://localhost:8080/struts2-mybatis-app`. |

## Next Steps

- Replace the in-memory H2 database with an external relational database by updating `mybatis-config.xml` and the datasource properties.
- Add authentication/authorization if you need multi-user access.
- Expand automated tests (unit + functional) to cover the service and action layers.

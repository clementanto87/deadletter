# Deadletter (sample Kotlin Spring Boot app)

Quick sample project providing basic REST endpoints for a DeadLetter store.

Build and run (requires JDK 17 and Gradle):

```bash
./gradlew bootRun
```

Endpoints:
- `GET /api/health` — health check
- `GET /api/deadletters` — list stored dead letters
- `GET /api/deadletters/{id}` — get single dead letter
- `POST /api/deadletters` — create dead letter (JSON body)

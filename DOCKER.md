# Docker - HDiSED Project

## Szybki start

### 1. Skopiuj plik konfiguracyjny
```bash
cp docker/.env.example docker/.env
```

### 2. Dostosuj konfigurację (opcjonalnie)
Edytuj plik `docker/.env` według potrzeb, np.:
- `OLLAMA_BASE_URL` - URL do Ollama/LLM API
- `OLLAMA_MODEL` - nazwa modelu LLM
- `POSTGRES_PASSWORD` - hasło do bazy danych

### 3. Uruchom kontenery
```bash
cd docker
docker-compose up -d --build
```

### 4. Sprawdź status
```bash
cd docker
docker-compose ps
docker-compose logs -f
```

## Architektura

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────────┐    ┌──────────────┐  │
│  │   Frontend   │───▶│  HDiSED-client   │───▶│   Postgres   │  │
│  │   (nginx)    │    │   (Spring Boot)  │    │  (pgvector)  │  │
│  │   :3000      │    │     :8081        │    │    :5432     │  │
│  └──────────────┘    └────────┬─────────┘    └──────────────┘  │
│                               │                                  │
│                               │ subprocess                       │
│                               ▼                                  │
│                      ┌──────────────────┐                       │
│                      │    TAKE-MCP      │                       │
│                      │   (embedded)     │                       │
│                      └──────────────────┘                       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    host.docker.internal                    │  │
│  │                          ▼                                │  │
│  │                  ┌──────────────┐                         │  │
│  │                  │    Ollama    │                         │  │
│  │                  │   :11434     │                         │  │
│  │                  └──────────────┘                         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Usługi

| Usługa | Port | Opis |
|--------|------|------|
| postgres | 5432 | PostgreSQL z rozszerzeniem pgvector |
| hdised-client | 8081 | Backend Spring Boot z MCP client |
| frontend | 3000 | Frontend React (nginx) |

## Kolejność uruchamiania

1. **postgres** - Baza danych z pgvector
2. **hdised-client** - Backend (czeka na postgres)
3. **frontend** - Frontend (czeka na hdised-client)

## Konfiguracja

### Zmienne środowiskowe

#### PostgreSQL
| Zmienna | Domyślna wartość | Opis |
|---------|------------------|------|
| `POSTGRES_USER` | admin | Użytkownik bazy danych |
| `POSTGRES_PASSWORD` | admin | Hasło do bazy danych |
| `POSTGRES_DB` | hdised_client_db | Nazwa bazy danych |
| `POSTGRES_PORT` | 5432 | Port zewnętrzny |

#### Ollama/LLM
| Zmienna | Domyślna wartość | Opis |
|---------|------------------|------|
| `OLLAMA_BASE_URL` | http://host.docker.internal:11434 | URL do Ollama API |
| `OLLAMA_MODEL` | gpt-oss:20b | Model LLM |
| `EMBEDDING_MODEL` | embeddinggemma:latest | Model embeddingów |

#### RAG
| Zmienna | Domyślna wartość | Opis |
|---------|------------------|------|
| `RAG_ENABLED` | true | Włączenie RAG |
| `RAG_TOP_K` | 3 | Liczba wyników |
| `RAG_SIMILARITY_THRESHOLD` | 0.7 | Próg podobieństwa |

#### MCP
| Zmienna | Domyślna wartość | Opis |
|---------|------------------|------|
| `MCP_JAR_PATH` | /app/mcp-servers/TAKE-MCP.jar | Ścieżka do JAR MCP |

### Porty
| Zmienna | Domyślna wartość | Opis |
|---------|------------------|------|
| `BACKEND_PORT` | 8081 | Port backendu |
| `FRONTEND_PORT` | 3000 | Port frontendu |

## Polecenia

### Uruchomienie
```bash
# Wszystkie usługi
cd docker
docker-compose up -d --build

# Tylko baza danych
cd docker
docker-compose up -d postgres

# Bez frontendu (dla developmentu frontendu lokalnie)
cd docker
docker-compose up -d postgres hdised-client
```

### Logi
```bash
# Wszystkie usługi
cd docker
docker-compose logs -f

# Konkretna usługa
cd docker
docker-compose logs -f hdised-client
```

### Zatrzymanie
```bash
cd docker
docker-compose down

# Z usunięciem wolumenów (UWAGA: usuwa dane!)
cd docker
docker-compose down -v
```

### Przebudowa
```bash
cd docker
docker-compose up -d --build --force-recreate
```

## Ollama

### Lokalna instalacja (na hoście)
Jeśli Ollama jest zainstalowana na maszynie hosta, kontenery automatycznie się z nią połączą przez `host.docker.internal:11434`.

### Ollama w Docker (opcjonalnie)
Możesz dodać Ollama jako dodatkowy kontener:

```yaml
# Dodaj do docker/docker-compose.yml
ollama:
  image: ollama/ollama
  container_name: ollama
  ports:
    - "11434:11434"
  volumes:
    - ollama_data:/root/.ollama
  networks:
    - hdised-network

# Dodaj wolumin
volumes:
  ollama_data:
```

Następnie zmień w `docker/.env`:
```
OLLAMA_BASE_URL=http://ollama:11434
```

## Rozwiązywanie problemów

### Brak połączenia z Ollama
```bash
# Sprawdź czy Ollama działa
curl http://localhost:11434/api/version

# Sprawdź logi
cd docker
docker-compose logs hdised-client | grep -i ollama
```

### Problemy z bazą danych
```bash
# Sprawdź status postgres
cd docker
docker-compose exec postgres pg_isready

# Sprawdź logi
cd docker
docker-compose logs postgres
```

### Czyszczenie
```bash
# Usuń wszystkie kontenery i wolumeny
cd docker
docker-compose down -v

# Usuń obrazy
cd docker
docker-compose down --rmi all
```

# Projket inżynierski 

## Uruchomienie
```
git clone https://github.com/jemek27/projket-inz.git
cd projket-inz
git submodule update --init --recursive
cp .env.example .env
```
Dokonaj potrzebnych zmian w pliku .env. Nalezy wybrać LLM_PROVIDER między ollama i groq.
W przyapdku wybrania groq naley podać GROQ_API_KEY.
W przyapdku wybrania ollama należy zahostować wybrany model lokalnie 
```
docker-compose up -d --build
```
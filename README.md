# Векторная PostgreSQL с интеграцией Ollama LLM

Этот проект настраивает полную среду с PostgreSQL, pgAdmin, автоматизацией рабочих процессов n8n и сервисом Ollama LLM (Large Language Model).

## Компоненты

- **PostgreSQL**: База данных с поддержкой векторов для хранения и запросов данных
- **pgAdmin**: Веб-интерфейс для управления PostgreSQL
- **n8n**: Инструмент автоматизации рабочих процессов
- **Ollama**: Локальный LLM-сервис, запускающий Llama 3.2

## Установка Docker для начинающих

Перед запуском проекта вам необходимо установить Docker и Docker Compose. Ниже приведены подробные инструкции для разных операционных систем.

### Установка Docker на Windows

1. **Скачайте Docker Desktop для Windows**:
   - Перейдите на [официальный сайт Docker](https://www.docker.com/products/docker-desktop/)
   - Нажмите на кнопку "Download for Windows"
   - Сохраните установочный файл на ваш компьютер

2. **Установите Docker Desktop**:
   - Запустите скачанный файл (обычно называется "Docker Desktop Installer.exe")
   - Следуйте инструкциям мастера установки
   - Во время установки вам может быть предложено включить WSL 2 (Windows Subsystem for Linux) - рекомендуется согласиться
   - После завершения установки перезагрузите компьютер

3. **Запустите Docker Desktop**:
   - После перезагрузки найдите Docker Desktop в меню "Пуск" и запустите его
   - Дождитесь, пока Docker полностью загрузится (значок Docker в системном трее станет неподвижным)
   - При первом запуске может потребоваться принять лицензионное соглашение

4. **Проверьте установку**:
   - Откройте командную строку (CMD) или PowerShell
   - Введите команду `docker --version` и нажмите Enter
   - Вы должны увидеть версию Docker, что подтверждает успешную установку

### Установка Docker на macOS

1. **Скачайте Docker Desktop для Mac**:
   - Перейдите на [официальный сайт Docker](https://www.docker.com/products/docker-desktop/)
   - Нажмите на кнопку "Download for Mac"
   - Выберите версию, соответствующую вашему процессору (Intel или Apple Silicon)
   - Сохраните установочный файл на ваш компьютер

2. **Установите Docker Desktop**:
   - Откройте скачанный файл .dmg
   - Перетащите значок Docker в папку Applications
   - Запустите Docker из папки Applications
   - Введите пароль администратора, если потребуется
   - Дождитесь завершения установки

3. **Проверьте установку**:
   - Откройте Terminal (Терминал)
   - Введите команду `docker --version` и нажмите Enter
   - Вы должны увидеть версию Docker, что подтверждает успешную установку

### Установка Docker на Linux (Ubuntu)

1. **Обновите индекс пакетов**:
   ```bash
   sudo apt-get update
   ```

2. **Установите необходимые пакеты**:
   ```bash
   sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
   ```

3. **Добавьте официальный GPG-ключ Docker**:
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```

4. **Добавьте репозиторий Docker**:
   ```bash
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   ```

5. **Обновите индекс пакетов**:
   ```bash
   sudo apt-get update
   ```

6. **Установите Docker**:
   ```bash
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
   ```

7. **Запустите и включите Docker**:
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

8. **Добавьте вашего пользователя в группу docker** (чтобы запускать Docker без sudo):
   ```bash
   sudo usermod -aG docker $USER
   ```
   После этой команды необходимо выйти из системы и войти снова, чтобы изменения вступили в силу.

9. **Проверьте установку**:
   ```bash
   docker --version
   ```

### Проверка установки Docker Compose

Docker Compose обычно устанавливается вместе с Docker Desktop на Windows и macOS. На Linux может потребоваться отдельная установка:

```bash
sudo apt-get install docker-compose-plugin
```

Проверьте установку Docker Compose:
```bash
docker compose version
```

## Быстрый старт

1. **Скачайте проект**:
   - Если у вас установлен Git, выполните команду:
     ```bash
     git clone https://github.com/refreezer/vector-postgres.git
     cd vector-postgres
     ```
   - Если Git не установлен, вы можете скачать проект как ZIP-архив с GitHub и распаковать его

2. **Запустите все сервисы одной командой**:
   ```bash
   docker compose up -d
   ```
   
   Все скрипты будут автоматически сделаны исполняемыми при запуске контейнеров.

3. **Доступ к сервисам**:
   - pgAdmin: http://localhost:5050 (Email: admin@example.com, Пароль: admin)
   - n8n: http://localhost:5678
   - Ollama API: http://localhost:11434

## Подключение n8n к Ollama

1. **Импорт примера рабочего процесса**:
   - Откройте n8n по адресу http://localhost:5678
   - Перейдите в Workflows → Import From File
   - Выберите файл `example-ollama-workflow.json`
   - Сохраните и выполните рабочий процесс

2. **Ручная настройка**:
   - Создайте новый рабочий процесс в n8n
   - Добавьте узел HTTP Request
   - Настройте его для подключения к Ollama (см. подробные инструкции в `n8n-ollama-guide.md`)

## Устранение неполадок

### Конфликты портов

Если у вас уже запущен Ollama локально на компьютере, он будет занимать порт 11434 и препятствовать запуску Docker-контейнера. Перед запуском контейнеров необходимо остановить локальный сервис Ollama:

```bash
docker compose run --rm init-scripts /scripts/stop-local-ollama.sh
```

После этого можно запустить все сервисы:

```bash
docker compose up -d
```

### Проблемы с подключением

Если у вас возникают проблемы с подключением n8n к Ollama:

1. **Проверьте, запущены ли сервисы**:
   ```bash
   docker compose ps
   ```

2. **Убедитесь, что Ollama доступен**:
   ```bash
   curl http://localhost:11434/api/version
   ```

3. **Проверьте из контейнера n8n**:
   ```bash
   docker exec vector-n8n curl http://vector-ollama:11434/api/version
   ```

4. **Проверьте логи**:
   ```bash
   docker compose logs ollama
   docker compose logs n8n
   ```

5. **Перезапустите сервисы**:
   ```bash
   docker compose restart
   ```

## Прямое использование Llama 3.2

Вы можете взаимодействовать с Llama 3.2 напрямую:

```bash
# Интерактивный чат
docker exec -it vector-ollama ollama run llama3.2

# API-запрос
curl http://localhost:11434/api/generate -d '{"model":"llama3.2","prompt":"Привет!"}'
```

## Файлы в этом проекте

- `docker-compose.yml`: Конфигурация для всех сервисов
- `setup-llama.sh`: Скрипт для настройки и тестирования среды
- `stop-local-ollama.sh`: Скрипт для остановки локального сервиса Ollama
- `ollama-init.sh`: Скрипт инициализации Ollama
- `n8n-ollama-guide.md`: Подробное руководство по подключению n8n к Ollama

## Дополнительные ресурсы

- [Документация Ollama](https://github.com/ollama/ollama)
- [Документация n8n](https://docs.n8n.io/)
- [Документация по векторам PostgreSQL](https://www.postgresql.org/docs/current/pgsql-vectors.html)
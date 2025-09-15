# 🚨 ПОШАГОВОЕ РУКОВОДСТВО ПО ВОССТАНОВЛЕНИЮ ПОСЛЕ RANSOMWARE АТАКИ

## ⚡ КРИТИЧЕСКИЕ ДЕЙСТВИЯ (выполнить НЕМЕДЛЕННО)

### Шаг 1: Изоляция сервера
```bash
# Временно заблокируйте весь исходящий трафик
sudo iptables -P OUTPUT DROP
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Сохраните текущее состояние для анализа
date > /tmp/incident_$(date +%Y%m%d_%H%M%S).log
ps aux >> /tmp/incident_$(date +%Y%m%d_%H%M%S).log
netstat -tulpn >> /tmp/incident_$(date +%Y%m%d_%H%M%S).log
docker ps -a >> /tmp/incident_$(date +%Y%m%d_%H%M%S).log
```

### Шаг 2: Остановка скомпрометированных сервисов
```bash
cd /home/debian/repos/vector-postgres
docker-compose down
sudo systemctl stop nginx
```

### Шаг 3: Анализ логов (быстрая проверка)
```bash
# Проверьте последние входы SSH
sudo tail -100 /var/log/auth.log | grep -i "accepted\|failed"

# Проверьте подозрительные процессы
ps aux | grep -v "\[.*\]" | sort -k3 -r | head -20

# Проверьте сетевые соединения
sudo netstat -tulpn | grep -v "127.0.0.1"
```

## 🔐 ВОССТАНОВЛЕНИЕ БЕЗОПАСНОСТИ

### Шаг 4: Подготовка безопасной конфигурации
```bash
cd /home/debian/repos/vector-postgres

# Создайте файл с переменными окружения
cp .env.example .env
chmod 600 .env

# Отредактируйте .env и установите НОВЫЕ сложные пароли
nano .env
```

**ВАЖНО**: В файле .env обязательно:
- Установите новый сложный `POSTGRES_PASSWORD`
- Сгенерируйте новый `N8N_ENCRYPTION_KEY`: `openssl rand -hex 32`
- Установите новые пароли для `N8N_BASIC_AUTH_PASSWORD`

### Шаг 5: Перевыпуск SSL сертификатов
```bash
# Остановите nginx если он работает
sudo systemctl stop nginx

# Перевыпустите сертификаты Let's Encrypt
sudo certbot certonly --standalone -d vps-af079087.vps.ovh.net --force-renewal

# Проверьте новые сертификаты
sudo certbot certificates
```

### Шаг 6: Запуск безопасной конфигурации
```bash
# Сделайте скрипт исполняемым
chmod +x secure-deploy.sh

# Запустите развертывание
sudo ./secure-deploy.sh
```

### Шаг 7: Настройка файрвола
```bash
# Установите ufw если не установлен
sudo apt install ufw

# Настройте правила
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp   # SSH (лучше сменить порт)
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS

# Включите файрвол
sudo ufw enable

# Проверьте статус
sudo ufw status verbose
```

### Шаг 8: Смена SSH конфигурации
```bash
# Сделайте бэкап конфигурации
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Отредактируйте конфигурацию
sudo nano /etc/ssh/sshd_config
```

Измените следующие параметры:
```
Port 2222  # Измените стандартный порт
PermitRootLogin no
PasswordAuthentication no  # Только SSH ключи
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

```bash
# Перезапустите SSH
sudo systemctl restart ssh

# Не забудьте обновить правило файрвола
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp
```

### Шаг 9: Установка системы мониторинга
```bash
# Установите fail2ban
sudo apt update
sudo apt install fail2ban

# Создайте локальную конфигурацию
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Настройте правила (отредактируйте файл)
sudo nano /etc/fail2ban/jail.local

# Запустите fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### Шаг 10: Настройка резервного копирования
```bash
# Сделайте скрипт исполняемым
chmod +x backup-setup.sh

# Запустите настройку
sudo ./backup-setup.sh

# Проверьте работу бэкапа
sudo /usr/local/bin/vector-postgres-backup.sh
```

## 🔍 ПРОВЕРКА И МОНИТОРИНГ

### Проверка работы сервисов
```bash
# Проверьте статус контейнеров
docker-compose -f docker-compose.secure.yml ps

# Проверьте логи
docker-compose -f docker-compose.secure.yml logs --tail=50

# Проверьте доступность n8n
curl -I https://vps-af079087.vps.ovh.net/n8n/
```

### Мониторинг безопасности
```bash
# Мониторинг логов в реальном времени
sudo tail -f /var/log/auth.log

# Проверка fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Проверка открытых портов
sudo netstat -tulpn
```

## 📋 ЧЕКЛИСТ БЕЗОПАСНОСТИ

- [ ] Все пароли изменены на новые сложные
- [ ] SSH ключи перегенерированы
- [ ] Let's Encrypt сертификаты перевыпущены
- [ ] Файрвол настроен и активен
- [ ] SSH порт изменен со стандартного
- [ ] Fail2ban установлен и настроен
- [ ] PostgreSQL доступен только локально
- [ ] n8n защищен двойной аутентификацией
- [ ] Автоматические бэкапы настроены
- [ ] Система обновлена до последней версии

## 🚀 ДОПОЛНИТЕЛЬНЫЕ МЕРЫ

### 1. Обновление системы
```bash
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
```

### 2. Установка антивируса
```bash
sudo apt install clamav clamav-daemon
sudo freshclam
sudo systemctl enable clamav-daemon
sudo clamscan -r /home
```

### 3. Аудит системы
```bash
# Установите инструменты аудита
sudo apt install lynis rkhunter

# Запустите проверку
sudo lynis audit system
sudo rkhunter --check
```

## ⚠️ ВАЖНЫЕ ЗАМЕЧАНИЯ

1. **НЕ ПЛАТИТЕ ВЫКУП** - это не гарантирует восстановление данных
2. **Сохраните все логи инцидента** для анализа
3. **Регулярно проверяйте бэкапы** и тестируйте восстановление
4. **Включите оповещения** о подозрительной активности
5. **Документируйте все изменения** в системе

## 📞 КОНТАКТЫ ДЛЯ ПОМОЩИ

- Техподдержка хостинга: [контакты OVH]
- Сообщить об инциденте: [local CERT contacts]
- Консультация по безопасности: [security consultant]

---

**Последнее обновление**: $(date)
**Версия**: 1.0
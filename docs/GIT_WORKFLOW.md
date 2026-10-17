# 🔀 Git Workflow: Работа в ветке и мерж в main

## 📋 Текущая настройка

- **Рабочая ветка:** `fix/build-optimization`
- **Основная ветка:** `main`

## 🚀 Работа в ветке

```powershell
# Проверить текущую ветку
git branch

# Добавить изменения
git add .

# Создать коммит
git commit -m "Описание изменений"

# Отправить на сервер
git push
```

## 🔄 Мерж в main

```powershell
# 1. Убедиться, что все закоммичено
git status

# 2. Переключиться на main
git checkout main

# 3. Обновить main (если работаете в команде)
git pull origin main

# 4. Вмержить вашу ветку
git merge fix/build-optimization

# 5. Отправить на сервер
git push origin main

# 6. Вернуться в рабочую ветку
git checkout fix/build-optimization
```

## 📥 Обновить рабочую ветку из main

```powershell
# 1. Переключиться на main
git checkout main

# 2. Обновить main
git pull origin main

# 3. Вернуться в рабочую ветку
git checkout fix/build-optimization

# 4. Вмержить изменения из main
git merge main
```

## 🔍 Полезные команды

```powershell
# Текущая ветка
git branch --show-current

# Статус изменений
git status

# Последние коммиты
git log --oneline -5
```


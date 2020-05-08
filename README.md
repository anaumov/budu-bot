# Репозиторий бота «Продолжаю»

![Build status](https://travis-ci.com/anaumov/budu-bot.svg?branch=master)

### Как развернуть у себя (MacOS)

Скопируйте проект с гитхаба
```
git clone git@github.com:anaumov/budu-bot.git
```

Установите [rbenv](https://github.com/rbenv/rbenv#installation)
```
brew update && brew install rbenv
rbenv init
```
Установите версию руби, которая указана в проекте
```
cd budu-bot
cat .ruby-version | rbenv install
```
Устновите бандлер и гемы
```
gem install bundler
gem install rails
rbenv rehash
bundler install
```

Установите постгрес и запустите консоль
```
brew install postgresql
psql -t template1
```
далее в консоли постгреса
```
CREATE DATABASE keepon_dev;
CREATE DATABASE keepon_test;
\q
```
Создайте конфиг базы данных, запустите миграции
```
cp ./config/database-sample.yml ./config/database.yml
bundle exec rake db:migrate
```

[Создайте бота через @BotFather](https://t.me/BotFather), добавьте апи ключ в `secrets.yml`
```
cp ./config/secrets-sample.yml ./config/secrets.yml
```

Готово, запустите пуллер!
```
make poller
rails s
```

-- create database 'owncloud'
CREATE DATABASE IF NOT EXISTS %database%;
-- create user 'owncloud'
CREATE USER '%user%'@'localhost' IDENTIFIED BY '%password%';
GRANT ALL ON %database%.* TO '%user%'@'localhost';

FLUSH PRIVILEGES;
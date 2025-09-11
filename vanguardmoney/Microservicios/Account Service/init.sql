-- Script de inicialización para MySQL (opcional)
-- Este archivo se ejecuta automáticamente cuando se crea el contenedor MySQL

CREATE DATABASE IF NOT EXISTS auth_db;
USE auth_db;

-- Crear usuario específico para la aplicación (opcional, ya se crea con docker-compose)
-- CREATE USER IF NOT EXISTS 'auth_user'@'%' IDENTIFIED BY 'auth_password_123';
-- GRANT ALL PRIVILEGES ON auth_db.* TO 'auth_user'@'%';
-- FLUSH PRIVILEGES;

-- Las tablas se crean automáticamente con Sequelize
-- Este archivo es principalmente para configuraciones adicionales si son necesarias

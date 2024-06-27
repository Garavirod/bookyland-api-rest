CREATE USER 'bookyland_user_dev'@'%' IDENTIFIED BY 'bookyland0925';
GRANT ALL PRIVILEGES ON bookyland.* TO 'bookyland_user_dev'@'%';
FLUSH PRIVILEGES;

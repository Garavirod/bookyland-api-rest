CREATE USER 'bookyland_user_dev'@'%' IDENTIFIED BY '@qwerqwerjklweriuyqwe87';
GRANT ALL PRIVILEGES ON bookyland.* TO 'bookyland_user_dev'@'%';
FLUSH PRIVILEGES;

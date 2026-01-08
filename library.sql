DROP DATABASE IF EXISTS library1;
CREATE DATABASE library1;
USE library1;

CREATE TABLE authors (
author_id int PRIMARY KEY NOT NULL AUTO_INCREMENT,
full_name VARCHAR(40)
);
CREATE TABLE books (
book_id int  PRIMARY KEY NOT NULL AUTO_INCREMENT,
title VARCHAR(100),
author_id int,
FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

INSERT INTO `library1`.`authors` (`full_name`) VALUES ('Phil');
INSERT INTO `library1`.`authors` (`full_name`) VALUES ('William Shakespeare');
INSERT INTO `library1`.`authors` (`full_name`) VALUES ('Jane Austen');
INSERT INTO `library1`.`authors` (`full_name`) VALUES ('Charles Dickens');
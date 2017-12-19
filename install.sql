CREATE DATABASE `universalapi` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_id` int(11) NOT NUll,
  `dr_uid` int(11) DEFAULT NULL,
  `name` varchar(30) DEFAULT NULL,
  `data` json DEFAULT NULL,
  `session` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`id`),
  key `app_id` (`app_id`),
  key `dr_uid` (`dr_uid`),
  key `session` (`session`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `session_dr` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `code` varchar(50) DEFAULT NULL,
  `api_key` varchar(50) DEFAULT NULL,
  `updated` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `session_dr_app_id` (`app_id`),
  KEY `session_dr_user_id` (`user_id`),
  KEY `session_dr_code` (`code`),
  CONSTRAINT `auth_user_id_ref` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

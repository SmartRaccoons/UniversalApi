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

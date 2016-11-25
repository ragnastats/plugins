CREATE TABLE `simple-relay` (
  `relayID` int(11) NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `destination` varchar(32) NOT NULL,
  `type` varchar(32) NOT NULL,
  `message` text NOT NULL,
  `relayed` int(1) NOT NULL,
  PRIMARY KEY (`relayID`),
  KEY `destination` (`destination`),
  KEY `relayed` (`relayed`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

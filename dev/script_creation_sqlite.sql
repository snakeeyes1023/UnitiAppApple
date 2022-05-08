------------- SQLite3 Dump File -------------

-- ------------------------------------------
-- Dump of "loyers"
-- ------------------------------------------

CREATE TABLE "loyers"(
	"id" Integer NOT NULL PRIMARY KEY AUTOINCREMENT,
	"nom" Text NOT NULL,
	"uuid" Text NOT NULL,
	"dispo" Boolean NOT NULL,
	"longitude" Text NOT NULL,
	"lattitude" Text NOT NULL,
	"grandeur" Double NOT NULL,
	"prix" Double NOT NULL );



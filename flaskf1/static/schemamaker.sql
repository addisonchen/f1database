CREATE DATABASE IF NOT EXISTS `formula1`;

use `formula1`;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `season`;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE `season` (
	season_id INT NOT NULL,
    CONSTRAINT season_pk PRIMARY KEY (season_id));
    
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `race`;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE `race` (
	race_id INT NOT NULL AUTO_INCREMENT,
    track VARCHAR(255) NOT NULL,
    `date` DATE NOT NULL,
    season_id INT NOT NULL,
    CONSTRAINT race_pk PRIMARY KEY (race_id),
    CONSTRAINT r_season_fk FOREIGN KEY (season_id) REFERENCES season (season_id) ON UPDATE CASCADE ON DELETE CASCADE);
    
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `twitter_info`;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE `twitter_info` (
	username VARCHAR(15) NOT NULL,
    followers INT,
    avg_likes INT,
    CONSTRAINT twitter_pk PRIMARY KEY (username));
    
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `team`;
SET FOREIGN_KEY_CHECKS = 1;
DROP TABLE IF EXISTS `team`;
CREATE TABLE `team` (
	team_id INT NOT NULL AUTO_INCREMENT,
    team_name VARCHAR(255) NOT NULL,
    hex_color VARCHAR(6) NOT NULL,
    username VARCHAR(255),
    CONSTRAINT team_pk PRIMARY KEY (team_id),
    CONSTRAINT t_username_fk FOREIGN KEY (username) REFERENCES twitter_info (username) ON UPDATE RESTRICT ON DELETE RESTRICT);
    
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `principal`;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE `principal` (
	principal_id INT NOT NULL AUTO_INCREMENT,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL,
    username VARCHAR(255),
    team_id INT,
    CONSTRAINT principal_pk PRIMARY KEY (principal_id),
    CONSTRAINT p_team_fk FOREIGN KEY (team_id) REFERENCES team (team_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT p_username_fk FOREIGN KEY (username) REFERENCES twitter_info (username) ON UPDATE RESTRICT ON DELETE RESTRICT);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `driver`;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE `driver` (
	driver_id INT NOT NULL AUTO_INCREMENT,
    fname VARCHAR(255) NOT NULL,
    lname VARCHAR(255) NOT NULL,
    username VARCHAR(255),
    team_id INT,
	CONSTRAINT driver_pk PRIMARY KEY (driver_id),
    CONSTRAINT d_season_fk FOREIGN KEY (team_id) REFERENCES team (team_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT d_username_fk FOREIGN KEY (username) REFERENCES twitter_info (username) ON UPDATE RESTRICT ON DELETE RESTRICT);

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `result`;
SET FOREIGN_KEY_CHECKS = 1;
CREATE TABLE `result` (
	result_id INT NOT NULL AUTO_INCREMENT,
    position INT NOT NULL,
    driver_id INT NOT NULL,
    team_id INT NOT NULL,
    race_id INT NOT NULL,
    fastest_lap BOOLEAN,
    points INT NOT NULL,
    CONSTRAINT result_pk PRIMARY KEY (result_id),
    CONSTRAINT r_driver_fk FOREIGN KEY (driver_id) REFERENCES driver (driver_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT r_team_fk FOREIGN KEY (team_id) REFERENCES team (team_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT r_race_fk FOREIGN KEY (race_id) REFERENCES race (race_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT r_position_greaterthan0 CHECK (position > 0),
    CONSTRAINT r_position_lessthan27 CHECK (position < 27));
    


/* PROCEDURE - ADD SEASON TO SEASON TABLE */
DROP PROCEDURE IF EXISTS add_season;
DELIMITER //
CREATE PROCEDURE add_season(IN `year` INT)
BEGIN
	INSERT INTO `season` (season_id) VALUES (`year`);
END //
DELIMITER ;

/* PROCEDURE - DELETE A SEASON BY PK*/
DROP PROCEDURE IF EXISTS delete_season;
DELIMITER //
CREATE PROCEDURE delete_season(IN id INT)
BEGIN
	DELETE FROM season WHERE season_id = id;
END //
DELIMITER ;

/* PROCEDURE - MODIFY SEASON */
DROP PROCEDURE IF EXISTS modify_season;
DELIMITER //
CREATE PROCEDURE modify_season(IN id INT, IN new_id INT)
BEGIN
	UPDATE season
    SET
		season_id = new_id
	WHERE season_id = id;
END //
DELIMITER ;


/* PROCEDURE - ADD RACE TO RACE TABLE */
DROP PROCEDURE IF EXISTS add_race;
DELIMITER //
CREATE PROCEDURE add_race(IN location VARCHAR(255), IN `day` DATE, IN season INT)
BEGIN
	INSERT INTO `race` (track, `date`, season_id) VALUES (location, `day`, season);
END //
DELIMITER ; 

/* PROCEDURE - DELETE A RACE BY PK*/
DROP PROCEDURE IF EXISTS delete_race;
DELIMITER //
CREATE PROCEDURE delete_race(IN id INT)
BEGIN
	DELETE FROM race WHERE race_id = id;
END //
DELIMITER ;

/* PROCEDURE - MODIFY RACE */
DROP PROCEDURE IF EXISTS modify_race;
DELIMITER //
CREATE PROCEDURE modify_race(IN id INT, IN t VARCHAR(255), IN d DATE, IN s INT)
BEGIN
	UPDATE race
    SET
		track = t,
        `date` = d,
        season_id = s
	WHERE race_id = id;
END //
DELIMITER ;

/* PROCEDURE - ADD TWITTER INFO */
DROP PROCEDURE IF EXISTS add_twitter_info;
DELIMITER //
CREATE PROCEDURE add_twitter_info(IN username VARCHAR(15), IN follow INT, IN likes INT)
BEGIN
	INSERT INTO twitter_info (username, followers, avg_likes)
		VALUES (username, follow, likes);
END //
DELIMITER ;

/* PROCEDURE - DELETE A TWITTER INFO BY PK */
DROP PROCEDURE IF EXISTS delete_twitter_info;
DELIMITER //
CREATE PROCEDURE delete_twitter_info(IN usern VARCHAR(15))
BEGIN
	DELETE FROM twitter_info WHERE username = usern;
END //
DELIMITER ;

/* PROCEDURE - GET DELETABLE TWITTER */
DROP PROCEDURE IF EXISTS get_deletable_twitter;
DELIMITER //
CREATE PROCEDURE get_deletable_twitter()
BEGIN
	SELECT t.username FROM twitter_info AS t WHERE t.username NOT IN
		((SELECT username FROM team WHERE username IS NOT NULL)
        UNION (SELECT username FROM driver WHERE username IS NOT NULL) 
        UNION (SELECT username FROM principal WHERE username IS NOT NULL));
END //
DELIMITER ;


/* PROCEDURE - REFRESH TWITTER INFO */
DROP PROCEDURE IF EXISTS refresh_twitter_info;
DELIMITER //
CREATE PROCEDURE refresh_twitter_info(IN usern VARCHAR(15), IN follow INT, IN likes INT)
BEGIN
	UPDATE twitter_info
    SET 
        followers = follow,
        avg_likes = likes
	WHERE username = usern;
END //
DELIMITER ;


/* PROCEDURE - ADD TEAM INFO */
DROP PROCEDURE IF EXISTS add_team;
DELIMITER //
CREATE PROCEDURE add_team(IN team_name VARCHAR(255), IN color VARCHAR(6), IN username VARCHAR(15))
BEGIN
	INSERT INTO team (team_name, hex_color, username)
		VALUES (team_name, color, username);
END //
DELIMITER ;

/* PROCEDURE - DELETE A TEAM BY PK */
DROP PROCEDURE IF EXISTS delete_team;
DELIMITER //
CREATE PROCEDURE delete_team(IN id INT)
BEGIN
	DELETE FROM team WHERE team_id = id;
END //
DELIMITER ;

/* PROCEDURE - MODIFY TEAM */
DROP PROCEDURE IF EXISTS modify_team;
DELIMITER //
CREATE PROCEDURE modify_team(IN id INT, IN tn VARCHAR(255), IN c VARCHAR(6), IN u VARCHAR(15))
BEGIN
	UPDATE team
    SET
		team_name = tn,
        hex_color = c,
        username = u
	WHERE team_id = id;
END //
DELIMITER ;


/* PROCEDURE - ADD A DRIVER */
DROP PROCEDURE IF EXISTS add_driver;
DELIMITER //
CREATE PROCEDURE add_driver(IN fname VARCHAR(255), IN lname VARCHAR(255), IN username VARCHAR(15), IN team_id INT)
BEGIN
	INSERT INTO driver (fname, lname, username, team_id)
		VALUES (fname, lname, username, team_id);
END //
DELIMITER ;

/* PROCEDURE - DELETE A DRIVER BY PK */
DROP PROCEDURE IF EXISTS delete_driver;
DELIMITER //
CREATE PROCEDURE delete_driver(IN id INT)
BEGIN
	DELETE FROM driver WHERE driver_id = id;
END //
DELIMITER ;

/* PROCEDURE - MODIFY DRIVER */
DROP PROCEDURE IF EXISTS modify_driver;
DELIMITER //
CREATE PROCEDURE modify_driver(IN id INT, IN fn VARCHAR(255), IN ln VARCHAR(255), IN u VARCHAR(15), IN t INT)
BEGIN
	UPDATE driver
    SET
		fname = fn,
        lname = ln,
        username = u,
        team_id = t
	WHERE driver_id = id;
END //
DELIMITER ;



/* PROCEDURE - ADD A PRINCIPAL */
DROP PROCEDURE IF EXISTS add_principal;
DELIMITER //
CREATE PROCEDURE add_principal(IN fname VARCHAR(255), IN lname VARCHAR(255), IN username VARCHAR(15), IN team_id INT)
BEGIN
	INSERT INTO principal (fname, lname, username, team_id)
		VALUES (fname, lname, username, team_id);
END //
DELIMITER ;

/* PROCEDURE - DELETE A PRINCIPAL BY PK */
DROP PROCEDURE IF EXISTS delete_principal;
DELIMITER //
CREATE PROCEDURE delete_principal(IN id INT)
BEGIN
	DELETE FROM principal WHERE principal_id = id;
END //
DELIMITER ;


/* PROCEDURE - MODIFY PRINCIPAL */
DROP PROCEDURE IF EXISTS modify_principal;
DELIMITER //
CREATE PROCEDURE modify_principal(IN id INT, IN fn VARCHAR(255), IN ln VARCHAR(255), IN u VARCHAR(15), IN t INT)
BEGIN
	UPDATE principal
    SET
		fname = fn,
        lname = ln,
        username = u,
        team_id = t
	WHERE principal_id = id;
END //
DELIMITER ;

/* PROCEDURE - ADD A RESULT */
DROP PROCEDURE IF EXISTS add_result;
DELIMITER //
CREATE PROCEDURE add_result(IN position INT, IN driver_id INT, IN team_id INT, IN race_id INT, IN fastest_lap BOOLEAN)
BEGIN
	SET @points =
		CASE position
			WHEN 1 THEN 25
			WHEN 2 THEN 18
			WHEN 3 THEN 15
			WHEN 4 THEN 12
			WHEN 5 THEN 10
			WHEN 6 THEN 8
			WHEN 7 THEN 6
			WHEN 8 THEN 4
			WHEN 9 THEN 2
			WHEN 10 THEN 1
			ELSE 0
		END;
    
    IF fastest_lap THEN SET @points = @points + 1;
    END IF;
    
	INSERT INTO result (position, driver_id, team_id, race_id, fastest_lap, points)
		VALUES (position, driver_id, team_id, race_id, fastest_lap, @points);
END //
DELIMITER ;

/* PROCEDURE - DELETE A RESULT BY PK */
DROP PROCEDURE IF EXISTS delete_result;
DELIMITER //
CREATE PROCEDURE delete_result(IN id INT)
BEGIN
	DELETE FROM result WHERE result_id = id;
END //
DELIMITER ;

/* PROCEDURE - MODIFY A RESULT */
DROP PROCEDURE IF EXISTS modify_result;
DELIMITER //
CREATE PROCEDURE modify_result(IN id INT, IN p INT, IN d INT, IN t INT, IN r INT, IN f BOOLEAN)
BEGIN
	SET @points =
		CASE position
			WHEN 1 THEN 25
			WHEN 2 THEN 18
			WHEN 3 THEN 15
			WHEN 4 THEN 12
			WHEN 5 THEN 10
			WHEN 6 THEN 8
			WHEN 7 THEN 6
			WHEN 8 THEN 4
			WHEN 9 THEN 2
			WHEN 10 THEN 1
			ELSE 0
		END;
    
    
    IF fastest_lap THEN SET @points = @points + 1;
    END IF;
    
	UPDATE result
    SET
		position = p,
        driver_id = d,
        team_id = t,
        race_id = r,
        fastest_lap = f,
        points = @points
	WHERE result_id = id;
END //
DELIMITER ;

/* PROCEDURE - get A result options info */
DROP PROCEDURE IF EXISTS get_result_info;
DELIMITER //
CREATE PROCEDURE get_result_info()
BEGIN
	SELECT result_id, team_name, lname, track, position, `date` FROM result, race, team, driver
		WHERE result.driver_id = driver.driver_id AND result.race_id = race.race_id AND
		result.team_id = team.team_id;
END //
DELIMITER ;


/* PROCEDURE - GET ALL TEAMS */
DROP PROCEDURE IF EXISTS all_teams;
DELIMITER //
CREATE PROCEDURE all_teams()
BEGIN
	SELECT team_id, team_name FROM team ORDER BY team_id ASC;
END //
DELIMITER ;

/* PROCEDURE - GET ALL DRIVERS */
DROP PROCEDURE IF EXISTS all_drivers;
DELIMITER //
CREATE PROCEDURE all_drivers()
BEGIN
	SELECT driver_id, fname, lname FROM driver ORDER BY team_id ASC;
END //
DELIMITER ;

/* PROCEDURE - GET ALL PRINCIPALS */
DROP PROCEDURE IF EXISTS all_principals;
DELIMITER //
CREATE PROCEDURE all_principals()
BEGIN
	SELECT principal_id, fname, lname FROM principal ORDER BY principal_id ASC;
END //
DELIMITER ;


/* PROCEDURE - GET ALL PRINCIPALS */
DROP PROCEDURE IF EXISTS all_principals;
DELIMITER //
CREATE PROCEDURE all_principals()
BEGIN
	SELECT principal_id, fname, lname FROM principal ORDER BY principal_id ASC;
END //
DELIMITER ;








/* PROCEDURE - TEAM POINT STANDINGS */
DROP PROCEDURE IF EXISTS team_point_standings;
DELIMITER //
CREATE PROCEDURE team_point_standings()
BEGIN
	SELECT team.team_id, team_name, hex_color, SUM(points) AS s FROM team LEFT JOIN result ON
		result.team_id = team.team_id GROUP BY team.team_id ORDER BY s DESC;
END //
DELIMITER ;


/* PROCEDURE - DRIVER POINT STANDINGS */
DROP PROCEDURE IF EXISTS driver_point_standings;
DELIMITER //
CREATE PROCEDURE driver_point_standings()
BEGIN
	SELECT result.driver_id, fname, lname, hex_color, SUM(points) AS s FROM 
		(SELECT fname, lname, driver_id, hex_color FROM driver, team WHERE driver.team_id = team.team_id) AS base
        LEFT JOIN result ON result.driver_id = base.driver_id GROUP BY base.driver_id ORDER BY s DESC;
END //
DELIMITER ;

/* FUNCTION - AVERAGE POINTS FOR A TEAM */
DROP FUNCTION IF EXISTS team_average_points;
DELIMITER //
CREATE FUNCTION team_average_points(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT AVG(points) FROM result WHERE team_id = id);
END //
DELIMITER ;

/* FUNCTION - AVERAGE POINTS FOR A DRIVER */
DROP FUNCTION IF EXISTS driver_average_points;
DELIMITER //
CREATE FUNCTION driver_average_points(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT AVG(points) FROM result WHERE driver_id = id);
END //
DELIMITER ;

/* FUNCTION GETS SCORE BY A TEAM FOR A RACE */
DROP FUNCTION IF EXISTS team_race_point_result;
DELIMITER //
CREATE FUNCTION team_race_point_result(tid INT, rid INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT SUM(points) FROM result WHERE tid = team_id AND rid = race_id GROUP BY race_id);
END //
DELIMITER ;

/* FUNCTION GETS SCORE BY A DRIVER FOR A RACE */
DROP FUNCTION IF EXISTS driver_race_point_result;
DELIMITER //
CREATE FUNCTION driver_race_point_result(did INT, rid INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT SUM(points) FROM result WHERE did = driver_id AND rid = race_id GROUP BY race_id);
END //
DELIMITER ;


/* PROCEDURE - TEAM FOLLOWER STANDINGS */
DROP PROCEDURE IF EXISTS team_follower_standings;
DELIMITER //
CREATE PROCEDURE team_follower_standings()
BEGIN
	SELECT team_id, followers, team_name, hex_color FROM team, twitter_info 
		WHERE team.username = twitter_info.username GROUP BY team_id ORDER BY followers DESC;
END //
DELIMITER ;

/* PROCEDURE - DRIVER FOLLWER STANDINGS */
DROP PROCEDURE IF EXISTS driver_follower_standings;
DELIMITER //
CREATE PROCEDURE driver_follower_standings()
BEGIN
	SELECT driver_id, followers, fname, lname, hex_color FROM driver, twitter_info, team
		WHERE driver.username = twitter_info.username AND driver.team_id = team.team_id GROUP BY driver_id ORDER BY followers DESC;
END //
DELIMITER ;

/* PROCEDURE - DRIVER NAME AND COLOR LIST */
DROP PROCEDURE IF EXISTS driver_name_color_list;
DELIMITER //
CREATE PROCEDURE driver_name_color_list()
BEGIN
	SELECT driver_id, fname, lname, hex_color FROM driver, team WHERE driver.team_id = team.team_id;
END //
DELIMITER ;


/* PROCEDURE - PRINCIPAL FOLLWER STANDINGS */
DROP PROCEDURE IF EXISTS principal_follower_standings;
DELIMITER //
CREATE PROCEDURE principal_follower_standings()
BEGIN
	SELECT principal_id, followers FROM principal, twitter_info 
		WHERE principal.username = twitter_info.username GROUP BY principal_id ORDER BY followers DESC;
END //
DELIMITER ;

/* FUNCTION - FOLLOWERS FOR A TEAM */
DROP FUNCTION IF EXISTS team_followers;
DELIMITER //
CREATE FUNCTION team_followers(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT followers FROM twitter_info, team WHERE team_id = id AND team.username = twitter_info.username);
END //
DELIMITER ;

/* FUNCTION - FOLLOWERS FOR A DRIVER */
DROP FUNCTION IF EXISTS driver_followers;
DELIMITER //
CREATE FUNCTION driver_followers(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT followers FROM twitter_info, driver WHERE driver_id = id AND driver.username = twitter_info.username);
END //
DELIMITER ;

/* FUNCTION - FOLLOWERS FOR A PRINCIPAL */
DROP FUNCTION IF EXISTS principal_followers;
DELIMITER //
CREATE FUNCTION principal_followers(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT followers FROM twitter_info, principal WHERE principal_id = id AND principal.username = twitter_info.username);
END //
DELIMITER ;

/* PROCEDURE - TEAM LIKES STANDINGS */
DROP PROCEDURE IF EXISTS team_likes_standings;
DELIMITER //
CREATE PROCEDURE team_likes_standings()
BEGIN
	SELECT team_id, avg_likes, team_name, hex_color FROM team, twitter_info 
		WHERE team.username = twitter_info.username GROUP BY team_id ORDER BY avg_likes DESC;
END //
DELIMITER ;

/* PROCEDURE - DRIVER LIKES STANDINGS */
DROP PROCEDURE IF EXISTS driver_likes_standings;
DELIMITER //
CREATE PROCEDURE driver_likes_standings()
BEGIN
	SELECT driver_id, avg_likes, fname, lname, hex_color FROM driver, twitter_info, team
		WHERE driver.username = twitter_info.username AND driver.team_id = team.team_id GROUP BY driver_id ORDER BY avg_likes DESC;
END //
DELIMITER ;

/* PROCEDURE - PRINCIPAL LIKES STANDINGS */
DROP PROCEDURE IF EXISTS principal_likes_standings;
DELIMITER //
CREATE PROCEDURE principal_likes_standings()
BEGIN
	SELECT principal_id, avg_likes FROM principal, twitter_info 
		WHERE principal.username = twitter_info.username GROUP BY principal_id ORDER BY avg_likes DESC;
END //
DELIMITER ;


/* FUNCTION - LIKES FOR A TEAM */
DROP FUNCTION IF EXISTS team_likes;
DELIMITER //
CREATE FUNCTION team_likes(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT avg_likes FROM twitter_info, team WHERE team_id = id AND team.username = twitter_info.username);
END //
DELIMITER ;

/* FUNCTION - LIKES FOR A DRIVER */
DROP FUNCTION IF EXISTS driver_followers;
DELIMITER //
CREATE FUNCTION driver_followers(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT avg_likes FROM twitter_info, driver WHERE driver_id = id AND driver.username = twitter_info.username);
END //
DELIMITER ;

/* FUNCTION - LIKES FOR A PRINCIPAL */
DROP FUNCTION IF EXISTS principal_followers;
DELIMITER //
CREATE FUNCTION principal_followers(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT avg_likes FROM twitter_info, principal WHERE principal_id = id AND principal.username = twitter_info.username);
END //
DELIMITER ;


/* FUNCTION - TOTAL TEAM SCORE */
DROP FUNCTION IF EXISTS total_team_score;
DELIMITER //
CREATE FUNCTION total_team_score(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN(SELECT SUM(points) AS s FROM result WHERE team_id = id GROUP BY team_id);
END //
DELIMITER ;

/* FUNCTION - TOTAL DRIVER SCORE */
DROP FUNCTION IF EXISTS total_driver_score;
DELIMITER //
CREATE FUNCTION total_driver_score(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN(SELECT SUM(points) AS s FROM result WHERE driver_id = id GROUP BY driver_id);
END //
DELIMITER ;

/* FUNCTION - AVERAGE TEAM SCORE */
DROP FUNCTION IF EXISTS average_team_score;
DELIMITER //
CREATE FUNCTION average_team_score(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN(SELECT AVG(s) AS a FROM (SELECT SUM(points) AS s FROM result WHERE team_id = id GROUP BY race_id) AS racescores);
END //
DELIMITER ;

/* FUNCTION - AVERAGE TEAM SCORE */
DROP FUNCTION IF EXISTS average_driver_score;
DELIMITER //
CREATE FUNCTION average_driver_score(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN(SELECT AVG(s) AS a FROM (SELECT SUM(points) AS s FROM result WHERE driver_id = id GROUP BY race_id) AS racescores);
END //
DELIMITER ;


/* FUNCTION - TEAM WINS */
DROP FUNCTION IF EXISTS count_team_wins;
DELIMITER //
CREATE FUNCTION count_team_wins(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(*) FROM result WHERE team_id = id AND position = 1 GROUP BY team_id);
END //
DELIMITER ;

/* FUNCTION - DRIVER WINS */
DROP FUNCTION IF EXISTS count_driver_wins;
DELIMITER //
CREATE FUNCTION count_driver_wins(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(*) FROM result WHERE driver_id = id AND position = 1 GROUP BY driver_id);
END //
DELIMITER ;

/* FUNCTION - TEAM PODIUMS */
DROP FUNCTION IF EXISTS count_team_podiums;
DELIMITER //
CREATE FUNCTION count_team_podiums(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(*) FROM result WHERE team_id = id AND position < 4 GROUP BY team_id);
END //
DELIMITER ;

/* FUNCTION - DRIVER PODIUMS */
DROP FUNCTION IF EXISTS count_driver_podiums;
DELIMITER //
CREATE FUNCTION count_driver_podiums(id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	RETURN (SELECT COUNT(*) FROM result WHERE driver_id = id AND position < 4 GROUP BY driver_id);
END //
DELIMITER ;

/* PROCEDURE - GET BASIC DRIVER INFO */
DROP PROCEDURE IF EXISTS basic_driver_info;
DELIMITER //
CREATE PROCEDURE basic_driver_info(IN id INT)
BEGIN
	SELECT driver_id, fname, lname, driver.username, team_name, hex_color, driver.team_id FROM driver, team WHERE driver_id = id AND driver.team_id = team.team_id;
END //
DELIMITER ;

/* PROCEDURE - GET team driver points for pie chart */
DROP PROCEDURE IF EXISTS get_dpp;
DELIMITER //
CREATE PROCEDURE get_dpp(IN id INT)
BEGIN
	SELECT SUM(points) AS s, fname, lname FROM (SELECT * FROM result WHERE team_id = id) AS r, driver
		WHERE driver.driver_id = r.driver_id GROUP BY r.driver_id;
END //
DELIMITER ;


/* PROCEDRE - GETS AVERAGE LIKES AND FOLLOWERS FOR TEAMS */
DROP PROCEDURE IF EXISTS team_avg_twitter;
DELIMITER //
CREATE PROCEDURE team_avg_twitter()
BEGIN
	SELECT AVG(followers) AS f, AVG(avg_likes) AS l FROM twitter_info, team WHERE team.username = twitter_info.username;
END //
DELIMITER ;


/* PROCEDRE - GETS AVERAGE LIKES AND FOLLOWERS FOR DRIVERS */
DROP PROCEDURE IF EXISTS driver_avg_twitter;
DELIMITER //
CREATE PROCEDURE driver_avg_twitter()
BEGIN
	SELECT AVG(followers) AS f, AVG(avg_likes) AS l FROM twitter_info, driver WHERE driver.username = twitter_info.username;
END //
DELIMITER ;


/* INITIALIZE DATA */
CALL add_season(2019);

CALL add_race("Melbourne Grand Prix Circuit", '2019-03-17', 2019);
CALL add_race("Bahrain International Circuit", '2019-03-31', 2019);
CALL add_race("Shanghai International Circuit", '2019-04-14', 2019);
CALL add_race("Baku City Circuit", '2019-04-28', 2019);
CALL add_race("Circuit De Barcelona-Catalunya", '2019-05-12', 2019);
CALL add_race("Monte Carlo", '2019-05-26-', 2019);
CALL add_race("Circuit Gilles-Villeneuve", '2019-06-09', 2019);
CALL add_race("Circuit Paul Ricard", '2019-06-23', 2019);
CALL add_race("Red Bull Ring", '2019-06-30', 2019);
CALL add_race("Silverstone", '2019-07-14', 2019);
CALL add_race("Hockenheimring", '2019-07-28', 2019);
CALL add_race("Hungaroring", '2019-08-04', 2019);
CALL add_race("Spa-Francorchamps", '2019-09-01', 2019);
CALL add_race("Autodromo Nazionale Monza", '2019-09-08', 2019);
CALL add_race("Singapore Street Circuit", '2019-09-22', 2019);
CALL add_race("Sochi Autodrome", '2019-09-29', 2019);
CALL add_race("Suzuka", '2019-10-13', 2019);
CALL add_race("Autodromo Hermano Redriguez", '2019-10-27', 2019);
CALL add_race("Circuit of the Americas", '2019-11-03', 2019);
CALL add_race("Autodromo Jose Carlos Pace", '2019-11-17', 2019);
CALL add_race("Yas Marina Circuit", '2019-12-01', 2019);

CALL add_twitter_info("MercedesAMGF1", 2500000, 1134);
CALL add_team("Mercedes", "00D2BE", "MercedesAMGF1");
CALL add_twitter_info("ScuderiaFerrari", 2500000, 1597);
CALL add_team("Ferrari", "DC0000", "ScuderiaFerrari");
CALL add_twitter_info("redbullracing", 2500000, 985);
CALL add_team("Red Bull Racing", "1E41FF", "redbullracing");
CALL add_twitter_info("RenaultF1Team", 1200000, 389);
CALL add_team("Renault", "fff500", "RenaultF1Team");
CALL add_twitter_info("HaasF1Team", 384200, 221);
CALL add_team("Haas", "F0D787", "HaasF1Team");
CALL add_twitter_info("RacingPointF1", 781500, 205);
CALL add_team("Racing Point", "F596C8", "RacingPointF1");
CALL add_twitter_info("AlphaTauriF1", 740200, 317);
CALL add_team("Toro Rosso", "469BFF", "AlphaTauriF1");
CALL add_twitter_info("McLarenF1", 1800000, 764);
CALL add_team("McLaren", "FF8700", "McLarenF1");
CALL add_twitter_info("alfaromeoracing", 798500, 1283);
CALL add_team("Alfa Romeo Racing", "9B0000", "alfaromeoracing");
CALL add_twitter_info("WilliamsRacing", 947100, 548);
CALL add_team("Williams", "419FD9", "WilliamsRacing"); 

CALL add_twitter_info("LewisHamilton", 2300000, 3428);
CALL add_driver("Lewis", "Hamilton", "LewisHamilton", 1);
CALL add_twitter_info("ValtteriBottas", 588800, 1109);
CALL add_driver("Valtteri", "Bottas", "ValtteriBottas", 1);
CALL add_driver("Sebastian", "Vettel", null, 2);
CALL add_twitter_info("Charles_Leclerc", 463000, 2137);
CALL add_driver("Charles", "Leclerc", "Charles_Leclerc", 2);
CALL add_twitter_info("alex_albon", 109900, 1093);
CALL add_driver("Alex", "Albon", "alex_albon", 3);
CALL add_twitter_info("Max33Verstappen", 1100000, 2938);
CALL add_driver("Max", "Verstappen", "Max33Verstappen", 3);
CALL add_twitter_info("HulkHulkenberg", 866800, 2738);
CALL add_driver("Nico", "Hulkenberg", "HulkHulkenberg", 4);
CALL add_twitter_info("danielricciardo", 1700000, 3102);
CALL add_driver("Daniel", "Ricciardo", "danielricciardo", 4);
CALL add_twitter_info("RGrosjean", 867300, 932);
CALL add_driver("Romain", "Grosjean", "RGrosjean", 5);
CALL add_twitter_info("KevinMagnussen", 499600, 893);
CALL add_driver("Kevin", "Magnussen", "KevinMagnussen", 5);
CALL add_twitter_info("SChecoPerez", 2000000, 738);
CALL add_driver("Sergio", "Perez", "SChecoPerez", 6);
CALL add_twitter_info("lance_stroll", 120000, 349);
CALL add_driver("Lance", "Stroll", "lance_stroll", 6);
CALL add_twitter_info("PierreGASLY", 225900, 1528);
CALL add_driver("Pierre", "Gasly", "PierreGASLY", 7);
CALL add_twitter_info("kvyatofficial", 184400, 837);
CALL add_driver("Daniil", "Kvyat", "kvyatofficial", 7);
CALL add_twitter_info("LandoNorris", 382500, 2548);
CALL add_driver("Lando", "Norris", "LandoNorris", 8);
CALL add_twitter_info("Carlossainz55", 557500, 738);
CALL add_driver("Carlos", "Sainz", "Carlossainz55", 8);
CALL add_driver("Kimi", "Raikkonen", null, 9);
CALL add_twitter_info("Anto_Giovinazzi", 122000, 589);
CALL add_driver("Antonio", "Giovinazzi", "Anto_Giovinazzi", 9);
CALL add_twitter_info("R_Kubica", 103922, 689);
CALL add_driver("Robert", "Kubica", "R_Kubica", 10);
CALL add_twitter_info("GeorgeRussell63", 148000, 2302);
CALL add_driver("George", "Russell", "GeorgeRussell63", 10);

CALL add_principal("Toto", "Wolff", null, 1);
CALL add_principal("Mattia", "Binotto", null,  2);
CALL add_principal("Christian", "Horner", null, 3);
CALL add_principal("Cyril", "Abiteboul", null, 4);
CALL add_principal("Guenther", "Steiner", null, 5);
CALL add_principal("Otmar", "Szafnauer", null, 6);
CALL add_principal("Franz", "Tost", null, 7);
CALL add_principal("Andreas", "Seidl", null, 3);
CALL add_principal("Frank", "Williams", null, 3);


/* AUSTRALIA */
CALL add_result(1, 2, 1, 1, TRUE);
CALL add_result(2, 1, 1, 1, FALSE);
CALL add_result(3, 6, 3, 1, FALSE);
CALL add_result(4, 3, 2, 1, FALSE);
CALL add_result(5, 4, 2, 1, FALSE);
CALL add_result(14, 5, 3, 1, FALSE);
CALL add_result(7, 7, 4, 1, FALSE);
CALL add_result(19, 8, 4, 1, FALSE);
CALL add_result(6, 10, 5, 1, FALSE);
CALL add_result(9, 12, 6, 1, FALSE);
CALL add_result(10, 14, 7, 1, FALSE);
CALL add_result(8, 17, 9, 1, FALSE);

/* BAHRAIN */
CALL add_result(1, 1, 1, 2, FALSE);
CALL add_result(2, 2, 1, 2, FALSE);
CALL add_result(3, 4, 2, 2, TRUE);
CALL add_result(4, 6, 3, 2, FALSE);
CALL add_result(5, 3, 2, 2, FALSE);
CALL add_result(9, 5, 3, 2, FALSE);
CALL add_result(17, 7, 4, 2, FALSE);
CALL add_result(18, 8, 4, 2, FALSE);
CALL add_result(10, 11, 6, 2, FALSE);
CALL add_result(8, 13, 7, 2, FALSE);
CALL add_result(6, 15, 8, 2, FALSE);
CALL add_result(7, 17, 9, 2, FALSE);


/* CHINA */
CALL add_result(1, 1, 1, 3, FALSE);
CALL add_result(2, 2, 1, 3, FALSE);
CALL add_result(3, 3, 2, 3, FALSE);
CALL add_result(4, 6, 3, 3, FALSE);
CALL add_result(5, 4, 2, 3, FALSE);
CALL add_result(10, 5, 3, 3, FALSE);
CALL add_result(7, 8, 4, 3, FALSE);
CALL add_result(20, 7, 4, 3, FALSE);
CALL add_result(8, 11, 6, 3, FALSE);
CALL add_result(6, 13, 7, 3, TRUE);
CALL add_result(9, 17, 9, 3, FALSE);

/* AZERBEIJAN */
CALL add_result(1, 2, 1, 4, FALSE);
CALL add_result(2, 1, 1, 4, FALSE);
CALL add_result(3, 3, 2, 4, FALSE);
CALL add_result(4, 6, 3, 4, FALSE);
CALL add_result(5, 4, 2, 4, TRUE);
CALL add_result(11, 5, 3, 4, FALSE);
CALL add_result(14, 7, 4, 4, FALSE);
CALL add_result(20, 8, 4, 4, FALSE);
CALL add_result(6, 11, 6, 4, FALSE);
CALL add_result(9, 12, 6, 4, FALSE);
CALL add_result(7, 16, 8, 4, FALSE);
CALL add_result(8, 15, 8, 4, FALSE);
CALL add_result(10, 17, 9, 4, FALSE);

/* SPAIN */
CALL add_result(1, 1, 1, 5, TRUE);
CALL add_result(2, 2, 1, 5, FALSE);
CALL add_result(3, 6, 3, 5, FALSE);
CALL add_result(4, 3, 2, 5, FALSE);
CALL add_result(5, 4, 2, 5, FALSE);
CALL add_result(11, 5, 3, 5, FALSE);
CALL add_result(12, 8, 4, 5, FALSE);
CALL add_result(13, 7, 4, 5, FALSE);
CALL add_result(7, 10, 5, 5, FALSE);
CALL add_result(10, 9, 5, 5, FALSE);
CALL add_result(6, 13, 7, 5, FALSE);
CALL add_result(9, 14, 7, 5, FALSE);
CALL add_result(8, 16, 8, 5, FALSE);


/* MONACO */
CALL add_result(1, 1, 1, 6, FALSE);
CALL add_result(2, 3, 2, 6, FALSE);
CALL add_result(3, 2, 1, 6, FALSE);
CALL add_result(4, 6, 3, 6, FALSE);
CALL add_result(8, 5, 3, 6, FALSE);
CALL add_result(20, 4, 2, 6, FALSE);
CALL add_result(9, 8, 4, 6, FALSE);
CALL add_result(13, 7, 4, 6, FALSE);
CALL add_result(10, 9, 5, 6, FALSE);
CALL add_result(5, 13, 7, 6, FALSE);
CALL add_result(7, 14, 7, 6, FALSE);
CALL add_result(6, 16, 8, 6, FALSE);

/* CANADA */
CALL add_result(1, 1, 1, 7, FALSE);
CALL add_result(2, 3, 2, 7, FALSE);
CALL add_result(3, 4, 2, 7, FALSE);
CALL add_result(4, 2, 1, 7, TRUE);
CALL add_result(5, 6, 3, 7, FALSE);
CALL add_result(19, 5, 3, 7, FALSE);
CALL add_result(6, 8, 4, 7, FALSE);
CALL add_result(7, 7, 4, 7, FALSE);
CALL add_result(9, 12, 6, 7, FALSE);
CALL add_result(8, 13, 7, 7, FALSE);
CALL add_result(10, 14, 7, 7, FALSE);

/* FRANCE */
CALL add_result(1, 1, 1, 8, FALSE);
CALL add_result(2, 2, 1, 8, FALSE);
CALL add_result(2, 4, 2, 8, FALSE);
CALL add_result(4, 6, 3, 8, FALSE);
CALL add_result(5, 3, 2, 8, TRUE);
CALL add_result(15, 5, 3, 8, FALSE);
CALL add_result(8, 7, 4, 8, FALSE);
CALL add_result(11, 8, 4, 8, FALSE);
CALL add_result(10, 13, 7, 8, FALSE);
CALL add_result(6, 16, 8, 8, FALSE);
CALL add_result(9, 15, 8, 8, FALSE);
CALL add_result(7, 17, 9, 8, FALSE);

/* AUSTRIA */
CALL add_result(1, 6, 3, 9, TRUE);
CALL add_result(2, 4, 2, 9, FALSE);
CALL add_result(3, 2, 1, 9, FALSE);
CALL add_result(4, 3, 2, 9, FALSE);
CALL add_result(5, 1, 1, 9, FALSE);
CALL add_result(15, 5, 3, 9, FALSE);
CALL add_result(12, 8, 4, 9, FALSE);
CALL add_result(13, 7, 4, 9, FALSE);
CALL add_result(7, 13, 7, 9, FALSE);
CALL add_result(6, 15, 8, 9, FALSE);
CALL add_result(8, 16, 8, 9, FALSE);
CALL add_result(9, 17, 9, 9, FALSE);
CALL add_result(10, 18, 9, 9, FALSE);

/* BRITAIN */
CALL add_result(1, 1, 1, 10, TRUE);
CALL add_result(2, 2, 1, 10, FALSE);
CALL add_result(3, 4, 2, 10, FALSE);
CALL add_result(5, 6, 3, 10, FALSE);
CALL add_result(12, 5, 3, 10, FALSE);
CALL add_result(16, 3, 2, 10, FALSE);
CALL add_result(7, 8, 4, 10, FALSE);
CALL add_result(10, 7, 4, 10, FALSE);
CALL add_result(4, 13, 7, 10, FALSE);
CALL add_result(9, 14, 7, 10, FALSE);
CALL add_result(6, 16, 8, 10, FALSE);
CALL add_result(8, 17, 9, 10, FALSE);

/* GERMANY */
CALL add_result(1, 6, 3, 11, TRUE);
CALL add_result(2, 3, 2, 11, FALSE);
CALL add_result(6, 5, 3, 11, FALSE);
CALL add_result(9, 1, 1, 11, FALSE);
CALL add_result(15, 2, 1, 11, FALSE);
CALL add_result(17, 4, 2, 11, FALSE);
CALL add_result(16, 7, 4, 11, FALSE);
CALL add_result(19, 8, 4, 11, FALSE);
CALL add_result(7, 9, 5, 11, FALSE);
CALL add_result(8, 10, 5, 11, FALSE);
CALL add_result(4, 12, 6, 11, FALSE);
CALL add_result(3, 14, 7, 11, FALSE);
CALL add_result(5, 16, 8, 11, FALSE);
CALL add_result(10, 19, 10, 11, FALSE);

/* HUNGARY */
CALL add_result(1, 1, 1, 12, FALSE);
CALL add_result(2, 6, 3, 12, TRUE);
CALL add_result(3, 3, 2, 12, FALSE);
CALL add_result(4, 4, 2, 12, FALSE);
CALL add_result(8, 2, 1, 12, FALSE);
CALL add_result(10, 5, 3, 12, FALSE);
CALL add_result(12, 7, 4, 12, FALSE);
CALL add_result(14, 8, 4, 12, FALSE);
CALL add_result(6, 14, 7, 12, FALSE);
CALL add_result(5, 16, 8, 12, FALSE);
CALL add_result(9, 15, 8, 12, FALSE);
CALL add_result(7, 17, 9, 12, FALSE);

/* BELGIUM */
CALL add_result(1, 4, 2, 13, FALSE);
CALL add_result(2, 1, 1, 13, FALSE);
CALL add_result(3, 2, 1, 13, FALSE);
CALL add_result(4, 3, 2, 13, TRUE);
CALL add_result(5, 5, 3, 13, FALSE);
CALL add_result(20, 6, 3, 13, FALSE);
CALL add_result(8, 7, 4, 13, FALSE);
CALL add_result(14, 8, 4, 13, FALSE);
CALL add_result(6, 11, 6, 13, FALSE);
CALL add_result(10, 12, 6, 13, FALSE);
CALL add_result(7, 14, 7, 13, FALSE);
CALL add_result(9, 13, 7, 13, FALSE);

/* ITALY */
CALL add_result(1, 4, 2, 14, FALSE);
CALL add_result(2, 2, 1, 14, FALSE);
CALL add_result(3, 1, 1, 14, TRUE);
CALL add_result(6, 5, 3, 14, FALSE);
CALL add_result(8, 6, 3, 14, FALSE);
CALL add_result(13, 3, 2, 14, FALSE);
CALL add_result(4, 8, 4, 14, FALSE);
CALL add_result(5, 7, 4, 14, FALSE);
CALL add_result(7, 11, 6, 14, FALSE);
CALL add_result(10, 15, 8, 14, FALSE);
CALL add_result(9, 18, 9, 14, FALSE);

/* SINGAPORE */
CALL add_result(1, 3, 2, 15, FALSE);
CALL add_result(2, 4, 2, 15, FALSE);
CALL add_result(3, 6, 3, 15, FALSE);
CALL add_result(4, 1, 1, 15, FALSE);
CALL add_result(5, 2, 1, 15, FALSE);
CALL add_result(6, 5, 3, 15, FALSE);
CALL add_result(9, 7, 4, 15, FALSE);
CALL add_result(14, 8, 4, 15, FALSE);
CALL add_result(8, 13, 7, 15, FALSE);
CALL add_result(7, 15, 8, 15, FALSE);
CALL add_result(10, 18, 9, 15, FALSE);

/* RUSSIA */
CALL add_result(1, 1, 1, 16, TRUE);
CALL add_result(2, 2, 1, 16, FALSE);
CALL add_result(3, 4, 2, 16, FALSE);
CALL add_result(4, 6, 3, 16, FALSE);
CALL add_result(5, 5, 3, 16, FALSE);
CALL add_result(18, 3, 2, 16, FALSE);
CALL add_result(10, 7, 4, 16, FALSE);
CALL add_result(19, 8, 4, 16, FALSE);
CALL add_result(9, 10, 5, 16, FALSE);
CALL add_result(6, 16, 8, 16, FALSE);
CALL add_result(7, 11, 6, 16, FALSE);
CALL add_result(8, 15, 8, 16, FALSE);

/* JAPAN */
CALL add_result(1, 2, 1, 17, FALSE);
CALL add_result(2, 3, 2, 17, FALSE);
CALL add_result(3, 1, 1, 17, TRUE);
CALL add_result(4, 5, 3, 17, FALSE);
CALL add_result(6, 4, 2, 17, FALSE);
CALL add_result(18, 6, 3, 17, FALSE);
CALL add_result(19, 7, 4, 17, FALSE);
CALL add_result(20, 8, 4, 17, FALSE);
CALL add_result(8, 11, 6, 17, FALSE);
CALL add_result(9, 12, 6, 17, FALSE);
CALL add_result(7, 13, 7, 17, FALSE);
CALL add_result(10, 14, 7, 17, FALSE);
CALL add_result(5, 16, 8, 17, FALSE);

/* MEXICO */
CALL add_result(1, 1, 1, 18, FALSE);
CALL add_result(2, 3, 2, 18, FALSE);
CALL add_result(3, 2, 1, 18, FALSE);
CALL add_result(4, 4, 2, 18, TRUE);
CALL add_result(5, 5, 3, 18, FALSE);
CALL add_result(6, 6, 3, 18, FALSE);
CALL add_result(8, 8, 4, 18, FALSE);
CALL add_result(10, 7, 4, 18, FALSE);
CALL add_result(7, 11, 6, 18, FALSE);
CALL add_result(9, 13, 7, 18, FALSE);

/* UNITED STATES */
CALL add_result(1, 2, 1, 19, FALSE);
CALL add_result(2, 1, 1, 19, FALSE);
CALL add_result(3, 6, 3, 19, FALSE);
CALL add_result(4, 4, 2, 19, TRUE);
CALL add_result(5, 5, 3, 19, FALSE);
CALL add_result(20, 3, 2, 19, FALSE);
CALL add_result(6, 8, 4, 19, FALSE);
CALL add_result(9, 7, 4, 19, FALSE);
CALL add_result(10, 11, 6, 19, FALSE);
CALL add_result(7, 15, 8, 19, FALSE);
CALL add_result(8, 16, 8, 19, FALSE);

/* BRAZIL */
CALL add_result(1, 6, 3, 20, FALSE);
CALL add_result(7, 1, 1, 20, FALSE);
CALL add_result(14, 5, 3, 20, FALSE);
CALL add_result(17, 3, 2, 20, FALSE);
CALL add_result(18, 4, 2, 20, FALSE);
CALL add_result(20, 2, 1, 20, FALSE);
CALL add_result(6, 8, 4, 20, FALSE);
CALL add_result(15, 7, 4, 20, FALSE);
CALL add_result(9, 11, 6, 20, FALSE);
CALL add_result(2, 13, 7, 20, FALSE);
CALL add_result(10, 14, 7, 20, FALSE);
CALL add_result(3, 16, 8, 20, FALSE);
CALL add_result(8, 15, 8, 20, FALSE);
CALL add_result(4, 17, 9, 20, FALSE);
CALL add_result(5, 18, 9, 20, FALSE);

/* ABU DHABI */
CALL add_result(1, 1, 1, 21, TRUE);
CALL add_result(2, 6, 3, 21, FALSE);
CALL add_result(3, 4, 2, 21, FALSE);
CALL add_result(4, 2, 1, 21, FALSE);
CALL add_result(5, 3, 2, 21, FALSE);
CALL add_result(6, 5, 3, 21, FALSE);
CALL add_result(11, 8, 4, 21, FALSE);
CALL add_result(12, 7, 4, 21, FALSE);
CALL add_result(7, 11, 6, 21, FALSE);
CALL add_result(9, 14, 7, 21, FALSE);
CALL add_result(8, 15, 8, 21, FALSE);
CALL add_result(10, 16, 8, 21, FALSE);


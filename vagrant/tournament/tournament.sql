-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

\c vagrant
DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament
CREATE TABLE players(id SERIAL PRIMARY KEY,
										 NAME TEXT,
										 standing INTEGER);

--Not needed for initial tests.
--CREATE TABLE tournaments(id SERIAL PRIMARY KEY,
--												 date_held DATE,
--												 location TEXT);

CREATE TABLE matches(id SERIAL PRIMARY KEY,
										 winner INTEGER REFERENCES players(id),
										 loser INTEGER REFERENCES players(id));

--Not needed yet.
--CREATE TABLE match_ownership(id SERIAL PRIMARY KEY,
--														 tournament_id INTEGER REFERENCES 
--															 tournaments(id),
--														 match_id INTEGER REFERENCES matches(id));

--Not needed at this stage - only for multi-tournament play.
--CREATE TABLE standings(player_id INTEGER REFERENCES players(id),
--											 tournament_id INTEGER REFERENCES tournaments(id),
--											 original_rank INTEGER,
--											 had_bye BOOLEAN,
--											 standing REAL,
--											 PRIMARY KEY(player_id, tournament_id));

CREATE VIEW player_wins AS
	SELECT players.id, players.NAME, count(matches.winner) AS wins FROM players
	left join matches
	ON players.id = matches.winner
	GROUP BY players.id;

CREATE VIEW player_losses AS
	SELECT players.id, count(matches.loser) AS losses FROM players
	left join matches
	ON players.id = matches.loser
	GROUP BY players.id;

CREATE VIEW player_totals AS
	SELECT player_wins.id, player_wins.wins + player_losses.losses AS totals
	FROM player_wins
	join player_losses
	ON player_wins.id = player_losses.id;

CREATE VIEW player_standings AS
	SELECT player_wins.id,
		player_wins.NAME,
		player_wins.wins,
		player_totals.totals
	FROM player_wins
	join player_totals ON player_wins.id = player_totals.id;

-- Viewports for swissPairings()
-- NOT NEEDED ANY MORE
CREATE VIEW pairings AS
	SELECT
			a.id AS id1,
			a.standing AS standing1,
			b.id AS id2,
			b.standing AS standing2
		FROM players AS a
		left join players AS b
			ON a.id = b.id - 1
		WHERE a.id %2 = 1
		ORDER BY a.standing DESC;

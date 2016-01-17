-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- Setup commands.
\c vagrant
DROP DATABASE IF EXISTS tournament;
CREATE DATABASE tournament;
\c tournament

CREATE TABLE players(id SERIAL PRIMARY KEY,
										 NAME TEXT,
										 standing INTEGER);

CREATE TABLE matches(id SERIAL PRIMARY KEY,
										 winner INTEGER REFERENCES players(id),
										 loser INTEGER REFERENCES players(id));

-- Viewports for playerStandings function.
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

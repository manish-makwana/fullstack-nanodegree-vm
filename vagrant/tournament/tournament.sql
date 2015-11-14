-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

CREATE DATABASE tournament;
\c tournament
CREATE TABLE players(id SERIAL PRIMARY KEY,
										 NAME TEXT);

CREATE TABLE tournaments(id SERIAL PRIMARY KEY,
												 date_held DATE,
												 location TEXT);

CREATE TABLE matches(id SERIAL PRIMARY KEY,
										 winner INTEGER REFERENCES players(id),
										 loser INTEGER REFERENCES players(id));

CREATE TABLE match_ownership(id SERIAL PRIMARY KEY,
														 tournament_id INTEGER REFERENCES 
															 tournaments(id),
														 match_id INTEGER REFERENCES matches(id));

CREATE TABLE standings(player_id INTEGER REFERENCES players(id),
											 tournament_id INTEGER REFERENCES tournaments(id),
											 original_rank INTEGER,
											 had_bye BOOLEAN,
											 standing REAL,
											 PRIMARY KEY(player_id, tournament_id));

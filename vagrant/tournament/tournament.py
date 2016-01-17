#!/usr/bin/env python

"""
tournament.py -- implementation of a Swiss-system tournament
"""

import psycopg2
import bleach
import itertools


def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


def deleteMatches():
    """Remove all the match records from the database."""
    conn = connect()
    c = conn.cursor()
    c.execute("delete from matches;")
    conn.commit()
    conn.close()


def deletePlayers():
    """Remove all the player records from the database."""
    conn = connect()
    c = conn.cursor()
    c.execute("delete from players;")
    conn.commit()
    conn.close()


def countPlayers():
    """Returns the number of players currently registered."""
    conn = connect()
    c = conn.cursor()
    c.execute("select count(id) as num from players;")
    count = c.fetchall()
    conn.close()
    return count[0][0]


def registerPlayer(name):
    """Adds a player to the tournament database.

    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)

    Args:
      name: the player's full name (need not be unique).
    """
    c_name = bleach.clean(name)
    conn = connect()
    c = conn.cursor()
    c.execute("insert into players(name, standing) "
              "values(%s, 0);", (c_name,))
    conn.commit()
    conn.close()


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a
    player tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    conn = connect()
    c = conn.cursor()
    # Use a viewport to simplify the query.
    c.execute("select * from player_standings order by wins desc;")
    standings = c.fetchall()
    conn.close()
    return standings


def reportMatch(winner, loser):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    c_winner = bleach.clean(winner)
    c_loser = bleach.clean(loser)
    conn = connect()
    c = conn.cursor()
    # Add record of who played in match.
    c.execute("insert into matches(winner, loser) values(%s, %s);",
              (c_winner, c_loser))
    # Increment the winner's standing.
    c.execute("update players "
              "set standing = standing + 1 "
              "where id = %s;", (winner,))
    conn.commit()
    conn.close()


def swissPairings():
    """Returns a list of pairs of players for the next round of a match.

    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.

    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    players = playerStandings()
    # Remove wins and matches - we only need IDs and names.
    players_trimmed = [x[:-2] for x in players]
    # Pair up adjacent players (ranked by number of wins).
    pairs = zip(players_trimmed[0::2], players_trimmed[1::2])
    # Unpack the nested tuples to get the desired output.
    pairs_unpacked = []
    for pair in pairs:
        pairs_unpacked.append(tuple(itertools.chain(*pair)))
    return pairs_unpacked

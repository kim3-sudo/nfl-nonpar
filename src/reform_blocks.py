#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 16:36:04 2021

@author: kim3
"""

import pandas as pd
from tqdm import tqdm

def yardsum(team, stadium, dataframe):
    """
    Sum yards for a team by stadium

    Parameters
    ----------
    team : string
        The two or three letter team string code
    stadium : string
        The stadium ID four, five, or six character code.
    dataframe : Pandas dataframe
        A dataframe to sum yards by (if you want to use temp DFs)

    Returns
    -------
    sum : int
        Sum of yards by that team in that stadium

    """
    yardsum = 0
    for index, row in tqdm(dataframe.iterrows(), desc = team + ' at ' + stadium):
        if (row.get("posteam") == team and row.get("stadium_id") == stadium):
            yardsum = yardsum + int(row.get("yards"))
    return yardsum

def narow(team, dataframe):
    """
    Generate a list of indices to remove from dataframe

    Parameters
    ----------
    team : string
        The team to check (home/away)

    Returns
    -------
    nothere : list of integers
        The rows that you can remove.

    """
    nothere = []
    current = 0
    for index, row in tqdm(dataframe.iterrows()):
        # if they're not the home team or the away team
        home = str(row["home_team"]).strip().upper()
        away = str(row["away_team"]).strip().upper()
        team = team.strip().upper()
        #print(home, away, team)
        if ((home != team and away != team) == True):
            #print(home != team or away != team)
            nothere.append(current)
        current += 1
        #if current > 150:
         #   break
    return nothere

df = pd.read_csv("~/Documents/nfl-nonpar/data/nfl.csv")
df['posteam'] = df['posteam'].astype('str')

blocked = pd.DataFrame(columns = ["ATL00", "ATL97", "BAL00", "BOS00", "BUF00", "BUF01", "CAR00", "CHI98", "CIN00", "CLE00", "DAL00", "DEN00", "DET00", "GNB00", "HOU00", "IND00", "JAX00", "KAN00", "LAX01", "LAX97", "LAX99", "LON00", "LON01", "LON02", "MEX00", "MIA00", "MIN00", "MIN01", "MIN98", "NAS00","NOR00", "NYC01", "OAK00", "PHI00", "PHO00", "PIT00", "SDG00", "SEA00", "SFO00", "SFO01", "STL00", "TAM00", "VEG00", "WAS00"])

teams = ["ARI", "ATL", "BAL", "BUF", "CAR", "CHI", "CIN", "CLE", "DAL", "DEN", "DET", "GB", "HOU", "IND", "JAX", "KC", "LA", "LAC", "LV", "MIA", "MIN", "NE", "NO", "NYG", "NYJ", "PHI", "PIT", "SEA", "SF", "TB", "TEN", "WAS"]
stadiums = ["ATL00", "ATL97", "BAL00", "BOS00", "BUF00", "BUF01", "CAR00", "CHI98", "CIN00", "CLE00", "DAL00", "DEN00", "DET00", "GNB00", "HOU00", "IND00", "JAX00", "KAN00", "LAX01", "LAX97", "LAX99", "LON00", "LON01", "LON02", "MEX00", "MIA00", "MIN00", "MIN01", "MIN98", "NAS00","NOR00", "NYC01", "OAK00", "PHI00", "PHO00", "PIT00", "SDG00", "SEA00", "SFO00", "SFO01", "STL00", "TAM00", "VEG00", "WAS00"]

blocked.reindex(teams)

for team in teams:
    print("Processing:", team)
    yardage = pd.Series(dtype=int)
    tempdf = df
    print("Calculating not applicable rows to remove")
    tempdf = tempdf.drop(narow(team, dataframe = tempdf))
    print("Removed NA rows", sep="")
    for stadium in stadiums:
        yards = yardsum(team = team, stadium = stadium, dataframe = tempdf)
        print("Got " + str(yards) + " yards")
        yardage = yardage.append(pd.Series([yards]))
    yardage = yardage.tolist()
    blocked.loc[team] = yardage

blocked.to_csv("~/Documents/nfl-nonpar/data/blocked.csv")

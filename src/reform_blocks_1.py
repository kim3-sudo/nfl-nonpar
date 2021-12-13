#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 12 16:56:40 2021

@author: kim3
"""

import pandas as pd
from tqdm import tqdm

df = pd.read_csv("~/Documents/nfl-nonpar/data/nfl.csv")
df['posteam'] = df['posteam'].astype('str')

blocked = pd.DataFrame({"game": pd.Series(dtype='str'), "posteam": pd.Series(dtype='str'), "yards": pd.Series(dtype='int'), "stadium": pd.Series(dtype='str')})

for index in tqdm(range(len(df))):
    game_id = str(df.iloc[index, 1]).strip().upper() # game_id
    yards = int(df.iloc[index, 11]) # yards
    posteam = str(df.iloc[index, 5]).strip().upper() # posteam
    #if game_id not in blocked.values:
    if ((blocked['game'] == game_id) & (blocked['posteam'] == posteam)).any() == False:
        # add game_id to blocked
        stadium = str(df.iloc[index, 2]).strip().upper() # stadium_id
        s = [game_id, posteam, yards, stadium]
        blocked.loc[len(blocked)] = s
        #blocked = blocked.append(s, ignore_index = True)
    else:
        # get location of match
        loc = blocked[(blocked['game'] == game_id) & (blocked['posteam'] == posteam)].index[0] #blocked.index[((blocked['game'] == game_id) & (blocked['posteam'] == posteam)).all().all()]
        # edit game_id in blocked at location
        blocked.at[loc, 'yards'] = int(blocked.at[loc, 'yards']) + int(df.iloc[index, 11]) # yards
        
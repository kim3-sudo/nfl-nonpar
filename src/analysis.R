### NFL Data Analysis
### Sejin Kim
### STAT 216 F21 @ Kenyon College

# Load libraries
library(mosaic) # For EDA
library(NSM3) # For Durbin-Skillings-Mack
library(mice) # For MICE procedure
library(Kendall) # For Mann-Kendall
library(trend) # For Sen's slope
library(PMCMRplus) # For Skillings-Mack rank sum test for partially balacned incomplete block designs

# Load data
data <- readRDS(url('https://github.com/kim3-sudo/nfl_analysis_data/blob/main/nflfastr_pbp_2010_to_2020.rds?raw=true'))

# Data Handling
nfl <- filter(data, play_type == "kickoff" | play_type == "pass" | play_type == "punt" | play_type == "field_goal" & season_type == "REG")
nfl <- nfl[, c("game_id"
               , "stadium_id"
               , "play_type"
               , "kick_distance"
               , "passing_yards"
               , "return_yards"
               , "air_yards")]
nfl$max_yards <- pmax(nfl$kick_distance, nfl$passing_yards, nfl$return_yards, nfl$air_yards, na.rm = TRUE)
mousey <- mice(nfl)
nfl <- complete(mousey)
View(nfl)

# EDA

# Friedman Procedure
## Distribution-Free Test for General Alternatives in a Randomized Block Design
## Response: Distance (*_yards)
## Blocks: Game (game_id)
## Treatments: Stadiums (stadium_id)
pMackSkil(nfl$max_yards, nfl$stadium_id, nfl$game_id)

# Durbin-Skillings-Mack Procedure
## Distribution-Free Test for General Alternatives in a Randomized Balanced Incomplete Block Design
## Response: Distance (*_yards)
## Blocks: Game (game_id)
## Treatments Stadiums (stadium_id)
pDurSkiMa(nfl$max_yards, b = nfl$game_id, trt = nfl$stadium_id, method = "Monte Carlo", n.mc = 1000)
# 
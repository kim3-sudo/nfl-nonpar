### NFL Data Analysis
### Sejin Kim
### STAT 216 F21 @ Kenyon College

# Load libraries
library(mosaic)
library(NSM3)
library(mice)
library(Kendall)
library(trend)
library(dplyr)
library(matrixStats)

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
nfl$yards_gained <- rowMaxs(as.matrix((nfl[, c(4, 5, 6, 7)])))
View(nfl)


# EDA

# Friedman Procedure
## Distribution-Free Test for General Alternatives in a Randomized Block Design
## Response: Distance (*_yards)
## Blocks: Game (game_id)
## Treatments: Stadiums (stadium_id)

# Durbin-Skillings-Mack Procedure
## Distribution-Free Test for General Alternatives in a Randomized Balanced Incomplete Block Design
## Response: Distance (*_yards)
## Blocks: Game (game_id)
## Treatments Stadiums (stadium_id)

# 
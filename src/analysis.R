### NFL Data Analysis
### Sejin Kim
### STAT 216 F21 @ Kenyon College

# Load libraries
library(dplyr) # For data filtering
library(mosaic) # For EDA
library(data.table) # For frequency approximation
library(mice) # For MICE procedure
library(Kendall) # For Mann-Kendall
library(trend) # For Sen's slope
library(FSA) # For Dunn's Test

# Make a new blocked dataframe
# treatments (across): stadium_id
# groups (down): teams
# response (cell): total yards gained in that stadium
blocked <- read.csv(url("https://raw.githubusercontent.com/kim3-sudo/nfl-nonpar/main/data/blocked.csv"))

# Test differences between stadiums by yards
kruskal.test(blocked$yards, g = blocked$stadium)

# Test differences between teams by yards
kruskal.test(blocked$yards, g = blocked$posteam)

# Stadiums Multiple Comparisons
# Dwass, Steel, Critchlow-Fligner Test
dscfAllPairsTest(blocked$yards, g=as.factor(blocked$stadium))
# Dunn's Test with Bonferroni correction
dunnTest(yards~stadium, data = blocked, method = "bonferroni")

# Teams Multiple Comparisons
dscfAllPairsTest(blocked$yards, g=as.factor(blocked$posteam))
# Dunn's Test with Bonferroni correction
dunnTest(yards~posteam, data = blocked, method = "bonferroni")

# Load data
data <- readRDS(url('https://github.com/kim3-sudo/nfl_analysis_data/blob/main/nflfastr_pbp_2010_to_2020.rds?raw=true'))

# Data Handling
nfl <- filter(data, play_type == "kickoff" | play_type == "pass" | play_type == "punt" | play_type == "field_goal" & season_type == "REG")
nfl <- nfl[, c("game_id"
               , "stadium_id"
               , "home_team"
               , "away_team"
               , "posteam"
               , "play_type"
               , "kick_distance"
               , "passing_yards"
               , "return_yards"
               , "air_yards")]
mousey <- mice(nfl)
nfl <- complete(mousey)
nfl$yards <- pmax(nfl$kick_distance, nfl$passing_yards, nfl$return_yards, nfl$air_yards, na.rm = TRUE)
View(nfl)

# Kendall Time Series Procedure
keys <- nfl$game_id
counts <- data.frame(table(keys))
counts <- data.frame(counts)
favstats(counts$Freq) # to find an average frequency of 97
# because there are so many obs, we can take this frequency to be roughly averaged
TS = ts(nfl$yards, frequency = 97, start = 2010, end = 2020)
TS
plot(TS, main="Time Series of Distances")
plot(decompose(TS))
plot(stl(TS, s.window="periodic"), main = "Remainder, Trends, and Seasonality")
MK = MannKendall(TS)
summary(MK)

# Sen's slope for time series data
sens.slope(TS)


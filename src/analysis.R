### NFL Data Analysis
### Sejin Kim
### STAT 216 F21 @ Kenyon College

# Load libraries
library(mosaic) # For EDA
library(data.table) # For frequency approximation
library(NSM3) # For Durbin-Skillings-Mack
library(mice) # For MICE procedure
library(Kendall) # For Mann-Kendall
library(trend) # For Sen's slope
library(PMCMRplus) # For Skillings-Mack rank sum test for partially balacned incomplete block designs
library(progress) # For dataframe building

# Load data
data <- readRDS(url('https://github.com/kim3-sudo/nfl_analysis_data/blob/main/nflfastr_pbp_2010_to_2020.rds?raw=true'))

# Data Handling
nfl <- filter(data, play_type == "kickoff" | play_type == "pass" | play_type == "punt" | play_type == "field_goal" & season_type == "REG")
nfl <- nfl[, c("game_id"
               , "stadium_id"
               , "home_team"
               , "away_team"
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

## Based on the time series analyses (not significant for everything), there's no reason for us to not just clump everything together
# Make a new blocked dataframe
# treatments (across): stadium_id
# groups (down): teams
# response (cell): total yards gained in that stadium
blocked <- data.frame("team", "ATL00", "ATL97", "BAL00", "BOS00", "BUF00", "BUF01", "CAR00", "CHI98", "CIN00", "CLE00", "DAL00", "DEN00", "DET00", "GNB00", "HOU00", "IND00", "JAX00", "KAN00", "LAX01", "LAX97", "LAX99", "LON00", "LON01", "LON02", "MEX00", "MIA00", "MIN00", "MIN01", "MIN98", "NAS00","NOR00", "NYC01", "OAK00", "PHI00", "PHO00", "PIT00", "SDG00", "SEA00", "SFO00", "SFO01", "STL00", "TAM00", "VEG00", "WAS00")
yardsum <- function(team, stadium) {
  sum = 0
  pb <- progress_bar$new(total = nrow(nfl), format = paste("[:bar]:percent", team, "at", stadium, "overall progress"))
  for (row in 1:nrow(nfl)) {
    pb$tick()
    home_team <- nfl[row, "home_team"]
    yards <- nfl[row, "yards"]
    if (home_team == team) {
      sum = sum + yards
    } else {
      sum = sum
    }
  }
  return(sum)
}

teams <- c("ARI", "ATL", "BAL", "BUF", "CAR", "CHI", "CIN", "CLE", "DAL", "DEN", "DET", "GB", "HOU", "IND", "JAX", "KC", "LA", "LAC", "LV", "MIA", "MIN", "NE", "NO", "NYG", "NYJ", "PHI", "PIT", "SEA", "SF", "TB", "TEN", "WAS")
stadiums <- c("ATL00", "ATL97", "BAL00", "BOS00", "BUF00", "BUF01", "CAR00", "CHI98", "CIN00", "CLE00", "DAL00", "DEN00", "DET00", "GNB00", "HOU00", "IND00", "JAX00", "KAN00", "LAX01", "LAX97", "LAX99", "LON00", "LON01", "LON02", "MEX00", "MIA00", "MIN00", "MIN01", "MIN98", "NAS00","NOR00", "NYC01", "OAK00", "PHI00", "PHO00", "PIT00", "SDG00", "SEA00", "SFO00", "SFO01", "STL00", "TAM00", "VEG00", "WAS00")
yardsum(team = "ARI", stadium = "ATL00")

totalcells = 0
for (team in teams) {
  for (stadium in stadiums) {
    totalcells = totalcells + 1
  }
}
pb1 <- progress_bar$new(total = totalcells, format = "[:bar]:percent Overall Progress")
for (team in teams) {
  yardage = c()
  for (stadium in stadiums) {
    pb1$tick()
    append(yardage, yardsum(team = team, stadium = stadium))
  }
  append(team, yardage, after = 0)
  newdf <- data.frame(t(yardage))
  blocked <- rbind(blocked, newdf)
}

# EDA

# Friedman Procedure
## Distribution-Free Test for General Alternatives in a Randomized Block Design
## Response: Distance (*_yards)
## Blocks: Game (game_id)
## Treatments: Stadiums (stadium_id)
nfl$stadium_id <- factor(nfl$stadium_id)
nfl$game_id <- factor(nfl$game_id)
friedman.test(nfl$yards, nfl$stadium_id, nfl$game_id)

# Durbin-Skillings-Mack Procedure
## Distribution-Free Test for General Alternatives in a Randomized Balanced Incomplete Block Design
## Response: Distance (*_yards)
## Blocks: Game (game_id)
## Treatments Stadiums (stadium_id)
pDurSkiMa(nfl$yards, b = nfl$game_id, trt = nfl$stadium_id, method = "Monte Carlo", n.mc = 10000)
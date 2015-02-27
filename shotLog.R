library(httr)

shotStats <- function(last_comma_first, from="", to="", gameSegment="", nGames=0, location="",month=0, teamID=0, outcome="",
         period=0, season="", seasonSegment="", seasonType="Regular+Season",
         teamID=0, vsConference="", vsDvision="") {
        playerID <- player.table[]
        shots.url <- paste0("http://stats.nba.com/stats/playerdashptshotlog?DateFrom=", from,
                            "&DateTo=", to, 
                            "&GameSegment=", gameSegment,
                            "&LastNGames=",nGames, 
                            "&LeagueID=00",
                            "&Location=", location,
                            "&Month=", month,
                            "&OpponentTeamID=", teamID, 
                            "&Outcome=", outcome="",
                            "&Period=", period,
                            "&PlayerID=", playerID,
                            "&Season=", season,
                            "&SeasonSegment=", seasonSegment,
                            "&SeasonType=", seasonType,
                            "&TeamID=", teamID,
                            "&VsConference=", vsConference,
                            "&VsDivision=", vsDivision)
        
        
}

# request the URL and parse the JSON
request <- GET(shots.url)

status_code(request)
headers(request)
str(content(request))
head(content(request))

library(jsonlite)
content <- content(request, "text")
john.wall <- fromJSON(content)
lapply(john.wall, dim)

john.wallShots <- data.frame(john.wall$resultSets[[3]])
names(john.wallShots) <- john.wall$resultSets[[2]][[1]]
str(john.wallShots)


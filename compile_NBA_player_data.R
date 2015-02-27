library(rvest)
library(rjson)
library(beepr)
library(httr)
library(dplyr)
library(data.table)

options (mc.cores = 1)
options(java.parameters = "-Xmx8192M")

# getting basic info with the John Wall example used in Greg Reda's post
# http://www.gregreda.com/2015/02/15/web-scraping-finding-the-api/
player_info <- html(paste0(
        "http://stats.nba.com/stats/commonplayerinfo?LeagueID=00&PlayerID=",
        202322,
        "&SeasonType=Regular+Season"))

# html_tag(player_info)

player_json <- fromJSON(html_text(player_info))
cols <- player_json$resultSets[[1]]$headers # taking the column names from the initial API test call
player_df <- data.frame(matrix(NA, nrow=1, ncol=25)) # empty dataframe
names(player_df) <- tolower(cols)

# through some digging, I found the list of players to start with the ID 891. As for the end, I looked at
# NBA rookies and found them to be in the low 200Ks. I'm sure there's a better way to do this, but....
start.time <- Sys.time()
for (i in 216601:220000) {
        url <- paste0(
                "http://stats.nba.com/stats/commonplayerinfo?LeagueID=00&PlayerID=",
                i,
                "&SeasonType=Regular+Season")
        
        player_info <- try(html(url), silent=TRUE)
        if (!("try-error" %in% class(player_info))) {
                player_json <- fromJSON(html_text(player_info))
                # the API returns 25 different columns
                for (x in 1:25) {
                        if (!is.null(player_json$resultSets[[1]][[3]][[1]][[x]])) {
                                player_df[i,x] <- player_json$resultSets[[1]][[3]][[1]][[x]] 
                        }
                }
        }
        if (i %% 7 == 0) handle_reset(url)
}
end.time <- Sys.time()
beep(7) 
end.time - start.time

write.csv(player_df, "./data/nba_players.csv", row.names=FALSE)
write.csv(player_df, "player_df.Rda")

load("player_df.Rda")
player_file <- read.csv("./data/nba_players.csv")
player_df <- player_file
rm(player_file)
player_df <- filter(player_df, !(is.na(first_name)))
player.table <- data.table(player_df)        
player.table[display_last_comma_first == "Wall, John", person_id]

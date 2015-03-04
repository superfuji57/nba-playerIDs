library(rvest)
library(rjson)
library(beepr)
library(httr)
library(dplyr)
library(data.table)

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

# NBA rookies seem to be in the low 200Ks. I'm sure there's a better way to do this, but....
start.time <- Sys.time()
for (i in 1:300000) {
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

player_df <- filter(player_df, !(is.na(first_name)))
player.table <- data.table(player_df)
save(player.table, file="./data/player.table.Rda")
write.csv(player.table, "./data/player.table.csv", row.names=FALSE)

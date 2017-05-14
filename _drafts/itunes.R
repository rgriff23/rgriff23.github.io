################
# PREPARATIONS #
################

# 1. import and process an XML file
# 2. word clouds for your artists, genres, and lyrics
# 3. sentiment analysis of lyrics

# load packages
library("XML")
library("plyr")
library("wordcloud")

# http://dataislife.blogspot.com/2014/11/how-to-import-your-itunes-library-into-r.html
# read data (takes maybe 20-30 seconds)
ituneslib <- readKeyValueDB("~/Desktop/Library.xml")

# get song data (Name, Artist, Album, Genre, Year, Date.Added, Play.Count)
songs <- ldply(lapply(ituneslib$Tracks, data.frame,stringsAsFactors=FALSE))

# decide which genre and columns to keep
keep.genre <- c("Soundtrack","Rock","Alternative","Holiday","Pop","Metal","Dance","Country","Electronic","Industrial","Singer/Songwriter","Hip-Hop/Rap","Hip Hop/Rap","Classical","Classical Crossover","World","Easy Listening","Folk","R&B/Soul","Reggae","Traditional Folk","Punk Rock","Oldies","Christian & Gospel","K-Pop","Pop/Rock","Bluegrass","Indie","Jazz","Vocal","Children's Music","Adult Alternative")
keep.cols <- c("Name","Artist","Album","Genre","Total.Time","Date.Added","Play.Count")
songs[songs$Genre %in% "Adult Alternative", c("Name","Artist")] # 'No Rain' by Blind Melon
songs <- songs[songs$Genre %in% keep.genre, keep.cols]

# combine similar genre
songs[songs$Genre=="Hip Hop/Rap","Genre"] <- "Hip-Hop/Rap"
songs[songs$Genre=="Adult Alternative","Genre"] <- "Alternative"
songs[songs$Genre=="Traditional Folk","Genre"] <- "Folk"
songs[songs$Genre=="Classical Crossover","Genre"] <- "Classical"
songs[songs$Genre=="Christian & Gospel","Genre"] <- "Holiday"

####################
# LIBRARY ANALYSIS #
####################

# load packages

#-play count: distribution and top 20
songs$Play.Count <- ifelse(is.na(songs$Play.Count), 0, songs$Play.Count)
hist(songs$Play.Count[songs$Play.Count<11], breaks=11, main="Histogram of play counts < 8", xlab="Play count")
songs[sort.int(songs$Play.Count, index.return=T, decreasing=T)$ix,][1:20,c("Play.Count","Name","Genre")]

#-genera distribution (unweighted and weighted)
genre <- table(songs$Genre)
genre.w <- table(rep(songs$Genre, times=songs$Play.Count))
sort(genre, decreasing = TRUE)[1:10]
sort(genre.w, decreasing = TRUE)[1:10]
wordcloud(names(genre), genre, random.order=FALSE, colors=rainbow(5))
wordcloud(names(genre.w), genre.w, random.order=FALSE, colors=rainbow(5))

#-artist word cloud (unweighted and weighted)
artist <- table(songs$Artist)
artist.w <- table(rep(songs$Artist, times=songs$Play.Count))
wordcloud(names(artist), artist, random.order=FALSE, colors=rainbow(5))
wordcloud(names(artist.w), artist.w, random.order=FALSE, colors=rainbow(5))

#-genera vs date added (unweighted and weighted)

#-top song plays vs date added (unweighted and weighted)

###################
# LYRICS ANALYSIS #
###################

#-import lyrics from song database(s)
# https://www.musixmatch.com/ 

#-lyric word cloud

#-lyric sentiment analysis

#-lyric sentiment analysis over time (unweighted and weighted)

#######
# END #
#######
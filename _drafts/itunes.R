# load packages
library("XML")
library("plyr")
library("wordcloud")

# http://dataislife.blogspot.com/2014/11/how-to-import-your-itunes-library-into-r.html
# read data
ituneslib <- readKeyValueDB("~/Desktop/Library.xml")

# get song data (Name, Artist, Album, Genre, Year, Date.Added, Play.Count)
songs <- ldply(lapply(ituneslib$Tracks, data.frame))

# clean data

#-play count: distribution and top 20
songs$Play.Count <- ifelse(is.na(songs$Play.Count), 0, songs$Play.Count)
hist(songs$Play.Count[songs$Play.Count<8], breaks=8, main="Histogram of play counts < 8", xlab="Play count")
songs[sort.int(songs$Play.Count, index.return=T, decreasing=T)$ix,][1:20,c("Play.Count","Name","Genre")]

#-genera distribution (unweighted and weighted)
genre <- table(songs$Genre)
genre.w <- table(rep(songs$Genre, times=songs$Play.Count))
sort(genre, decreasing = TRUE)[1:10]
sort(genre.w, decreasing = TRUE)[1:10]

#-artist word cloud (unweighted and weighted)
artist <- table(songs$Artist)
artist.w <- table(rep(songs$Artist, times=songs$Play.Count))
wordcloud(names(artist), artist, random.order=FALSE, colors=rainbow(5))
wordcloud(names(artist.w), artist.w, random.order=FALSE, colors=rainbow(5))

#-genera vs date added (unweighted and weighted)

#-import lyrics from song database(s)
#-lyric word cloud (unweighted and weighted)
#-lyric sentiment analysis (unweighted and weighted)
#-lyric sentiment analysis over time (unweighted and weighted)


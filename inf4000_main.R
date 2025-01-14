## Libraries
library(tidyverse)
library(gridExtra)
library(GGally)
library(rgl)
library(tidymodels)
library(ggradar)
library(scales)

## Load in data set
tracks<-read_csv("dataset.csv")

## Data Cleaning

# remove rows where the artist and track_name are the same
#make column concatenating artist and track_name
tracks$art_tra_name<-paste(tracks$artists,tracks$track_name)
#sort by popularity (to try to avoid deleting the original version)
tracks<-arrange(tracks,-popularity)
#check for duplicates in this column
tracks<-tracks[!duplicated(tracks$art_tra_name),]
#remove the first and last columns (0 indexed one and one just made)
tracks <- subset(tracks, select=c('track_id','artists','album_name','track_name',
                                  'popularity','duration_ms','explicit','danceability',
                                  'energy','key','loudness','mode','speechiness',
                                  'acousticness','instrumentalness','liveness',
                                  'valence','tempo','time_signature','track_genre'))

# isolate the genres of interest
heavy_metal<-tracks[grep("heavy-metal",tracks$track_genre),]
jazz<-tracks[grep("jazz",tracks$track_genre),]
hip_hop<-tracks[grep("hip-hop",tracks$track_genre),]
comedy<-tracks[grep("comedy",tracks$track_genre),]

# make a data frame with only the genres of interest
new_list<-rbind(heavy_metal, jazz, hip_hop, comedy)

# define the colours that will be used in the graphics
graph_cols<-c("#D0B066A0","#048BA8A0","#16DB93A0","#A4036FA0")

# run PCA on the genres
pca<- prcomp(new_list[,c(8,9,10,11,13,14,15,16,17,18)], scale=TRUE)
new.pca<-data.frame(
  track_name=new_list$track_name,
  genre=new_list$track_genre,
  PC1=pca$x[,1],
  PC2=pca$x[,2]
)

# PCA plot
ggplot(new.pca, aes(PC1, PC2)) +
  geom_point(aes(colour=genre, shape=genre, size=4)) +
  theme_light() +
  theme(text = element_text(size = 32,family = "serif")) +
  scale_colour_manual(values=graph_cols) +
  scale_shape_manual(values=c(15,16,17,18)) +
  labs(title="PCA of Selected Genres", colour="Genre", shape="Genre",
       caption="Spotify dataset", tag="1") +
  guides(size="none")

# get values for clustered bar
specie<-c(rep("danceability",4), rep("energy",4), rep("speechiness", 4), rep("acousticness", 4),
          rep("instrumentalness", 4), rep("valence", 4))
condition<-rep(c("comedy","heavy-metal","hip-hop","jazz"), 6)
value<-c(mean(comedy$danceability), mean(heavy_metal$danceability), mean(hip_hop$danceability), mean(jazz$danceability),
         mean(comedy$energy), mean(heavy_metal$energy), mean(hip_hop$energy), mean(jazz$energy),
         mean(comedy$speechiness), mean(heavy_metal$speechiness), mean(hip_hop$speechiness), mean(jazz$speechiness),
         mean(comedy$acousticness), mean(heavy_metal$acousticness), mean(hip_hop$acousticness), mean(jazz$acousticness),
         mean(comedy$instrumentalness), mean(heavy_metal$instrumentalness), mean(hip_hop$instrumentalness), mean(jazz$instrumentalness),
         mean(comedy$valence), mean(heavy_metal$valence), mean(hip_hop$valence), mean(jazz$valence))
avgs<-data.frame(specie,condition,value)

# plot clustered bar
ggplot(avgs, aes(fill=condition, y=value, x=specie)) +
  geom_bar(position = "dodge", stat = "identity") +
  theme_light() +
  scale_fill_manual(values=graph_cols) +
  theme(text = element_text(size=32,family="serif"),
        axis.text.x = element_text(size=32,angle=45, hjust=1)) +
  labs(title="Mean of Musical Components of Selected Genres",
       x="Musical Component", y="Mean", fill="Genre",
       caption="Spotify dataset", tag="2")

# plot scatter
ggplot(new_list, aes(valence, danceability)) +
  geom_point(size=4, aes(colour=track_genre, shape=track_genre)) +
  geom_smooth(method="lm", se=FALSE, colour="black") +
  theme_light() +
  theme(text=element_text(size=32,family="serif")) +
  scale_colour_manual(values=graph_cols) +
  scale_shape_manual(values=c(15,16,17,18)) +
  labs(x="Valence", y="Danceability", colour="Genre", shape="Genre",
       title="Danceability vs Valence for Selected Genres",
       caption="Spotify dataset", tag="3")

# plot violins
v1<-ggplot(new_list, aes(x=track_genre, y=danceability, fill=track_genre)) +
  geom_violin() +
  theme_light() +
  theme(text=element_text(size=32,family="serif")) +
  scale_fill_manual(values=graph_cols) +
  labs(title="Violin Plot of Danceability by Genre",
       x="Genre", y="Danceability", tag="4", caption="")+
  guides(fill="none")

v2<-ggplot(new_list, aes(x=track_genre, y=valence, fill=track_genre)) +
  geom_violin() +
  theme_light() +
  theme(text=element_text(size=32,family="serif")) +
  scale_fill_manual(values=graph_cols) +
  labs(title="Violin Plot of Valence by Genre",
       x="Genre", y="Valence", fill="Genre", caption="Spotify dataset", tag="")

grid.arrange(v1,v2,ncol=2)

# plot spider
n_new_list<-new_list
n_new_list$popularity<-NULL
n_new_list$duration_ms<-NULL
n_new_list$key<-NULL
n_new_list$loudness<-NULL
n_new_list$mode<-NULL
n_new_list$liveness<-NULL
n_new_list$tempo<-NULL
n_new_list$time_signature<-NULL

n_new_list %>%
  mutate_if(is.numeric, rescale) %>%
  group_by(track_genre) %>%
  summarise_if(is.numeric, mean) %>%
  ggradar(axis.label.size=12, legend.text.size=32)

# plot pie
group<-c("comedy", "heavy-metal", "hip-hop", "jazz")
dance_values<-c(mean(comedy$danceability), mean(heavy_metal$danceability), mean(hip_hop$danceability), mean(jazz$danceability))
pi_data<-data.frame(group,dance_values)

ggplot(pi_data, aes(x="",y=dance_values,fill=group)) +
  geom_bar(stat="identity", width=1) +
  coord_polar(theta="y") +
  theme(axis.line = element_blank(), panel.background = element_blank()) +
  theme(axis.text = element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(text=element_text(size=32), legend.text = element_text(size=32)) +
  labs(x=NULL, y=NULL, fill="Genre",
       title="Danceability proportion of songs by genre")

# plot parallel coords
ggparcoord(new_list, columns=c(14,8,9,15,13,17),
           groupColumn=20) +
  theme(axis.text.x=element_text(angle=45),
        panel.background=element_blank(),
        text=element_text(size=32)) +
  geom_vline(xintercept=c(1,2,3,4,5,6,7)) +
  labs(colour="Genre", x="Musical Component", y="Scaled Values",
       title="Parallel Coords of Selected Genres")








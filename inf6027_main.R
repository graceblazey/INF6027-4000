## Libraries
library(tidyverse)
library(gridExtra)
library(GGally)
library(rgl)
library(tidymodels)
library(ggradar)
library(scales)
library(ggalluvial)

## Load in data set
tracks<-read_csv("dataset.csv")

## Data Cleaning

# remove rows where the artist and track_name are the same
# make column concatenating artist and track_name
tracks$art_tra_name<-paste(tracks$artists,tracks$track_name)
# sort by popularity (to try to avoid deleting the original version)
tracks<-arrange(tracks,-popularity)
# check for duplicates in this column
tracks<-tracks[!duplicated(tracks$art_tra_name),]
# remove the first and last columns (0 indexed one and one just made)
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

## Exploratory Data Analysis

# run PCA on the genres
pca<- prcomp(new_list[,c(8,9,10,11,13,14,15,16,17,18)], scale=TRUE)
new.pca<-data.frame(
  track_name=new_list$track_name,
  genre=new_list$track_genre,
  PC1=pca$x[,1], # take the first
  PC2=pca$x[,2] # and second PCs
)

# define the colours that will be used in the graphics
graph_cols<-c("#D0B066A0","#048BA8A0","#16DB93A0","#A4036FA0")

# plot the first two PCs 
ggplot(new.pca, aes(PC1, PC2)) +
  geom_point(aes(colour=genre, shape=genre, size=4)) + # separate genres by colour
  theme_light() +
  theme(text = element_text(size = 16,family = "serif")) +
  scale_colour_manual(values=graph_cols) +
  scale_shape_manual(values=c(15,16,17,18)) +
  labs(title="PCA of Selected Genres", colour="Genre", shape="Genre",
       caption="Spotify dataset", tag="1") +
  guides(size="none")

# look at correlation between popularity and other factors in one variable
cor.test(comedy$popularity, comedy$acousticness)$estimate

# plot the relationship
ggplot(comedy, aes(popularity, acousticness)) +
  geom_point(colour=rgb(1,0,0,0.75)) + 
  geom_smooth(method="lm", se=FALSE) + # add line of best fit
  theme_light() +
  theme(text=element_text(size=32, family="serif")) +
  labs(title="Popularity vs Acousticness for Comedy Genre",
       x="Popularity", y="Acousticness", caption="Spotify dataset")



## logistic regression for classification of genre

# make genre a factor
new_list$track_genre<-as.factor(new_list$track_genre)

# split into training and test data
new_list<-arrange(new_list,track_id)

set.seed(421)
split<-initial_split(new_list, prop=0.70, strata=track_genre) # split within genre
train<- split %>% training()
test<- split %>% testing()

# fit the model
model<-multinom_reg(mode="classification", engine="nnet") %>%
  fit(track_genre ~ danceability+energy+key+loudness+speechiness+acousticness+
        instrumentalness+liveness+valence+tempo, data=train)

# run the model
tidy(model)

# separate the prediction and probability associated with the prediction
pred_class<-predict(model, new_data=test, type="class")
pred_proba<-predict(model, new_data=test, type="prob")

# assess the model
results<-test %>% select(track_genre) %>% bind_cols(pred_class, pred_proba)
accuracy(results, truth=track_genre, estimate=.pred_class)

# Sankey diagram of true -> predicted genre
results %>% group_by(track_genre, .pred_class) %>% summarise(count=n()) %>%
  ggplot(aes(y=count, axis1=track_genre, axis2=.pred_class)) +
  geom_alluvium(aes(fill=track_genre)) +
  geom_stratum() +
  geom_label(stat="stratum", aes(label=after_stat(stratum))) +
  scale_x_discrete(limits=c("True Genre", "Predicted Genre")) +
  theme(panel.background=element_blank(), axis.line.y=element_blank(),
        axis.text.y=element_blank(), axis.ticks=element_blank()) +
  labs(x="", y="") +
  guides(fill="none")


## multiple linear regression for predicting pop

# randomise order of each genre df
comedy<-comedy[sample(1:nrow(comedy)),]
heavy_metal<-heavy_metal[sample(1:nrow(heavy_metal)),]
hip_hop<-hip_hop[sample(1:nrow(hip_hop)),]
jazz<-jazz[sample(1:nrow(jazz)),]

# comedy model
# split into train and test
com_tr<-comedy[1:ceiling(nrow(comedy)*0.7),]
com_te<-comedy[((ceiling(nrow(comedy)*0.7))+1):nrow(comedy),]
# build model
com_pop_mod<-lm(formula=popularity~danceability+energy+key+loudness+speechiness+
                  acousticness+instrumentalness+liveness+valence+tempo,
                data=com_tr)
# get predictions and residuals for train
com_resid<-com_tr
com_resid$predicted<-predict(com_pop_mod)
com_resid$residuals<-residuals(com_pop_mod)
# plot predictions and residuals
plot(com_pop_mod, which=1)
# use test data to make predictions
predict(com_pop_mod, newdata=com_te, interval="confidence")
com_pop_test<-com_te
# get predictions and residuals for test
com_pop_test$predicted<-predict(com_pop_mod, newdata=com_te)
com_pop_test$residuals<-com_pop_test$predicted - com_pop_test$popularity
# get sum of squares error (sse)
sse_com<-sum(com_pop_test$residuals**2)

# heavy-metal model
# split into train and test
hm_tr<-heavy_metal[1:ceiling(nrow(heavy_metal)*0.7),]
hm_te<-heavy_metal[((ceiling(nrow(heavy_metal)*0.7))+1):nrow(heavy_metal),]
# build model
hm_pop_mod<-lm(formula=popularity~danceability+energy+key+loudness+speechiness+
                 acousticness+instrumentalness+liveness+valence+tempo,
               data=hm_tr)
# get predictions and residuals for train
hm_resid<-hm_tr
hm_resid$predicted<-predict(hm_pop_mod)
hm_resid$residuals<-residuals(hm_pop_mod)
# plot predictions and residuals
plot(hm_pop_mod, which=1)
# use test data to make predictions
predict(hm_pop_mod, newdata=hm_te, interval="confidence")
hm_pop_test<-hm_te
# get predictions and residuals for test
hm_pop_test$predicted<-predict(hm_pop_mod, newdata=hm_te)
hm_pop_test$residuals<-hm_pop_test$predicted - hm_pop_test$popularity
# get sse
sse_hm<-sum(hm_pop_test$residuals**2)

# hip-hop model
# split into train and test
hh_tr<-hip_hop[1:ceiling(nrow(hip_hop)*0.7),]
hh_te<-hip_hop[((ceiling(nrow(hip_hop)*0.7))+1):nrow(hip_hop),]
# build model
hh_pop_mod<-lm(formula=popularity~danceability+energy+key+loudness+speechiness+
                 acousticness+instrumentalness+liveness+valence+tempo,
               data=hh_tr)
# get predictions and residuals for train
hh_resid<-hh_tr
hh_resid$predicted<-predict(hh_pop_mod)
hh_resid$residuals<-residuals(hh_pop_mod)
# plot predictions and residuals
plot(hh_pop_mod, which=1)
# use test data to make predictions
predict(hh_pop_mod, newdata=hh_te, interval="confidence")
hh_pop_test<-hh_te
# get predictions and residuals for test
hh_pop_test$predicted<-predict(hh_pop_mod, newdata=hh_te)
hh_pop_test$residuals<-hh_pop_test$predicted - hh_pop_test$popularity
# get sse
sse_hh<-sum(hh_pop_test$residuals**2)

# jazz model
# split into train and test
jaz_tr<-jazz[1:ceiling(nrow(jazz)*0.7),]
jaz_te<-jazz[((ceiling(nrow(jazz)*0.7))+1):nrow(jazz),]
# build model
jaz_pop_mod<-lm(formula=popularity~danceability+energy+key+loudness+speechiness+
                  acousticness+instrumentalness+liveness+valence+tempo,
                data=jaz_tr)
# get predictions and residuals for train
jaz_resid<-jaz_tr
jaz_resid$predicted<-predict(jaz_pop_mod)
jaz_resid$residuals<-residuals(jaz_pop_mod)
# plot predictions and residuals
plot(jaz_pop_mod, which=1)
# use test data to make predictions
predict(jaz_pop_mod, newdata=jaz_te, interval="confidence")
jaz_pop_test<-jaz_te
# get predictions and residuals for test
jaz_pop_test$predicted<-predict(jaz_pop_mod, newdata=jaz_te)
jaz_pop_test$residuals<-jaz_pop_test$predicted - jaz_pop_test$popularity
# get sse
sse_jaz<-sum(jaz_pop_test$residuals**2)




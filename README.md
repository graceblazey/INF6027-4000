## README for INF6027_main and INF4000_main

Repository for files related to INF6027 (Intro to Data Science) and INF4000 (Data Visualisation) assessments.
This file contains details of the dataset and instructions for running the code.

## Column Descriptions (from dataset files)

- **track_id**: The Spotify ID for the track
- **artists**: The artists' names who performed the track. If there is more than one artist, they are separated by a `;`
- **album_name**: The album name in which the track appears
- **track_name**: Name of the track
- **popularity**: The popularity of a track is a value between 0 and 100, with 100 being the most popular. The popularity is calculated by algorithm and is based, in the most part, on the total number of plays the track has had and how recent those plays are. Generally speaking, songs that are being played a lot now will have a higher popularity than songs that were played a lot in the past. Duplicate tracks (e.g. the same track from a single and an album) are rated independently. Artist and album popularity is derived mathematically from track popularity.
- **duration_ms**: The track length in milliseconds
- **explicit**: Whether or not the track has explicit lyrics (true = yes it does; false = no it does not OR unknown)
- **danceability**: Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable
- **energy**: Energy is a measure from 0.0 to 1.0 and represents a perceptual measure of intensity and activity. Typically, energetic tracks feel fast, loud, and noisy. For example, death metal has high energy, while a Bach prelude scores low on the scale
- **key**: The key the track is in. Integers map to pitches using standard Pitch Class notation. E.g. `0 = C`, `1 = C♯/D♭`, `2 = D`, and so on. If no key was detected, the value is -1
- **loudness**: The overall loudness of a track in decibels (dB)
- **mode**: Mode indicates the modality (major or minor) of a track, the type of scale from which its melodic content is derived. Major is represented by 1 and minor is 0
- **speechiness**: Speechiness detects the presence of spoken words in a track. The more exclusively speech-like the recording (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value. Values above 0.66 describe tracks that are probably made entirely of spoken words. Values between 0.33 and 0.66 describe tracks that may contain both music and speech, either in sections or layered, including such cases as rap music. Values below 0.33 most likely represent music and other non-speech-like tracks
- **acousticness**: A confidence measure from 0.0 to 1.0 of whether the track is acoustic. 1.0 represents high confidence the track is acoustic
- **instrumentalness**: Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are treated as instrumental in this context. Rap or spoken word tracks are clearly "vocal". The closer the instrumentalness value is to 1.0, the greater likelihood the track contains no vocal content
- **liveness**: Detects the presence of an audience in the recording. Higher liveness values represent an increased probability that the track was performed live. A value above 0.8 provides strong likelihood that the track is live
- **valence**: A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry)
- **tempo**: The overall estimated tempo of a track in beats per minute (BPM). In musical terminology, tempo is the speed or pace of a given piece and derives directly from the average beat duration
- **time_signature**: An estimated time signature. The time signature (meter) is a notational convention to specify how many beats are in each bar (or measure). The time signature ranges from 3 to 7 indicating time signatures of `3/4`, to `7/4`.
- **track_genre**: The genre in which the track belongs

## Instructions for running INF6027_main

The code can be run in the order it is written to gain the results described in INF6027 Assessment Section 3.1 Results. More specifically: 

1. Install required packages to load libraries (all listed at the top of the code). The same libraries are listed in INF6027_main and INF4000_main for ease of installing all packages.
2. Ensure `dataset.csv` is in the working directory and load in the data.
3. Clean the data using the steps in lines 14-28.
4. Separate the genres to be used. Other genres can be used if care is taken to replace every instance of the old genre in the code.
5.Exploratory data analysis, lines 39-74 produces PCA graph and brief observation of popularity correlation with another variable.
6. Multinomial logistic regression on lines 78-117. Sankey diagram can be produced on lines 96-106
7. Multiple linear regression on lines 120-218, each genre is modeled in turn and graphics are produced during modelling.

## Instructions for running INF4000_main

The code can be run in order, or individual visualisations produced independently.

1. Install required packages to load libraries (all listed at the top of the code). The same libraries are listed in INF6027_main and INF4000_main for ease of installing all packages.
2. Ensure `dataset.csv` is in the working directory and load in the data.
3. Clean the data using the steps in lines 13-27.
4. Separate the genres to be used. Other genres can be used if care is taken to replace every instance of the old genre in the code.
5. Visualisation 1, PCA: lines 41-59
6. Visualisation 2, Clustered Bar: lines 61-82
7. Visualisation 3, Scatter: lines 84-94
8. Visualisation 4, Violins: lines 96-114
9. Additional visualisations: Spider (116-131), Pie (133-146), Parallel Coordinates (148-157)
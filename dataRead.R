rm(list=ls())
library(dplyr)
library(stringr)
# Don't install again
#{if (!requireNamespace("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install(version = "3.14")
#BiocManager::install("rhdf5")}

library(rhdf5)
setwd(dirname(getActiveDocumentContext()$path)) 
getwd()

# Read from all three layers of folders
layer1_path = "/MillionSongSubset"

# Let us first read everything from A

# Read all folder paths for the A> folder
layer2_vec = str_to_upper(letters)
path = vector(mode = "list", length = length(layer2_vec)*length(layer2_vec))
k = 0
# First generate all paths
for(i in 1:26){
  # Use same letter string for A folder
  for(j in 1:26)
  {  k = k + 1
  path[[k]] = paste0("/Users/sahilakudalkar/Library/CloudStorage/OneDrive-TheUniversityofChicago/Documents/Winter 2023/Machine Learning/Final Project/MillionSongSubset/A/", layer2_vec[i], "/", layer2_vec[j])
  }
}

songs = data.frame()
songs_meta = data.frame()
songs_full = list()
songs_data = list()

# Read for all 26*26 entries
for(i in 1:676){
  filenames <- list.files(path[[i]], pattern="*.h5", full.names=TRUE)
  for(j in 1:length(filenames)){
    
    # Open file
    df <- H5Fopen(name = filenames[j])
    
    # Read useful information
    songs = df$analysis[[14]]
    songs_meta <- df$metadata[[5]]
    # Constructing one row from the data
    songs_full[[j]] <- data.frame(cbind(songs_meta, songs, id = j))
    # Close the connection
    #H5Dclose(h5d)
  }
  # This creates an excessively long dataframe by mis-reading parts: Restrict to the top j instances
  songs_data[[i]] = purrr:::reduce(songs_full, rbind.data.frame)[1:j,] 
}

# Now convert the list songs_data as a dataframe
songs_dataA = as.data.frame(do.call(cbind, songs_data))


### Repeat for B
# Read all folder paths for the A> folder
layer1_vecB = LETTERS(A:I)
layer2_vecB = LETTERS
pathB = vector(mode = "list", length = length(layer1_vecB)*length(layer2_vecB))
k = 0
# First generate all paths
for(i in 1:26){
  # Use same letter string for A folder
  for(j in 1:26)
  {  k = k + 1
  pathB[[k]] = paste0("/Users/sahilakudalkar/Library/CloudStorage/OneDrive-TheUniversityofChicago/Documents/Winter 2023/Machine Learning/Final Project/MillionSongSubset/B/", layer1_vecB[i], "/", layer2_vecB[j])
  }
}

songs = data.frame()
songs_meta = data.frame()
songs_full = list()
songs_data = list()

# Read for all 9*26 entries
for(i in 1:234){
  filenames <- list.files(path[[i]], pattern="*.h5", full.names=TRUE)
  for(j in 1:length(filenames)){
    
    # Open file
    df <- H5Fopen(name = filenames[j])
    
    # Read useful information
    songs = df$analysis[[14]]
    songs_meta <- df$metadata[[5]]
    # Constructing one row from the data
    songs_full[[j]] <- data.frame(cbind(songs_meta, songs, id = j))
    # Close the connection
    #H5Dclose(h5d)
  }
  # This creates an excessively long dataframe by mis-reading parts: Restrict to the top j instances
  songs_data[[i]] = purrr:::reduce(songs_full, rbind.data.frame)[1:j,] 
}

# Now convert the list songs_data as a dataframe
songs_dataB = as.data.frame(do.call(cbind, songs_data))

### Then join the two data sources
songs_million = songs_dataA%>%
  full_join(songs_dataB)
write.csv(songs_million, "million_songs.csv")

# Downloaded from https://www.kaggle.com/datasets/dhruvildave/billboard-the-hot-100-songs
songs_billboard <- read.csv("charts.csv", header = T)


# We merge data on artist_name, title and year: This will be slow
songs <- songs_billboard%>%
  full_join(songs_million)%>%
  # Have a filter condition to reduce memory usage
  filter()

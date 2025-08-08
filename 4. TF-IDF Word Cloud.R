# Install necessary packages (uncomment and run these lines if you haven't already)
# install.packages(c("tm", "wordcloud", "RColorBrewer", "text2vec", "here"))
library(tm)          # For text mining functionalities (e.g., Corpus, DTM)
library(wordcloud)   # For generating word cloud visualizations
library(RColorBrewer)# For color palettes in visualizations
library(text2vec)    # For efficient TF-IDF calculation and text vectorization
library(here)        # For setting relative paths easily

# --- 1. Path and Seed Configuration ---
# Define the base directory where your preprocessed text files are located.
path_to_text_files <- here("data", "txt3")
# Define the full path where the generated word cloud image will be saved.
output_path <- here("Wordcloud_All.png")

# Set a seed for reproducibility of the word cloud layout.
SEED <- 42
set.seed(SEED)

# --- 2. Custom Stopwords Definition ---
# Initialize the standard English stopwords list.
stop_words <- stopwords("en")
# Extend the standard stopwords with domain-specific or general irrelevant terms.
custom_stopwords <- c(stop_words, 'al', 'wiley')

# --- 3. Text Preprocessing Function ---
# This function applies a series of text cleaning steps to a given text string.
preprocess_text <- function(text) {
  text <- tolower(text)             # Convert all text to lowercase.
  text <- removePunctuation(text)   # Remove all punctuation marks.
  text <- removeNumbers(text)       # Remove all numerical digits.
  text <- removeWords(text, custom_stopwords) # Remove defined custom stopwords.
  text <- stripWhitespace(text)     # Remove extra whitespace.
  return(text)
}

# Load and preprocess all text files from the specified base directory.
# 'sapply' is used to apply the 'preprocess_text' function to each file's content.
files <- list.files(path_to_text_files, pattern = "\\.txt$", full.names = TRUE)

# If no files are found, stop with an error.
if (length(files) == 0) {
  stop("Error: No text files found in the specified directory.")
}

documents <- sapply(files, function(file) {
  raw_text <- readLines(file, warn = FALSE, encoding = "UTF-8")
  # Collapse lines into a single string before preprocessing.
  preprocess_text(paste(raw_text, collapse = " "))
})

# --- 4. TF-IDF Calculation ---
# Create an 'itoken' iterator for efficient text processing.
it <- itoken(documents, progressbar = FALSE)
# Create a vocabulary from the processed documents.
vocab <- create_vocabulary(it)
# Create a vectorizer based on the vocabulary.
vectorizer <- vocab_vectorizer(vocab)
# Create a Document-Term Matrix (DTM) from the documents and vectorizer.
dtm <- create_dtm(it, vectorizer)

# Initialize a TF-IDF transformer.
tfidf <- TfIdf$new()
# Fit the TF-IDF model to the DTM and transform it into a TF-IDF matrix.
tfidf_matrix <- tfidf$fit_transform(dtm)
# Calculate the mean TF-IDF score for each word across all documents.
word_scores <- colMeans(as.matrix(tfidf_matrix))

# Extract the top 100 words based on their TF-IDF scores.
top_words <- sort(word_scores, decreasing = TRUE)[1:100]

# --- 5. Word Cloud Visualization ---
# Define a color palette for the word cloud.
pal <- brewer.pal(8, "Dark2")

# Generate the word cloud to display in the R graphics device (e.g., RStudio Plot pane).
# This code is for immediate visualization in the console.
wordcloud(words = names(top_words),    # Words to display
          freq = top_words,            # Frequencies (TF-IDF scores in this case)
          scale = c(5, 0.5),           # Range of font sizes for words
          max.words = 100,             # Maximum number of words to display
          random.order = FALSE,        # Display words in order of decreasing frequency
          rot.per = 0,                 # Percentage of words displayed vertically
          colors = pal,                # Color palette for words
          random.color = FALSE,        # Use specified colors, not random ones
          use.r.layout = FALSE)        # Use R's layout algorithm

# --- 6. Saving the Word Cloud ---
# The code below is specifically for saving the plot as an image file.

# Open a PNG graphics device with high resolution (1000 dpi) to start a new plotting session.
png(output_path, width = 4000, height = 4000, res = 1000)

# Re-generate the word cloud within the opened PNG device.
# This ensures the word cloud is drawn onto the file, not just the console.
wordcloud(words = names(top_words),    # Words to display
          freq = top_words,            # Frequencies (TF-IDF scores in this case)
          scale = c(5, 0.5),           # Range of font sizes for words
          max.words = 100,             # Maximum number of words to display
          random.order = FALSE,        # Display words in order of decreasing frequency
          rot.per = 0,                 # Percentage of words displayed vertically
          colors = pal,                # Color palette for words
          random.color = FALSE,        # Use specified colors, not random ones
          use.r.layout = FALSE)        # Use R's layout algorithm

# Close the graphics device, saving the plot to the specified file.
dev.off()

# Print a confirmation message to the console.
cat(paste0("Save Complete: ", output_path, "\n"))

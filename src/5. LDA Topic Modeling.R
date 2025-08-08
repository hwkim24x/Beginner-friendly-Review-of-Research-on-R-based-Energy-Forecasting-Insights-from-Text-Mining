# Install necessary packages (uncomment and run if they are not already installed)
# install.packages(c("tm", "topicmodels", "textstem", "stopwords", "LDAvis","stringr", "readtext", "stringi", "textmineR", "Matrix", "here", "servr"))
library(tm)          # For text mining, corpus management, and DTM creation
library(topicmodels) # For performing the LDA modeling
library(textstem)    # For lemmatization
library(stopwords)   # For managing stopwords
library(stringr)     # For string manipulation
library(stringi)     # For advanced string operations
library(readtext)    # For reading text files from a directory
library(LDAvis)      # For interactive topic visualization
library(textmineR)   # For coherence score calculation
library(Matrix)      # For handling sparse matrices
library(here)        # For setting relative paths easily
library(servr)       # For serving the LDAvis visualization locally

# --- 1. Path and Seed Configuration ---
path_to_stopwords_file <- here("data", "stop_words_english.txt")
path_to_text_files <- here("data", "txt3")
output_dir_lda_vis <- here('lda_vis')
output_path_coherence_plot <- here("Coherence_Score.png")

# Set a seed for reproducibility of random processes, such as LDA model training.
SEED <- 3
set.seed(SEED)

# --- 2. Stopword Configuration ---
# Initialize the standard English stopwords list.
stop_words <- stopwords("en")
# Define a list of custom, domain-specific stopwords to be removed from the corpus.
# These words are often too common to be useful for topic discrimination.
custom_stopwords <- c(
  'fig', 'table', 'example', 'figure', 'energy', 'forecasting', 'prediction', 'performance', 'forecast', 'set',
  'model', 'data', 'energy', 'forecast', 'time', 'prediction', 'method', 'base', 'variable', 'set', 'study',
  'parameter', 'al', 'value', 'performance', 'input', 'series', 'approach', 'forecasting', 'predict', 'propose'
)
# Combine the standard and custom stopwords into a single list.
stop_words <- c(stop_words, custom_stopwords)

# Attempt to load additional custom stopwords from a file.
# The 'tryCatch' block ensures the script doesn't fail if the file is not found.
tryCatch({
  custom_stopwords_file <- scan(path_to_stopwords_file, what = "character", sep = "\n", fileEncoding = "UTF-8")
  stop_words <- c(stop_words, unlist(strsplit(custom_stopwords_file, "\\s+")))
}, error = function(e) {
  message("Error: Custom stopwords file not found at the specified path.")
})

# --- 3. Text Preprocessing ---
# This function applies a comprehensive set of cleaning steps to the text.
clean_text <- function(text) {
  text <- tolower(text)                                      # Convert to lowercase.
  text <- str_replace_all(text, "\\b\\d*\\.?\\d+[\\w/]*\\b", "") # Remove numbers and alphanumeric characters attached to them.
  text <- str_replace_all(text, "[\\u0370-\\u03FF\\u2200-\\u22FF]+", "") # Remove Greek letters and math symbols.
  text <- str_replace_all(text, "[·〠ð]|et al", "")          # Remove specific special characters.
  text <- str_replace_all(text, "a b s t r a c t", "abstract ")  # Normalize 'abstract'
  text <- str_replace_all(text, "a r t i c l e i n f o", "")     # Remove article info text.
  text <- str_squish(text)                                   # Remove extra spaces.
  text <- removeWords(text, stop_words)                      # Remove all defined stopwords.
  text <- removePunctuation(text)                            # Remove punctuation.
  text <- lemmatize_strings(text)                            # Lemmatize words to their base form.
  text <- stri_extract_all_words(text)                       # Tokenize into words.
  text <- lapply(text, function(x) x[nchar(x) > 1])           # Remove single-character words.
  
  return(sapply(text, paste, collapse=" "))
}

# Read all text files from the directory and handle potential errors.
tryCatch({
  docs <- readtext(paste0(path_to_text_files, "/*.txt"))
}, error = function(e) {
  message("Error: Cannot find TXT files in the specified directory.")
  stop("Exiting script.")
})

# Apply the cleaning function to the loaded documents.
cleaned_docs <- clean_text(docs$text)
# Filter out empty documents after cleaning.
cleaned_docs <- cleaned_docs[nchar(cleaned_docs) > 0]
docs$doc_id <- docs$doc_id[nchar(cleaned_docs) > 0]
docs$text <- docs$text[nchar(cleaned_docs) > 0]

# Create a Document-Term Matrix (DTM), which is required for LDA.
dtm <- VCorpus(VectorSource(cleaned_docs))
dtm <- DocumentTermMatrix(dtm)

# Remove any rows (documents) that became empty after DTM creation.
row_sums <- rowSums(as.matrix(dtm))
dtm <- dtm[row_sums > 0, ]

# --- 4. Optimal Topic Number Discovery ---
# Convert the DTM to a sparse matrix format required by textmineR.
dtm_dgcm <- Matrix::Matrix(as.matrix(dtm), sparse = TRUE)

# Set the range of topic numbers to test.
num_topics_range <- seq(from = 2, to = 15, by = 1)
coherence_values <- c()

# Loop through the topic range to find the best number of topics using the 'c_v' coherence metric.
for (k in num_topics_range) {
  message("Training model with ", k, " topics...")
  
  # Fit a temporary LDA model to calculate its coherence score.
  lda_model_temp <- textmineR::FitLdaModel(
    dtm = dtm_dgcm,
    k = k,
    iterations = 50,
    seed = SEED,
    coherence = TRUE
  )
  
  coherence_score <- lda_model_temp$coherence
  coherence_values <- c(coherence_values, mean(coherence_score, na.rm = TRUE))
}

# --- 5. Coherence Score Visualization and Final Model ---
# Plot the coherence scores to visualize the trend and identify the optimal topic number.
png(output_path_coherence_plot, width = 1000, height = 800, res = 100)
plot(num_topics_range, coherence_values, type = "b",
     xlab = "Number of Topics (k)", ylab = "Coherence ('c_v') score",
     main = "Coherence Score vs. Number of Topics")
dev.off()
cat(paste0("Save Complete: ", output_path_coherence_plot, "\n"))

# Find the number of topics that corresponds to the highest coherence score.
optimal_num_topics <- num_topics_range[which.max(coherence_values)]
message("The optimal number of topics with the highest 'c_v' coherence score is: ", optimal_num_topics)

# Train the final LDA model using the optimal number of topics.
optimal_lda_model <- topicmodels::LDA(dtm, k = optimal_num_topics, method = "Gibbs", control = list(seed = SEED, iter = 50))

# Extract model parameters for LDAvis visualization.
dtm_matrix <- as.matrix(dtm)
phi <- topicmodels::posterior(optimal_lda_model)$terms %>% as.matrix
theta <- topicmodels::posterior(optimal_lda_model)$topics %>% as.matrix
doc_lengths <- rowSums(dtm_matrix)
vocab <- colnames(phi)
term_freqs <- colSums(dtm_matrix)

# Create the JSON object required by LDAvis.
json_lda <- LDAvis::createJSON(
  phi = phi,
  theta = theta,
  doc.length = doc_lengths,
  vocab = vocab,
  term.frequency = term_freqs,
  R = 30
)

# Launch the interactive LDAvis visualization in your web browser.
# Note: If the visualization does not load when opening the HTML file directly,
# it is likely due to browser security restrictions that prevent local files
# from loading the required JavaScript and CSS resources.
# If the visualization opens in the RStudio Viewer, click 'Show in new window' to view it in a separate window.
LDAvis::serVis(json_lda, out.dir = output_dir_lda_vis, open.browser = TRUE)
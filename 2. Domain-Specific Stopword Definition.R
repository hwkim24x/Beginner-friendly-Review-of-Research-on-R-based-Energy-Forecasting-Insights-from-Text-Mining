# install.packages(c("dplyr", "stringr", "ggplot2", "readr", "here"))
library(dplyr)       # For data manipulation (e.g., filtering, summarizing)
library(stringr)     # For easy and consistent string manipulation
library(ggplot2)     # For creating powerful and customizable data visualizations
library(readr)       # For fast and friendly reading of data files (e.g., .csv, .txt)
library(here)        # For setting relative paths easily and reliably

# --- 1. Path Configuration ---
# Define the path to the directory containing the preprocessed text files.
path_to_text_files <- here("data", "txt3")
# Define the path where the generated plot will be saved.
output_path_plot <- here("All_Documents_Frequency.png")

# --- 2. Custom Stop Words Definition ---
# This list is for manually adding custom stop words that need to be excluded.
# It can be populated with words identified from the visualization.
custom_stopwords <- c(
)

# --- 3. Text Aggregation and Filtering ---
# Get a list of all text files in the specified directory.
file_list <- list.files(path_to_text_files, pattern = "\\.txt$", full.names = TRUE)

# Stop the script if no text files are found, providing a clear error message.
if (length(file_list) == 0) {
  stop("Error: No text files found in the specified directory.")
}

# Read and combine the content of all text files into a single string.
combined_text <- ""
for (file_path in file_list) {
  text <- read_file(file_path)
  text <- tolower(text)
  combined_text <- paste(combined_text, text, sep = " ")
}

# Split the combined text into individual words.
words <- unlist(str_split(combined_text, "\\s+"))

# Filter out the custom stop words and single-letter words.
filtered_words <- words[!(words %in% custom_stopwords) & str_length(words) > 1]

# --- 4. Word Frequency Calculation ---
# Count the frequency of each filtered word.
word_counts <- as.data.frame(table(filtered_words)) %>%
  # Rename the columns for clarity.
  rename(word = filtered_words, count = Freq) %>%
  # Arrange the words in descending order based on their frequency.
  arrange(desc(count)) %>%
  # Select the top 50 most frequent words.
  head(50)

# --- 5. Visualization of Word Frequency ---
# Generate a horizontal bar chart to visualize the top 50 words.
ggplot(word_counts, aes(x = reorder(word, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + # Flip the coordinates to make the bars horizontal.
  labs(
    title = "All documents frequency",
    x = "Word",
    y = "Frequency"
  ) +
  theme_minimal() + # Use a clean, minimal theme.
  theme(plot.title = element_text(hjust = 0.5)) # Center the plot title.

# --- 6. Saving the Visualization ---
# Assign the generated plot to a variable for saving.
frequency_plot <- ggplot(word_counts, aes(x = reorder(word, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + # Flip the coordinates to make the bars horizontal.
  labs(
    title = "All documents frequency",
    x = "Word",
    y = "Frequency"
  ) +
  theme_minimal() + # Use a clean, minimal theme.
  theme(plot.title = element_text(hjust = 0.5)) # Center the plot title.

# Save the generated plot to a high-resolution PNG file.
ggsave(output_path_plot, plot = frequency_plot, dpi = 1000)
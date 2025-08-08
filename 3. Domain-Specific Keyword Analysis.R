# install.packages(c("dplyr", "stringr", "ggplot2", "readr", "here"))
library(dplyr)       # For data manipulation (e.g., filtering, summarizing)
library(stringr)     # For easy and consistent string manipulation
library(ggplot2)     # For creating powerful and customizable data visualizations
library(readr)       # For fast and friendly reading of data files (e.g., .csv, .txt)
library(here)        # For setting relative paths easily and reliably

# --- 1. Path Configuration ---
# Set the path to the directory containing text files for a specific domain.
path_to_text_files <- here("data", "txt3_domain", "Electricity_Forecasting")
# Define the full path where the generated plot image will be saved.
output_path_plot <- here("Freq_Chart_Electricity_Forecasting.png")

# --- 2. Custom Stop Words Definition ---
# Define a list of custom stopwords, including common words and those identified
# from a broader corpus analysis (e.g., from the previous script).
custom_stopwords <- c(
  'model', 'data', 'energy', 'forecast', 'time', 'prediction', 'method', 'base', 'variable', 'set', 'study',
  'parameter', 'al', 'value', 'performance', 'input', 'series', 'approach', 'forecasting', 'predict', 'propose',
  'dataset'
)

# --- 3. Text Aggregation and Filtering ---
# Get a list of all text files in the specified domain directory.
file_list <- list.files(path_to_text_files, pattern = "\\.txt$", full.names = TRUE)

# Stop the script with an error if the directory is empty.
if (length(file_list) == 0) {
  stop("Error: No text files found in the specified directory.")
}

# Read and combine the content of all text files into a single string for analysis.
combined_text <- ""
for (file_path in file_list) {
  text <- read_file(file_path)
  text <- tolower(text)
  combined_text <- paste(combined_text, text, sep = " ")
}

# Split the combined text into individual words.
words <- unlist(str_split(combined_text, "\\s+"))

# Filter out defined stopwords and single-letter words.
filtered_words <- words[!(words %in% custom_stopwords) & str_length(words) > 1]

# --- 4. Word Frequency Calculation ---
# Count the frequency of each filtered word.
word_counts <- as.data.frame(table(filtered_words)) %>%
  # Rename columns for better readability.
  rename(word = filtered_words, count = Freq) %>%
  # Sort words in descending order of their frequency.
  arrange(desc(count)) %>%
  # Select the top 20 most frequent words.
  head(20)

# --- 5. Visualization of Word Frequency ---
# Generate a horizontal bar chart to visualize the top 20 words.
ggplot(word_counts, aes(x = reorder(word, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + # Flip the coordinates for a horizontal layout.
  labs(
    title = "Electricity Forecasting",
    x = "Word",
    y = "Frequency"
  ) +
  theme_minimal() + # Use a minimalist theme for a clean look.
  theme(plot.title = element_text(hjust = 0.5)) # Center the plot title.

# --- 6. Saving the Visualization ---
# Store the generated plot in a variable.
my_plot <- ggplot(word_counts, aes(x = reorder(word, count), y = count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + # Flip the coordinates for a horizontal layout.
  labs(
    title = "Electricity Forecasting",
    x = "Word",
    y = "Frequency"
  ) +
  theme_minimal() + # Use a minimalist theme for a clean look.
  theme(plot.title = element_text(hjust = 0.5)) # Center the plot title.

# Save the generated plot to a high-resolution PNG file.
ggsave(output_path_plot, plot = my_plot, dpi = 1000)
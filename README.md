# Text Mining and Natural Language Processing Project

This project consists of a series of scripts for text mining and natural language processing (NLP), designed to extract, preprocess, and analyze text data from research papers. The workflow includes automated text extraction from PDFs, cleaning, lemmatization, and various analytical steps like keyword analysis and topic modeling.

------------------------------------------------------------------------

### Project Structure

The project is organized into an R Project file and several code files that interact with a data folder.

-   **nlp_for_research_papers.Rproj**: The R Project file for managing the workspace.
-   **data folder**: Contains all input and output files.
    -   **pdf**: Manually collected research papers in PDF format.
    -   **txt**: Extracted text files from the pdf folder.
    -   **txt2**: Cleaned and preprocessed text files from the txt folder.
    -   **txt3**: Further lemmatized and cleaned text files from the txt2 folder.
    -   **txt3_domain**: Text files from the txt3 folder, manually categorized by domain.
    -   **stop_words_english.txt**: A custom list of English stopwords.
-   **src folder**: Contains the source code files. (Implicitly, based on the file names)
    -   **1. Automated PDF Text Extractor.ipynb**: Python script for text extraction.
    -   **2. Domain-Specific Stopword Definition.R**: R script for word frequency analysis.
    -   **3. Domain-Specific Keyword Analysis.R**: R script for domain-specific keyword analysis.
    -   **4. TF-IDF Word Cloud.R**: R script for TF-IDF word cloud visualization.
    -   **5. LDA Topic Modeling.R**: R script for Latent Dirichlet Allocation (LDA) topic modeling.
    -   **Readme.md**: This document.

------------------------------------------------------------------------

### Prerequisites

To run these scripts, you'll need the following environments and libraries installed.

#### Python Environment

The `Automated PDF Text Extractor` script requires the following library:

``` python
pip install PyPDF2
pip install nltk
```

> You will also need to download NLTK data (stopwords and wordnet) by running `nltk.download('stopwords')` and `nltk.download('wordnet')` in a Python console.

#### R Environment

The R scripts (`2. Domain-Specific Stopword Definition` to `5. LDA Topic Modeling`) require several packages. You can install all of them by running the following command in your R console:

``` r
install.packages(c("dplyr", "stringr", "ggplot2", "readr", "here", "tm", "wordcloud", "RColorBrewer", "text2vec", "topicmodels", "textstem", "stopwords", "LDAvis", "readtext", "stringi", "textmineR", "Matrix", "servr"))
```

------------------------------------------------------------------------

### Workflow and Manual Steps

1.  **PDF Collection**
    -   Research papers related to energy and forecasting are **manually collected** and saved in the `data/pdf` folder.
2.  **PDF to Text Extraction**
    -   The `1. Automated PDF Text Extractor` Python script is run to extract text from all PDF files in `data/pdf` and save the output as `.txt` files in `data/txt`.
3.  **Text Preprocessing and Cleaning**
    -   The `1. Automated PDF Text Extractor` script also includes extensive text preprocessing steps. It cleans the text, removes special characters, and applies **lemmatization** to reduce words to their base form.
    -   **Note:** The `reference` section of the papers were handled **manually** to improve the quality of the data.
4.  **Domain Categorization**
    -   The cleaned text files from `data/txt3` are **manually classified** into domain-specific folders within `data/txt3_domain` based on their content (e.g., 'Electricity_Forecasting', 'Solar_Energy_Forecasting').
5.  **Stopwords Definition**
    -   The `stop_words_english.txt` file contains a custom list of stopwords. These were curated by adding protected stopwords (prepositions, conjunctions, adverbs, pronouns, numbers, symbols, etc.) from the **"countwordsfree"** website to the existing list. You can find this resource at: <https://countwordsfree.com/stopwords>.

------------------------------------------------------------------------

### Scripts and Their Functions

#### 1. Automated PDF Text Extractor (Python)

This script automates the process of converting PDF documents into plain text files. It uses the `PyPDF2` library to read and extract text from all PDF files in the `data/pdf` folder and saves them to `data/txt`. It also handles a significant portion of the text preprocessing, including custom stopword removal and lemmatization, saving the final output to `data/txt2` and `data/txt3`.

#### 2. Domain-Specific Stopword Definition (R)

This script reads all preprocessed text files from `data/txt3` to perform a basic word frequency analysis. It calculates the frequency of words across all documents and generates a bar chart of the top 50 most frequent words. This visualization helps in **manually identifying and defining additional domain-specific stopwords** that can be added to the `custom_stopwords` list.

#### 3. Domain-Specific Keyword Analysis (R)

This script focuses on a single, specific domain (e.g., 'Electricity_Forecasting'). It calculates the word frequency for all documents within that domain and generates a bar chart of the top 20 keywords. This helps in understanding the core concepts and terms unique to each domain after removing general stopwords.

#### 4. TF-IDF Word Cloud (R)

This script visualizes the most important keywords across the entire corpus using a TF-IDF (Term Frequency-Inverse Document Frequency) model. Words are weighted by their relevance across all documents, and a word cloud is generated to visually represent the words with the highest scores. The output is saved as a high-resolution PNG file.

#### 5. LDA Topic Modeling (R)

This is the final analytical script, which uses Latent Dirichlet Allocation (LDA) to discover hidden topics within the documents. It automatically determines the optimal number of topics by calculating the **coherence score** and then trains a final LDA model. The results are visualized with an interactive `LDAvis` plot, which is launched locally in a browser. This visualization allows for exploring the relationship between different topics and their most representative terms.

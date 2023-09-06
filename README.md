# Email Open Rate Prediction System![image](https://github.com/NehAdarsh/Decision-Tree/assets/111151093/f37b99b8-97f1-4ad6-b8ec-3ee3db7f4dd9)


## Overview
This repository contains the Email Open Rate Prediction System, a project designed to predict email open rates based on given email subject lines. The system uses various data sources, pre-processing techniques, manual tagging for different campaigns to achieve this prediction.

## Project Introduction
The Email Open Rate Prediction System is a data-driven project that aims to provide insights into email marketing campaigns by predicting open rates based on subject lines. It involves several key steps, including data collection, pre-processing, manual tagging, data preparation, and open rate prediction.

## Project Overview
The project is structured as follows:

#### Data Sources: These are the Data Sources that we utilized in this project:
-	150 Email Subject Lines: Examples, Best Practices, and More (April 2023) : https://www.wordstream.com/blog/ws/2014/03/31/email-subject-lines
-	184 Best Email Subject Lines And Why They Work! (April 2023) : 
https://optinmonster.com/101-email-subject-lines-your-subscribers-cant-resist
-	500 from 4500 subject lines randomly sampled from an available SQL database

####	Algorithm: 
- Performed Pre-processing, manual tagging, data preparation, and implemented Named Entity Recognition (NER) for each word using NLTK/Spacy

## Goals
The Email Open Rate Prediction System has these primary goals:
-	To provide accurate predictions of email open rates to our clients
-	To offer a clear and understandable algorithm for predicting open rates
-	To assist marketers in optimizing their email subject lines for better engagement

## Getting Started
###	Prerequisites
Before using the Email Open Rate Prediction System, ensure you have the following prerequisites in place
•	Access to a Python environment
•	Required Python packages and libraries installed (See installation section)
•	Access to the relevant data sources, as mentioned in the data sources section

###	Installation
Install these dependencies:

![Screen Shot 2023-09-06 at 2 50 47 PM](https://github.com/NehAdarsh/Decision-Tree/assets/111151093/b0b60b9c-0aa3-4ccd-b247-5a6d08c74d5f)

![Screen Shot 2023-09-06 at 2 50 55 PM](https://github.com/NehAdarsh/Decision-Tree/assets/111151093/5371a662-182a-4c3b-93b3-147430cfc20f)

![Screen Shot 2023-09-06 at 2 51 04 PM](https://github.com/NehAdarsh/Decision-Tree/assets/111151093/126d9ada-8006-49ef-96fc-f856adb714c4)

### Usage
The system can be used for predicting email open rates as follows:
- Collect and preprocess subject lines from data sources.
- Manually tag words in subject lines with campaign types and weights.
- Prepare the data and generate trigram word combinations.
- Input the email open rate data for different campaign types.
- Predict open rates using the provided algorithm.


##	Algorithm 

The algorithm employed in the Email Open Rate Prediction System encompasses several crucial steps:

### Pre-processing
- Import subject lines from the given data sources
- Tokenize subject lines into individual words
- After tokenization, NER algorithm is applied to each word in the subject lines. The NER algorithms, such as those provided by NLTK or Spacy, analyze the words and attempt to identify and classify them as specific types of entities, such as:

- - Person Names: Identifying names of individuals mentioned in the subject lines.
- - Organizations: Recognizing company names or organizations referred to in the subject lines.
- - Locations: Identifying places or locations mentioned.
- - Dates: Extracting date-related information if present in the subject lines.
- - Product Names: Detecting product names or mentions if relevant.
- After NER, the system filters out relevant entities based on the project's requirements. It keeps entities that are meaningful for the email open rate prediction task while removing non-relevant or trivial entities. This step helps in reducing noise in the data and ensures that only important entities are considered during subsequent tagging and analysis.

### Word Cloud
![Screen Shot 2023-09-06 at 2 28 42 PM](https://github.com/NehAdarsh/Decision-Tree/assets/111151093/13fb6755-f6aa-49ee-89c9-72dd955a789d)


  
### Manual Tagging
Classified each word into one of three campaign types (Words may belong to one or more types):
- Blast Awareness
- Engagement
- Highly Targeted


As Subject matter experts (SMEs), assigned weightage from 0 to 1 to indicate each word's power towards a specific campaign type. 
- Weightage > 0.5 represents a positive power word
- Weightage < 0.5 indicates a negative influence

### Data Preparation & Generation
Create a metadata table for each word containing:
- The Word
- Campaign Type
- Source 
- Weightage
Generated over 10,000 relevant combinations of trigram (3-gram) words to facilitate the prediction process.

### Open Rate Prediction
Obtain input data from a client, including email open rate statistics for each of the three campaign types (mean and standard deviation).
For each trigram, predict its open rate using the following rules:
```
- If a subject line has 1 power word, assign the predict rate: mean + sd
- If a subject line has 2 or more power words, assign the predict rate: mean + 2*sd
- If a subject line has 1 negative word, assign the predict rate: mean - 0.5 sd
- If a subject line has 2 or more negative words, assign the predict rate: mean - sd
- If a subject line has 1 power word and 1 negative word, assign the predicted rate: mean + 0.5 sd
- If a subject line has 1 power word and 2 or more negative words, assign the predicted rate: mean
- If a subject line has 2 or more power words and 1 negative word, assign the predicted rate: mean + 1.5 sd
- If a subject line has 2 or more power words and 2 or more negative words, assign the predicted rate: mean + sd
```
Notably, power words are identified as words belonging to a specific campaign type with an weight > 0.5, while negative power words have an SM weight < 0.5.
#### Logic behind this:
```
def predict_open_rate(num_power_words, num_negative_words, mean, sd):
    half_sd = sd / 2

    if num_power_words >= 2 and num_negative_words >= 2:
        predicted_open_rate = mean + sd
    elif num_power_words >= 2 and num_negative_words == 1:
        predicted_open_rate = mean + sd + half_sd
    elif num_power_words >= 2 and num_negative_words == 0:
        predicted_open_rate = mean + 2 * sd
    elif num_power_words == 1 and num_negative_words >= 2:
        predicted_open_rate = mean
    elif num_power_words == 1 and num_negative_words == 1:
        predicted_open_rate = mean + half_sd
    elif num_power_words == 1 and num_negative_words == 0:
        predicted_open_rate = mean + sd
    elif num_power_words == 0 and num_negative_words >= 2:
        predicted_open_rate = mean - sd
    elif num_power_words == 0 and num_negative_words == 1:
        predicted_open_rate = mean - half_sd
    else:
        predicted_open_rate = mean

    if predicted_open_rate < 0:
        predicted_open_rate = 0

    return predicted_open_rate
    
#Calling the above function and printing the predicted open rate for the email subject line
predicted_open_rate = predict_open_rate(num_power_words, num_negative_words, mean, sd)
print(f"Email Subject Line is: {email_subject_line}\nPredicted Open Rate for this subject line is: {predicted_open_rate}")

```

#### Model Performance (Results)
```
Email Subject Line is: Just a few more steps! Complete your profile and start connecting
The predicted Open Rate for this subject line is: 3.0
```



## Achievements
The Email Open Rate Prediction System has achieved the following milestones:

- Successful prediction of open rates for various email marketing campaigns.
- Provision of valuable insights into the influence of specific words and phrases on email open rates.
- User-friendly tools for marketers to optimize email subject lines, improving engagement.

## Acknowledgments
- [1] Usman Malik, Stack Abuse. Python for NLP: Tokenization, Stemming, and Lemmatization with SpaCy Library. [https://stackabuse.com/python-for-nlp-tokenization-stemming-and-lemmatization-with-spacy-library/]
- [2] Angelica Lo Duca, 2021. Towards Data Science - TEXT ANALYSIS. How to Extract Structured Information from a Text through Python SpaCy. [https://towardsdatascience.com/how-to-extract-structured-information-from-a-text-through-python-spacy-749b311161e]
- [3] Stack Overflow, 2021. Replace entity with its label in SpaCy. [https://stackoverflow.com/questions/58712418/replace-entity-with-its-label-in-spacy]
- [4] Manfye Goh, 2020. Towards Data Science. Text Normalization with spaCy and NLTK. [https://towardsdatascience.com/text-normalization-with-spacy-and-nltk-1302ff430119]



from collections import Counter
import re
import os
import numpy as np

#print("Loading corpus...")
######### Fix re_pattern
re_pattern = r'\b[a-zA-Z0-9\-\'\*]+\b'
#bigram_re_pattern = r'\b[a-zA-Z0-9\-\'\*]+[\s,][a-zA-Z0-9\-\'\*]+\b'
directory = [
	"Joji_s BALLAD Song Lyrics",
	"Duturte_s Speeches",
	"DLSU Student Publications",
	"Journal Articles"
]
text_files = []
term_counter = Counter()
bigram_counter = Counter()
for folder in directory:
    file_names = os.listdir(folder)
    for file_name in file_names[:]:
        with open(folder + "/" + file_name, 'r', encoding='utf8') as f:
            bigrams = []
            title = file_name[:-4]
            temp = {
                    "Title": title,
                    "Raw Text": f.read()
                    }
            temp['Tokens'] = re.findall(re_pattern, temp["Raw Text"].lower())
#            temp['Bigrams'] = list(set(re.findall(bigram_re_pattern, temp["Raw Text"].lower())))
            temp['Vocabulary'] = list(set(re.findall(re_pattern, temp["Raw Text"].lower())))
			
            for i in range(len(temp["Tokens"]) - 1):
                bigrams.append(temp["Tokens"][i] + " " + temp["Tokens"][i + 1])
            temp['Bigrams'] = list(set(bigrams))
            
#            print("===%s===" % title)
#            print("Total tokens: %s" % len(temp['Tokens']))
#            print("Total vocabulary: %s" % len(temp['Vocabulary']))
#            print(temp["Bigrams"])
            
            text_files.append(temp) #text_files is a list of dictionaries
            term_counter.update(temp['Tokens'])
            bigram_counter.update(temp['Bigrams'])

#print("Identifying vocabulary...")

# Find vocabulary set
total_vocabulary = set()
total_bigram_vocabulary = set()
for song in text_files:
    total_vocabulary |= set(song['Vocabulary'])
    total_bigram_vocabulary |= set(song['Bigrams'])
total_vocabulary = list(total_vocabulary)
total_bigram_vocabulary = list(total_bigram_vocabulary)
vocabulary_count = len(total_vocabulary)
bigram_vocabulary_count = len(total_bigram_vocabulary)
#print("Vocabulary count: %s" % vocabulary_count)
#print("Bigram vocabulary count: %s" % bigram_vocabulary_count)
#print(total_vocabulary)
#print(total_bigram_vocabulary)

# Create bag-of-words/count matrix/probability matrix
probMatrix = np.zeros((bigram_vocabulary_count, vocabulary_count))
for file in text_files: #Run through all text files
    for i in range(len(file["Tokens"]) - 2):
        first_idx = total_bigram_vocabulary.index(file["Tokens"][i] + " " + file["Tokens"][i + 1])
        second_idx = total_vocabulary.index(file["Tokens"][i + 2])
        probMatrix[first_idx, second_idx] += 1
    for i in range(bigram_vocabulary_count):
        if np.sum(probMatrix[i,]) != 0:
            probMatrix[i, ] = probMatrix[i, ] / np.sum(probMatrix[i,])
    
# Get and tokenize an input value/hard coded value
inputString = input("Please enter a string: ")

# Modify re_pattern as required
input_re_pattern = r'\b[a-zA-Z0-9\-\'\*]+'
inputTokens = re.findall(input_re_pattern, inputString.lower())

# Output the next probable word based on an input
# Error handling when only one string
lastBigram = inputTokens[-2] + " " + inputTokens[-1]
if lastBigram in total_bigram_vocabulary:   
    bigram_idx = total_bigram_vocabulary.index(lastBigram)
    probMatrix_idx = np.argmax(probMatrix[bigram_idx,])
    print(total_vocabulary[probMatrix_idx])
else:
    print("last two words not in corpus")
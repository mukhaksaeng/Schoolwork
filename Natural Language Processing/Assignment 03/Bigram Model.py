from collections import Counter
import re
import os
import numpy as np

#print("Loading corpus...")
# Fix re_pattern
re_pattern = r'\b[a-zA-Z0-9\-\'\*]+\b|[\.\?\!]'
directory = [
	"Joji_s BALLAD Song Lyrics",
#	"Duturte_s Speeches",
#	"DLSU Student Publications",
#	"Journal Articles"
]
text_files = []
term_counter = Counter()
for folder in directory:
    file_names = os.listdir(folder)
#    probMatrix = np.zeros((len(temp["Vocabulary"]), len(temp["Vocabulary"])))
    for file_name in file_names[:]:
        with open(folder + "/" + file_name, 'r', encoding='utf8') as f:
            title = file_name[:-4]
            temp = {
                    "Title": title,
                    "Raw Text": f.read()
                    }
            temp['Tokens'] = re.findall(re_pattern, temp["Raw Text"].lower())
            temp['Vocabulary'] = list(set(re.findall(re_pattern, temp["Raw Text"].lower())))
			
#            print("===%s===" % title)
#            print("Total tokens: %s" % len(temp['Tokens']))
#            print("Total vocabulary: %s" % len(temp['Vocabulary']))

            text_files.append(temp) #text_files is a list of dictionaries
            term_counter.update(temp['Tokens'])

#print("Identifying vocabulary...")

# Find vocabulary set
total_vocabulary = set()
for song in text_files:
	total_vocabulary |= set(song['Vocabulary'])
total_vocabulary = list(total_vocabulary)
vocabulary_count = len(total_vocabulary)
#print("Vocabulary count: %s" % vocabulary_count)
#print(total_vocabulary)

# Create bag-of-words/count matrix/probability matrix
probMatrix = np.zeros((vocabulary_count, vocabulary_count))
for file in text_files: #Run through all text files
    for i in range(len(file["Tokens"]) - 1):        
        first_idx = total_vocabulary.index(file["Tokens"][i])
        second_idx = total_vocabulary.index(file["Tokens"][i + 1])
        probMatrix[first_idx, second_idx] += 1
    for i in range(vocabulary_count):
        if np.sum(probMatrix[i,]) != 0:
            probMatrix[i, ] = probMatrix[i, ] / np.sum(probMatrix[i,])
    
# Get and tokenize an input value/hard coded value
inputString = input("Please enter a string: ")

# Modify re_pattern as required
input_re_pattern = r'\b[a-zA-Z0-9\-\'\*]+\b|[\.\?\!]'
inputTokens = re.findall(input_re_pattern, inputString.lower())

# Output the next probable word based on an input
if inputTokens[-1] in total_vocabulary:   
    vocab_idx = total_vocabulary.index(inputTokens[-1])
    probMatrix_idx = np.argmax(probMatrix[vocab_idx,])
    print(total_vocabulary[probMatrix_idx])
else:
    print("last word not in corpus")
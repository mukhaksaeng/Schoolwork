import re
import os
import numpy as np

# Fix re_pattern
re_pattern = r'\b[a-zA-Z]+\-?\'?[a-zA-Z]+\b'

corpus = []
directory = "C:\\Users\Justin\Desktop\Open ANC\data"
for dir_path, dir_name, file_name in os.walk(directory):
    if len(file_name) > 0:
        for file in file_name:
            if not file.endswith(".txt"):
                os.remove(os.path.join(dir_path, file))
            else:
                with open(os.path.join(dir_path, file), 'r', encoding='utf8') as f:
                    title = file_name[:-4]
                    temp = {
                            "Title": title,
                            "Raw Text": f.read()
                            }
                    temp['Tokens'] = re.findall(re_pattern, temp["Raw Text"].lower())
                    temp['Vocabulary'] = list(set(re.findall(re_pattern, temp["Raw Text"].lower())))
        
                    corpus.append(temp)
            
# Find vocabulary set
total_vocabulary = set()
words = []
for article in corpus:
    total_vocabulary |= set(article['Vocabulary'])
    words.extend(article['Vocabulary'])
    
total_vocabulary = list(total_vocabulary)
vocabulary_count = len(total_vocabulary)

# Compute for Damerau-Levenshtein edit distance
def minEditDistance(word1, word2):
    # Initialize matrices
    # Note for distMatrix that the origin is at the upper left. Thus, instead of "DOWN", we use "UP"
    distMatrix = np.zeros((len(word1) + 1, len(word2) + 1))
    insCost = 1
    delCost = 1
    transCost = 1
     
    distMatrix[0, 0] = 0     
    for i in range(1, len(word1) + 1):
        distMatrix[i, 0] = i * delCost
    for j in range(1, len(word2) + 1):
        distMatrix[0, j] = j * insCost
                
    # Fill up matrices
    for i in range(1, len(word1) + 1):
        for j in range(1, len(word2) + 1):
            if word1[i - 1] != word2[j - 1]:
                subCost = 2
            else:
                subCost = 0
            distMatrix[i, j] = min(distMatrix[i - 1, j] + insCost, distMatrix[i, j - 1] + delCost, distMatrix[i - 1, j - 1] + subCost, distMatrix[i - 2, j - 2] + transCost)
    
    # Return min edit distance
    return int(distMatrix[len(word1), len(word2)])

# Create probability matrix for unigram model
#probMatrix = np.zeros((vocabulary_count, vocabulary_count))
#for file in corpus: #Run through all text files
#    for i in range(len(file["Tokens"]) - 1):        
#        first_idx = total_vocabulary.index(file["Tokens"][i])
#        second_idx = total_vocabulary.index(file["Tokens"][i + 1])
#        probMatrix[first_idx, second_idx] += 1
#    for i in range(vocabulary_count):
#        if np.sum(probMatrix[i,]) != 0:
#            probMatrix[i, ] = probMatrix[i, ] / np.sum(probMatrix[i,])

# Get (and tokenize) an input value/hard coded value
inputWord = input("Please enter a string: ")
            
# Screen candidates from vocabulary list
candidateList = []

for word in total_vocabulary:
    if minEditDistance(word, inputWord) == 1:
        candidateList.append(word)
        
print(candidateList)
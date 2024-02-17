import os
from fonetika.soundex import RussianSoundex
import string

soundex = RussianSoundex(delete_first_letter=True)
soundex_dictionary = {}


def matching_sequence_lengths(text1, text2):
    words1 = remove_punctuation(text1).split()
    words2 = remove_punctuation(text2).split()
    sequences = []
    current_sequence_length = 0
    last_index = 0
    for word1 in words1:
        i = last_index
        for word2 in words2[last_index:]:
            i += 1
            soundex1 = soundex_transform(word1)
            soundex2 = soundex_transform(word2)
            if soundex1 == soundex2:
                if current_sequence_length > 0:
                    last_index = i
                    current_sequence_length += 1
                    break
                else:
                    if len(soundex1) > 7:
                        last_index = i
                        current_sequence_length += 1
                        break
            else:
                if current_sequence_length > 1:
                    sequences.append(current_sequence_length)
                current_sequence_length = 0
    if current_sequence_length > 1:
        sequences.append(current_sequence_length)
    return sequences


def longest_matching_sequence_length(text1, text2):
    words1 = remove_punctuation(text1).split()
    words2 = remove_punctuation(text2).split()
    max_sequence_length = 0
    current_sequence_length = 0
    last_index = 0
    for word1 in words1:
        for i, word2 in enumerate(words2[last_index:]):
            soundex1 = soundex_transform(word1)
            soundex2 = soundex_transform(word2)
            if soundex1 == soundex2:
                current_sequence_length += 1
                last_index += i + 1
                break
            else:
                max_sequence_length = max(max_sequence_length, current_sequence_length)
                current_sequence_length = 0

    max_sequence_length = max(max_sequence_length, current_sequence_length)
    return max_sequence_length


def soundex_transform(text):
    if text in soundex_dictionary:
        return soundex_dictionary[text]
    else:
        result = soundex.transform(text)
        soundex_dictionary[text] = result
        return result


def remove_punctuation(txt):
    punct_set = set(string.punctuation)
    no_punct = "".join(char for char in txt if char not in punct_set)
    return no_punct

Akin
=======

Akin is a collection of string comparison algorithms for Elixir. This solution was born of a [Record Linking](https://en.wikipedia.org/wiki/Record_linkage) project. It combines and modifies [The Fuzz](https://github.com/smashedtoatoms/the_fuzz) and [Fuzzy Compare](https://github.com/patrickdet/fuzzy_compare). Algorithms can be called independently or in total to return a map of metrics. This library was built to facilitiate the disambiguation of names but can be used to compare any two binaries.

<details>
  <summary>Table of Contents</summary>
  
  1. [Installation](#installation)
  2. [Metrics](#metrics)
     * [Algorithms](#algorithms)
     * [Compare Strings](#compare-strings)
     * [Options](#options)
     * [Algorithms Subset](#algorithm-subset)
     * [Stemming](#stemming)
     * [Max](#max)
     * [Smart Compare](#smart-compare)
     * [Accents](#accents)
     * [Single Algorithms](#single-algorithms)
     * [Metaphone](#metaphone)
     * [n-gram Size](#n-gram-size)
     * [Match Level](#match-level)
     * [Name Disambiguation](#name-disambiguation)
  3. [Algorithms](#algorithms)
     * [Bag Distance](#bag-distance)
     * [Substring Set](#substring-set)
     * [Sørensen–Dice](#sørensen–dice)
     * [Hamming Distance](#hamming-distance)
     * [Jaccard Similarity](#jaccard-similarity)
     * [Jaro-Winkler Similarity](#jaro-winkler-similarity)
     * [Levenshtein Distance](#levenshtein-distance)
     * [Metaphone](#metaphone)
     * [Double Metaphone](#double-metaphone)
     * [Substring Double Metaphone](#substring-double-metaphone)
     * [N-Gram Similarity](#n-gram-similarity)
     * [Overlap Metric](#overlap-metric)
     * [Substring Sort](#substring-sort)
     * [Tversky](#tversky)
  4. [Resources & Credit](#resources-&-credit)
  5. [In Development](#in-development)
</details>

## Installation

Add a dependency in your mix.exs:

```elixir
deps: [{:akin, "~> 1.0"}]
```

## Metrics

### Algorithms

To see all of the avialable algorithms:

```elixir
iex> Akin.algorithms()
["bag_distance", "substring_set", "sorensen_dice", "hamming", "jaccard", "jaro_winkler", 
"levenshtein", "metaphone", "double_metaphone", "substring_double_metaphone", "ngram", 
"overlap", "substring_sort", "tversky"]
```

Subsets of algorithems 

Hamming Distance is always excluded as it only compares strings of equal length. Hamming may be called directly. See: [Single Algorithms](#single-algorithms)

```elixir
iex> Akin.algorithms([metric: "phonetic"])
["metaphone", "double_metaphone", "substring_double_metaphone"]
iex> Akin.algorithms([metric: "phonetic", unit: unit]) 
["metaphone", "double_metaphone"]
iex> Akin.algorithms([metric: "phonetic", unit: "parts"])
["substring_double_metaphone"]
```

### Compare Strings

Compare two strings using all of the available algorithms. The return value is a map of scores for each algorithm.

 ```elixir
iex> Akin.compare("weird", "wierd")
%{
  bag_distance: 1.0,
  sorensen_dice: 0.25,
  double_metaphone: 1.0,
  jaccard: 0.14,
  jaro_winkler: 0.94,
  levenshtein: 0.6,
  metaphone: 1.0,
  ngram: 0.25,
  overlap: 0.25,
  tversky: 0.14
}
```

```elixir
iex> Akin.compare("beginning", "begining")
%{
  bag_distance: 0.89,
  sorensen_dice: 0.93,
  double_metaphone: 1.0,
  jaccard: 0.88,
  jaro_winkler: 0.95,
  levenshtein: 0.89,
  metaphone: 1.0,
  ngram: 0.88,
  overlap: 1.0,
  tversky: 0.88
}
```

### Options

Comparison accepts options in a Keyword list. 

  1. `algorithms`: algorithms to use in comparision. Accepts the name or a keyword list. Default is algorithms/0.
      1. `metric` - algorithm metric. Default is both
        - "string": uses string algorithms
        - "phonetic": uses phonetic algorithms
      1. `unit` - algorithm unit. Default is both.
        - "whole": uses algorithms best suited for whole string comparison (distance)
        - "parts": uses algorithms best suited for partial string comparison (substring)
  1. `ngram_size`: number of contiguous letters to split strings into. Default is 2.
  1. `match_at`: an algorith scoare equal to or above this value is condsidered a match. Default is 0.9
  1. `level` - level for double phonetic matching. Default is "normal".
      - "strict": both encodings for each string must match
      - "strong": the primary encoding for each string must match
      - "normal": the primary encoding of one string must match either encoding of other string (default)
      - "weak":   either primary or secondary encoding of one string must match one encoding of other string
  1. `short_length`: qualifies as "short" to recieve a shortness boost. Used by Name Metric. Default is 8.

### Algorithms Subset

Comparison can request a subset of algorithms.  

```elixir
iex> Akin.compare("weird", "wierd", [algorithms: "bag_distance", "jaro_winkler", "jaccard"])  
%{bag_distance: 1.0, jaccard: 0.14, jaro_winkler: 0.94}
```

```elixir
iex> Akin.compare("weird", "wierd", [ngram_size: 1, metric: "string", unit: "whole"])
%{jaccard: 0.67} 
```

```elixir
iex> Akin.compare("weird", "wierd")
%{
  bag_distance: 1.0,
  sorensen_dice: 0.25,
  double_metaphone: 1.0,
  jaccard: 0.14,
  jaro_winkler: 0.94,
  levenshtein: 0.6,
  metaphone: 1.0,
  ngram: 0.25,
  overlap: 0.25,
  tversky: 0.14
}
```

### Stemming

Compare the stemmed version of two strings.

```elixir
iex> Akin.compare_stems("write", "writing")
%{
  bag_distance: 1.0,
  sorensen_dice: 1.0,
  double_metaphone: 1.0,
  jaccard: 1.0,
  jaro_winkler: 1.0,
  levenshtein: 1.0,
  metaphone: 1.0,
  ngram: 1.0,
  overlap: 1.0,
  tversky: 1.0
}
```

### Max 

Compare two strings using all algorithms. From the metrics returned through the comparision, return only the highest algorithm scores.
The strings are compared using the default list of comparison algorithms unless a list of algorithms is given. Also accepts a keyword list of options. 

```elixir
iex> Akin.max("weird", "wierd")
[bag_distance: 1.0, double_metaphone: 1.0, metaphone: 1.0]
```

```elixir
iex> Akin.max("Alice P. Liddel", "Alice Liddel")
[jaro_winkler: 0.98]
```

```elixir
iex> Akin.max("Alice P. Liddel", "Alice Liddel", ["substring_double_metaphone"])
[substring_double_metaphone: 1.0]
```

```elixir
iex> limited = Akin.compare("beginning", "begining", ["bag_distance", "jaro_winkler", "levenshtein"], [])
%{bag_distance: 0.89, jaro_winkler: 0.95, levenshtein: 0.89} 
```

```elixir
iex> Akin.max(limited)
[jaro_winkler: 0.95]
```

### Smart Compare

When the strings contain spaces, such as a name comprised of a given and family nam, you can narrow the results to only algorithms which take substrings into account. Do that by using `smart_compare/2` which will check for white space in either of the strings being compared. If white space is found, then the comaparison will use algorithms that prioritize substrings: "substring_set", "overlap", and "substring_sort". Otherwise, the comparison will use  algoritms which do not prioritize substrings. Furthermore, if either string is shorter than or equal to the `length cutoff`, then N-Gram alogrithms are excluded (Sorensen-Dice, Jaccard, NGram, Overlap, and Tversky)

```elixir
iex> Akin.smart_compare("weird", "wierd")
%{
  bag_distance: 1.0,
  dice_sorensen: 0.25,
  double_metaphone: 1.0,
  jaccard: 0.14,
  jaro_winkler: 0.94,
  levenshtein: 0.6,
  metaphone: 1.0,
  ngram: 0.25,
  overlap: 0.25,
  tversky: 0.14
}
```

```elixir
iex> Akin.smart_compare("Alice Pleasance Liddel", "Alice P. Liddel")
%{
  substring_set: 0.85,
  substring_double_metaphone: 0.67,
  overlap: 1.0,
  substring_sort: 0.85
}
```

### Accents

```elixir
iex> Akin.compare("Hubert Łępicki", "Hubert Lepicki")
%{
  bag_distance: 0.92,
  dice_sorensen: 0.83,
  double_metaphone: 0.0,
  jaccard: 0.71,
  jaro_winkler: 0.97,
  levenshtein: 0.92,
  metaphone: 0.0,
  ngram: 0.83,
  overlap: 0.83,
  tversky: 0.71
}
```

### Single Algorithms

Use a single algorithm for comparing two strings. The return value is a float.

```elixir
iex> left = "Alice P. Liddel"
iex> right = "Liddel, Alice"
iex> Akin.compare_using("jaro_winkler", left, right)
0.71
iex> Akin.compare_using("levenshtein", left, right) 
0.33
iex> Akin.compare_using("metaphone", left, right)
0.0
iex> Akin.compare_using("double_metaphone", left, right)  
0.0
iex> Akin.compare_using("substring_double_metaphone", left, right)
1.0
iex> Akin.compare_using("substring_set", left, right)
0.74
iex> Akin.compare_using("substring_sort", left, right)
0.97
iex> Akin.compare_using("tversky", left, right)
0.4
```

### Metaphone

Metaphone and Double Metaphone results can be retrieved directly outside of a comparison.

```elixir
iex> Akin.Metaphone.Metaphone.compute("virginia")
"frjn"
iex> Akin.Metaphone.Metaphone.compute("woolf")
"wlf"
iex> Akin.Metaphone.Metaphone.compute("woolfe")
"wlf"
iex> Akin.Metaphone.Double.parse("virginia")
{"frjn", "frkn"}
iex> Akin.Metaphone.Double.parse("woolfe") 
{"alf", "flf"}
```

### n-gram Size

The default ngram size for the algorithms is 2. You can change by setting 
a value in opts.

```elixir
iex> Akin.compare_using("sorensen_dice", "weird", "wierd")
0.25
iex> Akin.compare_using("sorensen_dice", "weird", "wierd", [ngram_size: 1])
0.8
iex> left = "Alice P. Liddel"
iex> right = "Liddel, Alice"
iex> Akin.compare_using("tversky", left, right)
0.4
iex> Akin.compare_using("tversky", left, right, [ngram_size: 1])
0.8
iex> Akin.compare_using("tversky", left, right, [ngram_size: 3])
0.0
```

### Match Level

The default match strictness is "normal" You change it by setting 
a value in opts. Currently it only affects the outcomes of the `substring_set` and
`double_metaphone` algorithms

```elixir
iex> left = "Alice in Wonderland"
iex> right = "Alice's Adventures in Wonderland"
iex> Akin.compare_using("substring_set", left, right)
0.64
iex> Akin.compare_using("substring_set", left, right, [level: "weak"])
0.85
iex> left = "which way"
iex> right = "whitch way"
iex> Akin.compare_using("double_metaphone", left, right, [level: "weak"])
1.0
iex> Akin.compare_using("double_metaphone", left, right, [level: "strict"])
0.0
```

### Name Disambiguation

_UNDER DEVELOPMENT_

Identity is the challenge of author name disambiguation (AND). The aim of AND is to match an author's name to that author when the author appears in a list of many authors. Complexity arises from homonymity (many people with the same name) and synonymity (when one person uses different forms/spellings of their name in publications). 

Given the name of an author which is divided into the given, middle, and family name parts (i.e. "Virginia", nil, "Woolf") and a list of possible matching author names, find and return the matches for the author in the list. 

This method manages a name with initials. If the left string includes initials, the name may have a lower score when compared to the full name if it exists in the right string. Therefore there is an option available to the name matching method to compare initials: [boost_initials: true].

If the option is set and initials exist in the left name, a separate comparison is performed for the initals and the sets of the right string. There must be an exact match of each initial against the first character of one of the sets.

Hamming Distance algorithm is excluded as it only compares strings of equal length. Hamming may be called directly. See: [Single Algorithms](#single-algorithms)

If the comparison metrics produce a score greater than or equal to 0.9, they considered a match and returned in the list.

```elixir
iex> Akin.match_names("V. Woolf", ["V Woolf", "V Woolfe", "Virginia Woolf", "V White", "Viginia Wolverine", "Virginia Woolfe"])
["v woolfe", "v woolf"]
iex> Akin.match_names("V. Woolf", ["V Woolf", "V Woolfe", "Virginia Woolf", "V White", "Viginia Wolverine", "Virginia Woolfe"], [boost_initials: true])
["virginia woolfe", "v woolf"]
```

This may not be what you want. There are likely to be unwanted matches.

```elixir
iex> Akin.match_names("V. Woolf", ["Victor Woolf", "Virginia Woolf", "V White", "V Woolf", "Virginia Woolfe"], [boost_initials: true])
["v woolf", "virginia woolf", "victor woolf"]
```

---

## Algorithms

### Bag Distance

The bag distance is a cheap distance measure which always returns a distance smaller or equal to the edit distance. It's meant to be an efficient approximation of the distance between two strings to quickly rule out strings that are largely different.  

### Substring Set

Splits the strings on spaces, sorts, re-joins, and then determines Jaro-Winkler distance. Best when the strings contain irrelevent substrings. 

### Sørensen–Dice 

Sørensen–Dice coefficient is calculated using bigrams. The equation is `2nt / nx + ny` where nx is the number of bigrams in string x, ny is the number of bigrams in string y, and nt is the number of bigrams in both strings. For example, the bigrams of `night` and `nacht` are `{ni,ig,gh,ht}` and `{na,ac,ch,ht}`. They each have four and the intersection is `ht`. 

``` (2 · 1) / (4 + 4) = 0.25 ```

### Hamming Distance

Note: Hamming algorithm is not used in an of the comparison functions because it requires the strings being compared are of the same length. It can be called directly, however, so it is still a part of this library.

The Hamming distance between two strings of equal length is the number of positions at which the corresponding letters are different. Returns the percentage of change needed to the left string of the comparison of one string (left) with another string (right). Returns 0.0 if the strings are not the same length. Returns 1.0 if the string are equal.

### Jaccard Similarity

Calculates the similarity of two strings as the size of the intersection divided by the size of the union. Default ngram: 2.

### Jaro-Winkler Similarity

Jaro-Winkler calculates the edit distance between two strings. A score of one denotes equality. Unlike the Jaro Similarity, it modifies the prefix scale to gives a more favorable rating to strings that match from the beginning.

### Levenshtein Distance

Compare two strings for their Levenshtein score. The score is determined by finding the edit distance: the minimum number of single-character edits needed to change one word into the other. The distance is substracted from 1.0 and then divided by the longest length between the two strings. 

### Metaphone 

Compares two strings by converting each to an approximate phonetic representation in ASCII and then comparing those phoenetic representations. Returns a 1 if the phoentic representations are an exact match.

### Double Metaphone 

Calculates the [Double Metaphone Phonetic Algorithm](https://xlinux.nist.gov/dads/HTML/doubleMetaphone.html) metric of two strings. The return value is based on the match level: strict, strong, normal (default), or weak. 

  * "strict": both encodings for each string must match
  * "strong": the primary encoding for each string must match
  * "normal": the primary encoding of one string must match either encoding of other string (default)
  * "weak":   either primary or secondary encoding of one string must match one encoding of other string

### Substring Double Metaphone

Iterate over the cartesian product of the two lists sending each element through
the Double Metaphone using all strictness levels until a true value is found
in the list of returned booleans from the Double Metaphone algorithm. Return the 
percentage of true values found. If true is never returned, return 0. Increases  
accuracy for search terms containing more than one word.

### N-Gram Similarity

Calculates the ngram distance between two strings. Default ngram: 2.

### Overlap Metric

Uses the Overlap Similarity metric to compare two strings by tokenizing the strings and measuring their overlap. Default ngram: 1.

### Substring Sort

Sorts substrings by words, compares the sorted strings in pairs, and returns the maximum ratio. If one strings is signficantly longer than the other, this method will compare matching substrings only. 

### Tversky 

A generalization of Sørensen–Dice and Jaccard.

## Resources & Credit

* [Disambiguation Datasets](https://github.com/dhwajraj/dataset-person-name-disambiguation)
* [Double Metaphone in python](https://github.com/oubiwann/metaphone/blob/master/metaphone/metaphone.py)
* [Fuzzy Compare](https://github.com/patrickdet/fuzzy_compare)
* [Python Fuzzy Wuzzy (2011)](https://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/)
* [ML Authur Block Dismabiguation](https://github.com/helenamihaljevic/ads_author_disambiguation)
* [ML Author Name Disambiguation](https://medium.com/ai2-blog/s2and-an-improved-author-disambiguation-system-for-semantic-scholar-d09380da30e6)
* [Record Linking](https://en.wikipedia.org/wiki/Record_linkage)
* [The Fuzz](https://github.com/smashedtoatoms/the_fuzz)
* [Homophones used in testing metaphone algorithms](https://www.cs.cmu.edu/afs/cs/project/ai-repository/ai/areas/speech/database/homofonz/)

## In Development

* Document Machine Learning in ReadMe
* Add Damerau-Levenshtein algorithm
  * [Damerau-Levenshtein](https://en.wikipedia.org/wiki/Damerau-Levenshtein_distance)
  * [Examples](https://datascience.stackexchange.com/questions/60019/damerau-levenshtein-edit-distance-in-python)
* Add Caverphone algorithm
  * [Caverphone](https://en.wikipedia.org/wiki/Caverphone)
  * [Research](https://caversham.otago.ac.nz/files/working/ctp150804.pdf)
  * [Example](https://gist.github.com/kastnerkyle/a697d4e762fa8f53c70eea7bc712eead)
* Compare results to Python's [FuzzyWuzzy](https://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/) library using [ErlPort](http://erlport.org/)
* Author Name Disambiguation (see lib/akin/and.ex for developments)

[![Swift 3.0](https://img.shields.io/badge/swift-3.0-brightgreen.svg)](https://swift.org)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)

Honyaku: A MeCab wrapper for Swift

# Format
*HonyakuText* ->  
*[HonyakuSentence]* ->  
*[HonyakuWord]*
* surface (as appears in text)
* pos (part of speech)
* pos_subone (extra information concerning part of speech)
* pos_subtwo
* pos_subthree
* inflection
* conjugation
* root (deconjugated word)
* reading (formal written form, in hiragana)
* pronunciation (spoken, written in katanana)
 
# Functions

## contains
Returns true if Text (or Sentence) contain the target word.

## filter
Filter HonyakuText, returning only HonyakuSentences that contain the target word.

## indexOf
*Within Text*: Return the first index of a sentence containing the target word.
*Within Sentence*: Return the first index of the target word, if it appears. This is not the exact location of the target word within the sentence, but the relative position among all elements.

## toSurface
Returns the text or selected sentence to its original form.

# Example
```
let parser = Honyaku()

let text: HonyakuText = try! parser.parse(filePath: "/path/to/file.txt")

text.contains(word: "翻訳")
text.sentences.first?.contains(word: "翻訳")
text.indexOf(word: "翻訳")
```

# Requirements
* Swift 3.0 or later
* [MeCab](http://taku910.github.io/mecab/)

# Installation
Copy Honyaku.swift to project.

# License
Apache

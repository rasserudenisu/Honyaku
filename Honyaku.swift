/*
* Honyaku.swift
* Honyaku
*
* Copyright (c) 2016 Dennis Russell
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*  http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation
 
class Honyaku {
	
	/**
	Process the specified text file.
	
	Currently supports plain text only. Any formatting is lost after processing.
	
	- parameter filePath: Single text file to process.
	- parameter mecabPath: A specific mecab path. Default value of /usr/local/bin/.
	
	- throws: When either parameter is not valid.
	
	- returns: The processed text.
	*/
	func parse(filePath: String, mecabPath: String = "/usr/local/bin/mecab") throws -> HonyakuText {
		
		guard filePath != "" && filePath.isEmpty != true && FileManager.default.fileExists(atPath: filePath) == true else {
			throw HonyakuError.invalidFilePath("Source file not found at: \(filePath)")
		}
		guard FileManager.default.fileExists(atPath: mecabPath) == true else {
			throw HonyakuError.invalidMecabPath("Mecab executable not found at: \(mecabPath)")
		}
		
		let text = HonyakuText()
		
		let task = Process()
		let output = Pipe()
		
		task.launchPath = mecabPath
		task.arguments = [filePath]
		task.standardOutput = output
		
		task.launch()
		
		let data = output.fileHandleForReading.readDataToEndOfFile()
		let result = String(data: data, encoding: String.Encoding.utf8)
		
		text.sentences.append(HonyakuSentence())
		for line in (result?.components(separatedBy: "\n"))! {
			if line == "EOS" {
				if text.sentences.last?.words.count != 0 {
					text.sentences.append(HonyakuSentence())
				}
			}
			else {
				let detail = HonyakuWord()
				detail.parse(line: line)
				text.sentences.last?.words.append(detail)
			}
		}
		
		task.terminate()
		
		return text
		
	}
	
}

class HonyakuText {
	var sentences: [HonyakuSentence] = []
	
	/**
		Search the entire text for target word. 
	
		May take either the surface or base form.

		- parameter word: The word to search for.
	
		- returns: Whether the text contains the word.
	*/
	func contains(word: String) -> Bool {
		for value in sentences {
			return value.contains(word: word)
		}
		return false
	}
	
	/**
		Find index of first sentence containing word.
		
		May take either the surface or base form.
		
		- parameter word: The word to search for.
		
		- returns: Index of sentence containing word.
	*/
	func indexOf(word: String) -> Int {
		for value in 0..<sentences.count {
			if sentences[value].contains(word: word) {
				return value
			}
		}
		
		return -1
	}
	
	/**
	Filter HonyakuText sentences by target word.
	
	May take either the surface or base form.
	
	- parameter word: The word to filter by.
	
	- returns: A new instance of HonyakuText, with sentences containing word.
	*/
	func filter(word: String) -> HonyakuText {
		let x = HonyakuText()
		for value in sentences {
			if value.contains(word: word) {
				x.sentences.append(value)
			}
		}
		return x
	}
	
	/**
	Reconstructs the original text in its entirety.
	
	Original formatting is not maintained.
	
	- returns: A String reconstruction of the initially parsed text.
	*/
	func toSurface() -> String {
		var surface = String()
		for sentence in sentences {
			surface.append(sentence.toSurface())
		}
		return surface
	}
	
}

class HonyakuSentence {
	var words: [HonyakuWord] = []
	
	/**
	Search the sentence for target word.
	
	May take either the surface or base form.
	
	- parameter word: The word to search for.
	
	- returns: Whether the text contains the word.
	*/
	func contains(word: String) -> Bool {
		for value in words {
			if value.surface == word || value.root == word {
				return true
			}
		}
		return false
	}
	
	/**
	Find index of first given word in sentence.
	
	Returns the relative position of the word in the parsed sentence, not the absolute position.
	
	May take either the surface or base form.
	
	- parameter word: The word to search for.
	
	- returns: Index of word in sentence.
	*/
	func indexOf(word: String) -> Int {
		for value in 0..<words.count {
			if words[value].surface == word || words[value].root == word {
				return value
			}
		}
		
		return -1
	}
	
	/**
	Reconstructs the original sentence in its entirety.
	
	- returns: A String of the initially parsed sentence.
	*/
	func toSurface() -> String {
		return words.flatMap({$0.surface}).joined()
	}
	
}

class HonyakuWord {
	
	var surface: String? = nil
	var pos: String? = nil
	var pos_subone: String? = nil
	var pos_subtwo: String? = nil
	var pos_subthree: String? = nil
	var inflection: String? = nil
	var conjugation: String? = nil
	var root: String? = nil
	var reading: String? = nil
	var pronunciation: String? = nil
	
	func parse(line: String) {
		if line.characters.count <= 0 {
			return
		}
		
		let regex = try! NSRegularExpression(pattern: "(\\s)", options: .caseInsensitive)
		let linefix = regex.stringByReplacingMatches(in: line, options: .withoutAnchoringBounds, range: NSMakeRange(0, line.characters.count), withTemplate: ",").components(separatedBy: ",")
		
		surface = linefix[0]
		pos = linefix[1]
		inflection = linefix[5]
		conjugation = linefix[6]
		root = linefix[7]
		reading = linefix[8]
		pronunciation = linefix[9]
		
		if linefix[2] != "*" {
			pos_subone = linefix[2]
		}
		if linefix[3] != "*" {
			pos_subtwo = linefix[2]
		}
		if linefix[4] != "*" {
			pos_subthree = linefix[2]
		}
		
	}
	
}

enum HonyakuError: Error {
	case invalidFilePath(String)
	case invalidMecabPath(String)
}

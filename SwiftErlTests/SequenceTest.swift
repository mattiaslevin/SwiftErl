//
//  SequenceTest.swift
//  SwiftErl
//
//  Created by Mattias Levin on 22/10/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

import UIKit
import XCTest

class SequenceTest: XCTestCase {
  
  let strings = Array(count: 10, repeatedValue: "A")
  let numbers = Array(1..<10)
  let emptyStrings = [String]()
  let emptyNumbers = [Int]()
  
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  
  func testAll() {
    
    var strings = Array(count: 10, repeatedValue: "A")
    XCTAssertTrue(strings.asSequence().all { $0 == "A" } )
    
    var strings2 = Array(strings)
    strings2.append("B")
    XCTAssertFalse(strings2.asSequence().all { $0 == "A"} )
    
    XCTAssertTrue(emptyStrings.asSequence().all {$0 == "A"} )
    
  }
  
  
  func testAny() {
    
    XCTAssertTrue(numbers.asSequence().any {$0 == 5} )
    
    XCTAssertFalse(numbers.asSequence().any {$0 == 12} )
    XCTAssertFalse(numbers.asSequence().any {$0 == "A"} )
    
    XCTAssertFalse(emptyStrings.asSequence().any { $0 == "A"} )
    
  }
  
  
  func testAppend() {
    
    let sequence1 = SequenceOf(1..<5)
    let sequence2 = SequenceOf(5..<10)
    
    var appendedSequence = sequence1.append(sequence2)
    var appendedArray = appendedSequence.asArray()
    
    XCTAssertTrue(appendedArray.count == 9)
    
    for (index, number) in enumerate(appendedSequence) {
      XCTAssertTrue(appendedArray[index] == index + 1)
    }
    
    appendedSequence = sequence1.append(emptyNumbers.asSequence())
    XCTAssertTrue(appendedSequence.asArray().count == sequence1.asArray().count)
    
    appendedSequence = emptyNumbers.asSequence().append(sequence1)
    XCTAssertTrue(appendedSequence.asArray().count == sequence1.asArray().count)
    
    appendedSequence = emptyNumbers.asSequence().append(emptyNumbers.asSequence())
    XCTAssertTrue(appendedSequence.asArray().count == 0)
    
  }
  
  
  func testDelete() {
    
    XCTAssertFalse(numbers.asSequence().delete(1).any { $0 == 1} )
    
    XCTAssertFalse(numbers.asSequence().delete(5).any { $0 == 5} )
    
    XCTAssertFalse(numbers.asSequence().delete(9).any { $0 == 9} )
    
    XCTAssertTrue(numbers.asSequence().delete(12).asArray().count == numbers.count)

    XCTAssertTrue(emptyStrings.asSequence().delete("ABC").asArray().count == 0)
    XCTAssertTrue(emptyStrings.asSequence().delete("").asArray().count == 0)
    
  }
  
  
  func testDropLast() {
    
    XCTAssertTrue(numbers.count == 9)
    XCTAssertTrue(numbers.asSequence().droplast().asArray().count == 8)
    
    XCTAssertTrue(emptyStrings.asSequence().droplast().asArray().count == 0)
    
  }
  
  
  func testDropWhile() {
    
    let numbers = [4, 2, 5, 6, 1, 2, 3]
    
    XCTAssertTrue(numbers.asSequence().dropwhile( { $0 <= 5 } ).asArray().count == 4)
    
    XCTAssertTrue(numbers.asSequence().dropwhile( { $0 <= 3 } ).asArray().count == numbers.count)
    
    XCTAssertTrue(emptyStrings.asSequence().dropwhile( {$0 == "A"} ).asArray().count == 0)
    
  }
  
  
  func testDuplicateFunc() {
    
    let strings = SequenceOf.duplicate("ABC", times: 10)
    
    XCTAssertTrue(strings.asArray().count == 10)
    XCTAssertTrue(strings.all { $0 == "ABC"}  )
    
    let emptyStrings = SequenceOf.duplicate("DEF", times: 0)
    XCTAssertTrue(emptyStrings.asArray().count == 0)
    
  }
  
  
  func testDuplicateInit() {
    
    let strings = SequenceOf(count: 10, repeatedValue: "ABC")
    
    XCTAssertTrue(strings.asArray().count == 10)
    XCTAssertTrue(strings.all { $0 == "ABC"}  )
    
  }
  
  
  func testfilter() {
    
    XCTAssertEqual(numbers.asSequence().filter( { $0 % 2 == 0} ).asArray(), [2, 4, 6, 8])
    
    XCTAssertTrue(emptyStrings.asSequence().filter( { $0.isEmpty } ).asArray().count == 0)
    
  }
  
  
  func testFiltermap() {
    
    let evens: SequenceOf<String> = numbers.asSequence().filtermap {
      if $0 % 2 == 0 {
        return String($0)
      } else {
        return nil
      }
    }
    
    let reference = ["2", "4", "6", "8"]
    XCTAssertTrue(hasSameElements(evens, array: reference))
    
    let nothing = emptyStrings.asSequence().filtermap { String($0) }
    XCTAssertTrue(nothing.asArray().count == 0)
    
  }
  
  
  func testFoldl() {
    
    var add = false
    let sum = numbers.asSequence().foldl(0, function: {
      add = !add
      return add ? $0 + $1 : $0 - $1
    })
    
    XCTAssertTrue(sum == 5)
    
    let nothing = emptyNumbers.asSequence().foldl(0, { $0 + $1 })
    XCTAssertTrue(nothing == 0)
    
  }
  
  
  func testFoldr() {
    
    var add = false
    let sum = numbers.asSequence().foldr(0, function: {
      add = !add
      return add ? $0 + $1 : $0
    })
    
    XCTAssertTrue(sum == 25)
    
    let nothing = emptyNumbers.asSequence().foldr(0, { $0 + $1 })
    XCTAssertTrue(nothing == 0)
    
  }
  
  
  func testForeach() {
    
    var sum = 0
    numbers.asSequence().foreach { sum += Int($0) }
    XCTAssertTrue(sum == 45)
    
    emptyStrings.asSequence().foreach {
      println($0)
      XCTAssertTrue(false)
    }
    
  }
  
  
  func testLast() {
    
    XCTAssertTrue(numbers.asSequence().last() == 9)
    
    emptyStrings.asSequence().last() == nil ? XCTAssertTrue(true) : XCTAssertTrue(false)
  }
  
  
  func testFirst() {
    
    XCTAssertTrue(numbers.asSequence().first() == 1)
    
    emptyStrings.asSequence().first() == nil ? XCTAssertTrue(true) : XCTAssertTrue(true)
    
  }
  
  
  func testMap() {
    
    let strings = numbers.asSequence().map { String($0) }
    
    let reference = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    XCTAssertTrue(hasSameElements (strings, array: reference))
    
    XCTAssertTrue(emptyNumbers.asSequence().map( { String($0) } ).asArray().count == 0)
    
  }
  
  
  func testMapfoldr() {
    
    let (sequence: SequenceOf<Int>, accumulator: Int) = numbers.asSequence().mapfoldl(0, function: { (element, accumulator) in
      return (element * 2, accumulator + element)
    })
    
    XCTAssertTrue(accumulator == 45)
    for (index, number) in enumerate(sequence) {
      XCTAssertTrue(number == (index + 1) * 2)
    }
    
    var (s2: SequenceOf<Int>, a2: Int) = emptyNumbers.asSequence().mapfoldl(0, function: { (element, accumulator) in
      return (element * 2, accumulator + element)
    })
    
    XCTAssertTrue(a2 == 0)
    XCTAssertTrue(s2.asArray().count == 0)
    
  }
  
  
  func testMapfoldl() {
    
    let (sequence: SequenceOf<Int>, accumulator: Int) = numbers.asSequence().mapfoldl(0, function: { (element, accumulator) in
      return (element % 2 == 0 ? element * 2 : element, accumulator + element)
    })
    
    XCTAssertTrue(accumulator == 45)
    for (index, number) in enumerate(sequence) {
      XCTAssertTrue( number == ((index + 1) % 2 == 0 ? ((index + 1) * 2) : index + 1) )
    }
    
    var (s2: SequenceOf<Int>, a2: Int) = emptyNumbers.asSequence().mapfoldl(0, function: { (element, accumulator) in
      return (element * 2, accumulator + element)
    })
    
    XCTAssertTrue(a2 == 0)
    XCTAssertTrue(s2.asArray().count == 0)
    
  }

  
  func testMax() {
    
    XCTAssertTrue(numbers.asSequence().max() == 9)
    
    let max: Int? = emptyNumbers.asSequence().max()
    XCTAssertTrue(max == nil)
    
  }
  
  
  func testMin() {
    
    XCTAssertTrue(numbers.asSequence().min() == 1)
    
    let min: Int? = emptyNumbers.asSequence().min()
    XCTAssertTrue(min == nil)
    
  }
  
  
  func testMemeber() {
    
    XCTAssertTrue(numbers.asSequence().member(5))
    
    XCTAssertFalse(numbers.asSequence().member(20))
    
    XCTAssertFalse(emptyStrings.asSequence().member("AAA"))
    
  }
  
  
  func testMerge() {
    
    let evenNumbers = [2, 4, 6, 8]
    let oddNumbers = [1, 3, 5, 7, 9]
    
    var mergedNumbers = evenNumbers.asSequence().merge(oddNumbers.asSequence())
    
    XCTAssertTrue(mergedNumbers.asArray().count == 9)
    for (index, element) in enumerate(mergedNumbers) {
      XCTAssertTrue(element == index + 1)
    }
    
    let shortList = [2, 20]
    mergedNumbers = oddNumbers.asSequence().merge(shortList.asSequence())
    
    XCTAssertTrue(mergedNumbers.asArray().count == 7)
    let reference = [1, 2, 3, 5, 7, 9, 20]
    XCTAssertTrue(hasSameElements(mergedNumbers, array: reference))
    
    // TODO
  
  }
  
  
  func testNth() {
    
    XCTAssertTrue(numbers.asSequence().nth(0) == nil)
    XCTAssertTrue(numbers.asSequence().nth(1) == 1)
    XCTAssertTrue(numbers.asSequence().nth(8) == 8)
    XCTAssertTrue(numbers.asSequence().nth(10) == nil)
    
  }
  
  
  func testNthtail() {
    
    var tail = numbers.asSequence().nthtail(5)
    XCTAssertTrue(tail.asArray().count == 4)
    
    tail = numbers.asSequence().nthtail(12)
    XCTAssertTrue(tail.asArray().isEmpty)
    
  }
  
  
  func testPartition() {
    
    let evenNumbers = [2, 4, 6, 8]
    let oddNumbers = [1, 3, 5, 7, 9]
    
    var (even, odd) = numbers.asSequence().partition( {$0 % 2 == 0 } )
    
    XCTAssertTrue(even.asArray() == evenNumbers)
    XCTAssertTrue(odd.asArray() == oddNumbers)
    
  }
  
  
  func testIsPrefix() {
    
    let evenNumbers = [2, 4, 6, 8]
    let prefix = [1, 2, 3]
    
    XCTAssertTrue(numbers.asSequence().isPrefix(prefix.asSequence()))
    
    XCTAssertFalse(evenNumbers.asSequence().isPrefix(prefix.asSequence()))
    
    XCTAssertFalse(prefix.asSequence().isPrefix(numbers.asSequence()))
    
  }
  
  
  func testReverese() {
    
    let revesed = numbers.asSequence().reverse()
    for (index, number) in enumerate(revesed) {
      XCTAssertTrue(number == 9 - index)
    }
    
  }
  
  
  func testSplit() {
    
    let (left, right) = numbers.asSequence().split(5)
    XCTAssertTrue(left.asArray().count == 5)
    XCTAssertTrue(right.asArray().count == 4)
    
  }
  
  
  func testSplitwith() {
    
    let numbers = [2, 4, 2, 8, 1, 5, 2, 10, 4]
    
    let (left, right) = numbers.asSequence().splitwith( { $0 % 2 == 0} )
    XCTAssertTrue(left.asArray().count == 4)
    XCTAssertTrue(right.asArray().count == 5)
    
  }
  
  
  func testTakewhile() {
    
    XCTAssertTrue(numbers.asSequence().takewhile( {$0 < 5} ).asArray().count == 4);
    
  }
  
  
  func testUmerge() {
    
    let numbers1 = [1, 2, 3, 4]
    let numbers2 = [1, 4, 5, 6]
    
    let mergedNumbers = numbers1.asSequence().umerge(numbers2.asSequence())
    
    for (index, element) in enumerate(mergedNumbers) {
      println("index:\(index) element:\(element)")
      XCTAssertTrue(element == index + 1)
    }
    
  }
  
  
  func testUnzip() {
    
    let tuples = [(1, "a"), (2, "b"), (3, "c")]
    
    let tupleSeq = tuples.asSequence()
    // TODO Unsure why this is not workinf
    //let unzipped: (SequenceOf<Int>, SequenceOf<String>) = SequenceOf.unzip(tupleSeq)
    
  }
  
  
  func testZip() {
    
    let zipped = numbers.asSequence().zip(numbers.asSequence())
    
    for element in zipped {
      let (first, second) = element
      XCTAssertTrue(first == second)
    }
    
  }
  
  
  func testZip3() {
    
    let zipped = numbers.asSequence().zip3(numbers.asSequence(), thirdSequence:numbers.asSequence())

    for element in zipped {
      let (first, second, third) = element
      XCTAssert(first == second && second == third)
    }
    
  }
  
  
  func testZipWith() {
    
    let zipped = numbers.asSequence().zipWith( { $0 + $1 }, otherSequence: numbers.asSequence())
    
    for (i, element) in enumerate(zipped) {
      XCTAssert( element == (i + 1) + (i + 1) )
    }
    
  }
  
  
  func testZip3With() {
    
    let zipped = numbers.asSequence().zip3With( { $0 + $1 + $2 }, secondSequence: numbers.asSequence(), thirdSequence: numbers.asSequence())
    
    for (i, element) in enumerate(zipped) {
      XCTAssert( element == (i + 1) + (i + 1) + (i + 1) )
    }
    
  }
  
  
  private func hasSameElements<T: Equatable>(sequence: SequenceOf<T>, array: [T]) -> Bool {
    
    for (index, element) in enumerate(sequence) {
      if element != array[index] {
        return false
      }
    }
    
    return true
    
  }
  
  
}


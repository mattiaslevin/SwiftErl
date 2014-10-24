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
  let empty = [String]()
  
  
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
    
    XCTAssertTrue(empty.asSequence().all {$0 == "A"} )
    
  }
  
  
  func testAny() {
    
    XCTAssertTrue(numbers.asSequence().any {$0 == 5} )
    
    XCTAssertFalse(numbers.asSequence().any {$0 == 12} )
    XCTAssertFalse(numbers.asSequence().any {$0 == "A"} )
    
    XCTAssertFalse(empty.asSequence().any { $0 == "A"} )
    
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
    
    appendedSequence = sequence1.append([Int]().asSequence())
    XCTAssertTrue(appendedSequence.asArray().count == sequence1.asArray().count)
    
    appendedSequence = [Int]().asSequence().append(sequence1)
    XCTAssertTrue(appendedSequence.asArray().count == sequence1.asArray().count)
    
  }
  
  
  func testDelete() {
    
    var sequence1 = numbers.asSequence().delete(1)
    XCTAssertFalse(sequence1.any { $0 == 1} )
    
    sequence1 = numbers.asSequence().delete(5)
    XCTAssertFalse(sequence1.any { $0 == 5} )
    
    sequence1 = numbers.asSequence().delete(9)
    XCTAssertFalse(sequence1.any { $0 == 9} )
    
    sequence1 = numbers.asSequence().delete(12)
    XCTAssertTrue(sequence1.asArray().count == numbers.count)
    
    XCTAssertTrue(empty.asSequence().delete("").asArray().count == 0)
    
  }
  
  
  func testDropLast() {
    
    XCTAssertTrue(numbers.count == 9)
    XCTAssertTrue(numbers.asSequence().droplast().asArray().count == 8)
    
    XCTAssertTrue(empty.asSequence().droplast().asArray().count == 0)
    
  }
  
  
  func testDropWhile() {
    
    let numbers = [4, 2, 5, 6, 1, 2, 3]
    
    var numbers1 = numbers.asSequence().dropwhile { $0 <= 5 }
    XCTAssertTrue(numbers1.asArray().count == 4)
    
    numbers1 = numbers.asSequence().dropwhile { $0 <= 3 }
    XCTAssertTrue(numbers1.asArray().count == numbers.count)
    
  }
  
  
  // TODO For some reason the init method is not working
  //  func testDuplicate() {
  //
  //    let strings = SequenceOf.duplicate("ABC", times: 10)
  //
  //    var count = 0
  //    for string in strings {
  //      XCTAssertTrue(string == "ABC")
  //      count++
  //    }
  //
  //    XCTAssertTrue(count == 10)
  //
  //  }
  
  
  func testfilter() {
    
    let evens = numbers.asSequence().filter { $0 % 2 == 0}
    XCTAssertEqual(Array(evens), [2, 4, 6, 8])
    
    let emptySequence = empty.asSequence().filter { $0.isEmpty }
    XCTAssertTrue(emptySequence.asArray().count == 0)
    
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
    for (index, string) in enumerate(evens) {
      XCTAssertTrue(string == reference[index])
    }
    
  }
  
  
  func testFoldl() {
    
    var add = false
    let sum = numbers.asSequence().foldl(0, function: {
      add = !add
      return add ? $0 + $1 : $0 - $1
    })
    
    XCTAssertTrue(sum == 5)
    
  }
  
  
  func testFoldr() {
    
    var add = false
    let sum = numbers.asSequence().foldr(0, function: {
      add = !add
      return add ? $0 + $1 : $0 - $1
    })
    
    XCTAssertTrue(sum == 5)
    
  }
  
  
  func testForeach() {
    
    var sum = 0
    numbers.asSequence().foreach( { sum += Int($0) } )
    XCTAssertTrue(sum == 45)
    
  }
  
  
  func testLast() {
    
    XCTAssertTrue(numbers.asSequence().last() == 9)
    
    if let last = empty.asSequence().last() {
      XCTAssertTrue(false)
    } else {
      XCTAssertTrue(true)
    }
    
  }
  
  
  func testFirst() {
    
    XCTAssertTrue(numbers.asSequence().first() == 1)
    
    if let last = empty.asSequence().first() {
      XCTAssertTrue(false)
    } else {
      XCTAssertTrue(true)
    }
    
  }
  
  func testMap() {
    
    let strings = numbers.asSequence().map { String($0) }
    
    let reference = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    for (index, string) in enumerate(strings) {
      XCTAssertTrue(string == reference[index])
    }
    
  }
  
  
  func testMapfoldr() {
    
    var (sequence: SequenceOf<Int>, accumulator: Int) = numbers.asSequence().mapfoldl(0, function: { (element, accumulator) in
      return (element * 2, accumulator + element)
    })
    
    XCTAssertTrue(accumulator == 45)
    for (index, number) in enumerate(sequence) {
      XCTAssertTrue(number == (index + 1) * 2)
    }
    
  }
  
  
  func testMax() {
    
    XCTAssertTrue(numbers.asSequence().max() == 9)
    
    let max: Int? = empty.asSequence().max()
    XCTAssertTrue(max == nil)
    
    
  }
  
  
  func testMin() {
    
    XCTAssertTrue(numbers.asSequence().min() == 1)
    
    let min: Int? = empty.asSequence().min()
    XCTAssertTrue(min == nil)
    
  }
  
  
  func testMemeber() {
    
    XCTAssertTrue(numbers.asSequence().member(5))
    
    XCTAssertFalse(numbers.asSequence().member(20))
    
    XCTAssertFalse(empty.asSequence().member("AAA"))
    
  }
  
  
  func testMerge() {
    
    let evenNumbers = [2, 4, 6, 8]
    let oddNumbers = [1, 3, 5, 7, 9]
    
    let mergedNumbers = evenNumbers.asSequence().merge(oddNumbers.asSequence())
    
    for (index, element) in enumerate(mergedNumbers) {
      XCTAssertTrue(element == index + 1)
    }
    
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
  
  
  
  
}


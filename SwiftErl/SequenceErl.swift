//
//  SequenceErl.swift
//  SwiftErl
//
//  Created by Mattias Levin on 22/10/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

import Foundation


public extension SequenceOf {
  
  /**
   Check if predicate returns true for all elements in the sequence.
  
   :param: predicate function to call for each element
   :returns: true if predicate returns true for all elements in the sequence
  */
  func all(predicate: T -> Bool) -> Bool {
    
    for element in self {
      if !predicate(element) {
        return false
      }
    }
    
    return true
    
  }
  
  
  /**
   Check if predicate returnes true for any of the elements in the sequence.
  
   :param: predicate function to call for each element
   :returns: true if predicate return true for any of the elements in the sequence.
  */
  public func any(predicate: T -> Bool) -> Bool {
    
    for element in self {
      if predicate(element) {
        return true
      }
    }
    
    return false
    
  }
  
  
  /**
   Create a new sequence made from the current sequence followed by the provided sequence.
  
   :param: sequence sequence appended to the current sequence
   :returns: a new sequence made from the current sequence followed by the provided sequence
  */
  public func append(sequence: SequenceOf<T>) -> SequenceOf<T> {
    var thisGenerator = generate()
    var otherGenerator = sequence.generate()
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      if let next = thisGenerator.next() {
        return next
      } else {
        return otherGenerator.next()
      }
      
    })
    
  }
  
  
  /**
   Create a new sequence with the first element matching element deleted, if there is such an element.
  
   :param: element element to delete
   :returns: a new sequence with the first element matching element deleted, if there is such an element
  */
  public func delete<T: Equatable>(element: T) -> SequenceOf<T> {
    var generator = generate()
    var isFinished = false
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      var next = generator.next()
      if !isFinished {
        if let unwrapped = next as? T {
          
          if unwrapped == element {
            isFinished = true
            next = generator.next()
          }
          
        }
      }
      
      return next as? T
      
    })
    
  }
  
  
  /**
   Drop the last element in the sequence.
  
   :returns: a new sequence with the last element removed
  */
  public func droplast() -> SequenceOf<T> {
    var generator = generate()
    var next = generator.next()
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      if next != nil {
        
        let ahead = generator.next()
        if ahead != nil {
          let temp = next
          next = ahead
          return temp
        } else {
          return nil
        }
        
      } else {
        return nil
      }
      
    })
    
  }
  
  
  /**
   Drop elements from the sequence as long as the predicate returns true and return the remaining sequence.
  
   :param: predicate function to call for each element
   :returns: a new sequence containing the remaing elements
  */
  public func dropwhile(predicate: T -> Bool) -> SequenceOf<T> {
    var generator = generate()
    var finished = false
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      var next = generator.next()
      if !finished {
        while let unwrapped = next {
          
          if predicate(unwrapped) {
            next = generator.next()
          } else {
            finished = true
            break
          }
          
        }
      }
      
      return next
      
    })
    
  }
  
  
  /**
   Create a new sequence containing count copies of repeatedValue.
  
   :param: count the number of copies to create
   :param: repeatedValue the value to repeat
   :returns: a new sequence containing count copies of repeatedValue
  */
  public init(count: Int, repeatedValue: T) {
    var index = 0
    
    self.init(GeneratorOf<T> {
      
      if index < count {
        index++
        return repeatedValue
      } else {
        return nil
      }
      
    })
    
  }
  
  
  /**
   Create a new sequence containing times copies of elemet.
  
   :param: element the value to repeat
   :param: times the number of copies
   :returns: a new sequence containing times copies of elemet.
  */
  public static func duplicate(element: T, times: Int) -> SequenceOf<T> {
    return SequenceOf<T>(count: times, repeatedValue: element)
  }
  
  
  /**
   Create a new sequence containing all elemenets for which predicate returns true.
  
   :param: predicate function to call for each element
   :returns: a new sequence containing all elemenets for which predicate returns true
  */
  public func filter(predicate: T -> Bool) -> SequenceOf<T> {
    var generator = generate()
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      var next = generator.next()
      while let unwrapped = next {
        
        if predicate(unwrapped) {
          break
        } else {
          next = generator.next()
        }
        
      }
      
      return next
      
    })
    
  }
  
  
  /**
   Create a new sequence containing elements for which function return a new mapped value.
   This method is the same as first filtering a sequence then applying a map function to the filtered sequence combined in one single method.
  
   :param: function function to call for each element
   :returns: new sequence containing elements for which function return a new mapped value
  */
  public func filtermap<U>(function: T -> U?) -> SequenceOf<U> {
    var generator = generate()
    
    return SequenceOf<U>(GeneratorOf<U> {
      
      while let unwrapped = generator.next() {
        if let result = function(unwrapped) {
          return result
        }
      }
      
      return nil
      
    })
    
  }
  
  
  // TODO flatten, flatmap?
  
  
  /**
   Accumulates a sinlge value by calling function for each element in the sequence from left to right.
   
   function must return a new accumulator which is passed to the next call. The function returns the final value of the accumulator.
   The initial accumulator value is returned if the list is empty.
  
   :param: initial initial accumulator value
   :param: function functions to call for each element, must return a new accumulator
   :returns: the final value of the accumulator
  */
  public func foldl<V>(initial: V, function: (accumulator: V, element: T) -> V) -> V {
    
    var acc = initial
    for element in self {
      acc = function(accumulator: acc, element: element)
    }
    
    return acc
  }
  
  
  /**
   Accumulates a sinlge value by calling function for each element in the sequence from right to left.
  
   function must return a new accumulator which is passed to the next call. The function returns the final value of the accumulator.
   The initial accumulator value is returned if the list is empty.
  
   :param: initial initial accumulator value
   :param: function functions to call for each element, must return a new accumulator
   :returns: the final value of the accumulator
  */
  public func foldr<V>(initial: V, function: (accumulator: V, element: T) -> V) -> V {
    return reverse().foldl(initial, function: function)
  }
  
  
  /**
   Calls function for each element in the sequence. This method is used for its side effects.
  
   :param: function function to call for each element
  */
  public func foreach(function: T -> ()) {
    
    for element in self {
      function(element)
    }
    
  }
  
  
  /**
   Get the last element in the sequence.
  
   :returns: the last element in the sequence
  */
  public func last() -> T? {
    var generator = generate()
    
    var next = generator.next()
    while next != nil {
      
      let ahead = generator.next()
      if ahead != nil {
        next = ahead
      } else {
        break
      }
      
    }
    
    return next
  }
  
  
  /**
   Get the first element in the sequence.
   
   :returns: the first element in the sequence
  */
  public func first() -> T? {
    var generator = generate()
    return generator.next()
  }
  
  
  /**
   Create a new sequence by applying function to each element in the sequence.
   
   :param: function function to call for each element
   :returns: a new sequence by applying function to each element in the sequence
  */
  public func map<U>(function: T -> U) -> SequenceOf<U> {
    var generator = generate()
    
    return SequenceOf<U>(GeneratorOf<U> {
      
      let next = generator.next()
      if let unwrapped = next {
        return function(unwrapped)
      } else {
        return nil
      }
    
    })
    
  }
  
  
  /**
   Combines the operation of map and foldl into one pass (saving one pass over the sequence).
  
   :param: initial accumulator value
   :param: function function to call for each element. Must return a tuple of the mapped value and the new accumulator
   :returns: a tuple containing the mapped sequence and the accumulator
  */
  public func mapfoldl<U, V>(initial: V, function: (element: T, accumulator: V) -> (element: U, accumulator: V)) -> (sequence: SequenceOf<U>, accumulator: V) {
    var generator = generate()
    
    var acc = initial
    var mappedValues = [U]()
    while let next = generator.next() {
      let (mappedValue, updatedAcc) = function(element: next, accumulator: acc)
      mappedValues.append(mappedValue)
      acc = updatedAcc
    }
    
    return (mappedValues.asSequence(), acc)
    
  }
  
  
  /**
   Combines the operation of map and foldl into one pass (saving one pass over the sequence).
  
   :param: initial accumulator value
   :param: function function to call for each element. Must return a tuple of the mapped value and the new accumulator
   :returns: a tuple containing the mapped sequence and the accumulator
  */
  public func mapfoldr<U, V>(initial: V, function: (element: T, accumulator: V) -> (element: U, accumulator: V)) -> (sequence: SequenceOf<U>, accumulator: V) {
    return reverse().mapfoldl(initial, function: function)
  }
  
  
  /**
   Returns the maximum element in the sequence.
  
   :returns: the maximum element
  */
  public func max<U: Comparable>() -> U? {
    var generator = generate()
    
    var max = generator.next() as U?
    if max == nil {
      return nil
    }
    
    while let next = generator.next() as U? {
      if next > max {
        max = next
      }
    }
    
    return max
    
  }
  
  
  /**
   Find out if the element is a member of the sequence.
  
   :param: element the element to look for
   :returns: true if the element exists in the sequence
  */
  public func member<T: Equatable>(element: T) -> Bool {
    var generator = generate()
    
    while let next = generator.next() as? T {
      if next == element {
        return true
      }
    }
    
    return false
    
  }
  
  
  /**
  Create a new sorted sequence by merging the provided sequence. Both sequences must be sorted prior to calling this method.
  
  :param: sequence the sequence to merge
  :returns: a merged sorted sequence
  */
  public func merge<T: Comparable>(sequence: SequenceOf<T>) -> SequenceOf<T> {
    return merge(sequence, asUniqueMerge:false)
  }
  
  
  // merge3
  public func merge3<T: Comparable>(secondSequence: SequenceOf<T>, thirdSequence: SequenceOf<T>) -> SequenceOf<T> {
    var thisGenerator = generate()
    var secondGenerator = secondSequence.generate()
    var thirdGenerator = thirdSequence.generate()
    
    var pendingThis: T?
    var pendingSecond: T?
    var pendingThird: T?
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      if pendingThis == nil {
        pendingThis = thisGenerator.next() as? T
      }
      if pendingSecond == nil {
        pendingSecond = secondGenerator.next()
      }
      if pendingThis == nil {
        pendingThird = thirdGenerator.next()
      }
      
      if pendingThis != nil && pendingThis < pendingSecond {
        
        if (pendingThis < pendingThird) {
          pendingThis = nil
          return pendingThis!
        } else {
          pendingThird = nil
          return pendingThird!
        }
        
      } else if pendingSecond != nil && pendingSecond < pendingThird {
        pendingSecond = nil
        return pendingSecond!
      } else {
        pendingThird = nil
        return pendingThird!
      }
      
    })
    
  }
  
  
  /**
   Returns the minimum element in the sequence.
  
   :returns: the minimum element
  */
  public func min<U: Comparable>() -> U? {
    var generator = generate()
    
    var min = generator.next() as U?
    if min == nil {
      return nil
    }
    
    while let next = generator.next() as U? {
      if next < min {
        min = next
      }
    }
    
    return min
    
  }
  
  
  // TODO Zero or One based sequences? Check all methods below
  
  /**
   Returns the nth element of the sequence.
  
   :param: n the position of the element to return (first element starts at 1)
   :returns: nth element of the sequence
  */
  public func nth(n: Int) -> T? {
    
    if n <= 0 {
      return nil
    }
    
    var generator = generate()
    var currentIndex = 1
    
    while let next = generator.next() {
      if currentIndex == n {
        return next
      }
      currentIndex++
    }
    
    return nil
    
  }
  
  
  /**
   Return a new sequence starting at nth + 1 and continue until the end of the sequence.
   
   :param: n the number of elements to skip
   :returns: new sequence starting at nth + 1 until the end of the sequence.
  */
  public func nthtail(n: Int) -> SequenceOf<T> {
    var generator = generate()
    var found = false
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      if n <= 0 {
        return nil
      }
      
      if found {
        return generator.next()
      } else {
        
        var currentIndex = 1
        while let next = generator.next() {
          if currentIndex == n + 1 {
            found = true
            return next
          }
          currentIndex++
        }
        
      }
      
      return nil
      
    })
    
  }
  
  
  /**
   Partition the sequence into two sequences. The first sequence will contain all elements for which predicate returns true and the second sequence will contain all elements for which predicate returns false.
  
   :param: predicate
   :returns: a tuple with two sequences. The first sequence will contain all elements for which predicate returns true and the second sequence will contain all elements for which predicate returns false.
  */
  public func partition(predicate: T -> Bool) -> (SequenceOf<T>, SequenceOf<T>) {
    return (filter({ predicate($0) }), filter({ !predicate($0) }))
  }
  
  
  /**
   Returns true if the provided sequence is a prefix of the current sequence.
  
   :params: sequence the prefix sequence
   :returns: true if the provided sequence is a prefix of the current sequence. Otherwise false
  */
  public func isPrefix<T: Equatable>(sequence: SequenceOf<T>) -> Bool {
    var thisGenerator = generate()
    var otherGenerator = sequence.generate()
    
    while let otherNext = otherGenerator.next() {
      if let thisNext = thisGenerator.next() as? T {
        if otherNext != thisNext {
          return false
        }
      } else {
        return false
      }
    }
    
    return true
    
  }
  
  
  /**
   Create a new reversed sequence.
  
   :returns: a reversed sequence
  */
  public func reverse() -> SequenceOf<T> {
    var generator = generate()
    var hasSequenceBeenReversed = false
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      if !hasSequenceBeenReversed {
        generator = Array(self).reverse().asSequence().generate()
        hasSequenceBeenReversed = true
      }
      
      return generator.next()
      
    })
    
  }
  
  
  /**
   Split the sequence into two sequences. The first sequence contains the n first elements of the sequence and the second list contains the rest of the elements.
  
   :param: n the number elements in the first sequence
   :returns: the first sequence contains the n first elements of the sequence and the second sequence contains the rest of the elements
  */
  public func split(n: Int) -> (SequenceOf<T>, SequenceOf<T>) {
    return (subsequence(n), nthtail(n))
  }
  
  
  /**
   Split the sequence in two sequences. The first sequence will contain all elements from the start of the sequence as long as the predicate returns true. The second sequence will contain the remaining elements.
  
   :param: predicate function to call for each element
   :returns: The first sequence will contain all elements from the start of the sequence as long as the predicate returns true. The second sequence will contain the remaining elements.
  */
  public func splitwith(predicate: T -> Bool) -> (SequenceOf<T>, SequenceOf<T>) {
    return (takewhile(predicate), dropwhile(predicate))
  }
  
  
  /**
   Return a new sequence starting at the first element and with (max) lenght elements.
  
   :param: length lenght of the new subsequence
   :returns: a new sequence starting at the first element and with (max) lenght elements
  */
  public func subsequence(lenght: Int) -> SequenceOf<T> {
    var generator = generate()
    var currentIndex = 0
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      if currentIndex == lenght {
        return nil
      } else {
        currentIndex++
        return generator.next()
      }
      
    })
    
  }
  
  
  /**
   Return a new sequence starting at the provided index and with (max) lenght elements.
  
   :param: start the start of the new sequence
   :param: lenght lenght of the new sequence
   :returns: a new sequence starting at the provided index and with (max) lenght elements
  */
  public func subsequence(start: Int, lenght: Int) -> SequenceOf<T> {
    return nthtail(start).subsequence(lenght)
  }
  
  
  // TODO subtract
  
  
  /**
   Return true if the provided sequence is a suffix of the sequence.
  
   :param: sequence
   :returns: true of the provided sequence is a suffix of the sequence
  */
  public func isSuffix<T: Equatable>(sequence: SequenceOf<T>) -> Bool {
    return reverse().isPrefix(sequence.reverse())
  }
  
  
  // TODO sum
  // There is currently no good way to implement this
  // There is no similar protocol like Equatable for adding numbers
  
  
  /**
   Return a new sequence containing elements from the start of the sequence as long as the predicate returns true.
  
   :param: predicate function to call for each element
   :returna: a new sequence containing elements from the start of the sequence as long as the predicate returns true.
  */
  public func takewhile(predicate: T -> Bool) -> SequenceOf<T> {
    var generator = generate()
    var isDone = false
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      if (isDone) {
        return nil
      } else {
        
        if let next = generator.next() {
          if predicate(next) {
            return next
          } else {
            isDone = true
            return nil
          }
        } else {
          isDone = true
          return nil
        }
        
      }
      
    })
    
  }
  
  
  /**
   Unqiue merge. Return the sorted sequence by mergin the current sequence with the provided sequence. All sequences must be sorted and contain no duplicates. When two element compare equal, the element from the current sequence will be picked.
  
   :param: sequence the sequence to merge with
   :returns: merged sorted sequence with unique elements
  */
  public func umerge<U: Comparable>(sequence: SequenceOf<U>) -> SequenceOf<U> {
    return merge(sequence, asUniqueMerge:true)
  }
  
  internal func merge<U: Comparable>(sequence: SequenceOf<U>, asUniqueMerge: Bool) -> SequenceOf<U> {
    var thisGenerator = generate()
    var otherGenerator = sequence.generate()
    
    var pending: (element: U?, isFromThisSequence: Bool) = (nil, true)
    
    return SequenceOf<U>(GeneratorOf<U> {
      
      var thisElement: U?
      var otherElement: U?
      
      if let pendingElement = pending.element {
        
        if pending.isFromThisSequence {
          thisElement = pendingElement
          otherElement = otherGenerator.next()
        } else {
          thisElement = thisGenerator.next() as U?
          otherElement = pendingElement
        }
        
      } else {
        thisElement = thisGenerator.next() as U?
        otherElement = otherGenerator.next()
      }
      
      println("this:\(thisElement) other:\(otherElement)")
      
      if thisElement == nil && otherElement == nil {
        return nil
      } else if thisElement == nil {
        pending.element = nil
        return otherElement
      } else if otherElement == nil {
        pending.element = nil
        return thisElement
      } else {
        
        if thisElement == otherElement {
          pending = asUniqueMerge ? (nil, false) : (otherElement, false)
          return thisElement
        } else if thisElement > otherElement {
          pending = (thisElement, true)
          return otherElement
        } else {
          pending = (otherElement, false)
          return thisElement
        }
        
      }
      
    })
    
  }

  
  /**
   Unzip a sequence of two-tuples into two separate sequences, where the the first sequence contains the first element of each tuple and the second sequence contains the second element of each tuple.
  
   :returns: Tuple with two sequences
  */
  // TODO Looks good but not possible to call
  static public func unzip<U, V>(sequence: SequenceOf<(U, V)>) -> (SequenceOf<U>, SequenceOf<V>) {
    var firstGenerator = sequence.generate()
    var secondGenerator = sequence.generate()

    let firstSequence = SequenceOf<U>(GeneratorOf<U> {
      if let (first, _) = firstGenerator.next() {
        return first
      } else {
        return nil
      }
    })
    
    let secondSequence = SequenceOf<V>(GeneratorOf<V> {
      if let (_, second) = secondGenerator.next() {
        return second
      } else {
        return nil
      }
    })
    
    return (firstSequence, secondSequence)
  }
  
  
  // unzip3
  // TODO Wait with implementation until unzip works
  
  
  // usort? (unique sort)
  // Maybe not applicable to sequences
  
  
  /**
   Zip two sequences of equal length into a sequence of two-tuples, where the first element in tuple is taken from the current sequence and the second element is taken from the provided sequence.
   As soon as one of the sequences run out of elements the zipping will stop.
  
   :param: otherSequence a sequence to zip with
   :returns: a sequence of two-tuples
  */
  public func zip<U>(otherSequence: SequenceOf<U>) -> SequenceOf<(T, U)> {
    var thisGenerator = generate()
    var otherGenerator = otherSequence.generate()

    return SequenceOf<(T, U)>(GeneratorOf<(T, U)> {
      
      let thisElement = thisGenerator.next()
      let otherElement = otherGenerator.next()
      
      if thisElement == nil || otherElement == nil {
        return nil
      } else {
        return (thisElement!, otherElement!)
      }
      
    })
    
  }

  
  /**
   Zip three sequences of equal lenght into a sequence of three-tuples.
   As soon as one of the sequences run out of elements the zipping will stop.
  
   :param: secondSequence a sequence to zip with
   :param: thridSequence a sequence to zip with
   :returns: a sequence of three-tuples
  */
  public func zip3<U, V>(secondSequence: SequenceOf<U>, thirdSequence: SequenceOf<V>) -> SequenceOf<(T, U, V)> {
    var thisGenerator = generate()
    var secondGenerator = secondSequence.generate()
    var thirdGenerator = thirdSequence.generate()
    
    return SequenceOf<(T, U, V)>(GeneratorOf<(T, U, V)> {
      
      let thisElement = thisGenerator.next()
      let secondElement = secondGenerator.next()
      let thirdElement = thirdGenerator.next()
      
      if thisElement == nil || secondElement == nil || thirdElement == nil {
        return nil
      } else {
        return (thisElement!, secondElement!, thirdElement!)
      }
      
    })
    
  }
  
  
  /**
   Combine the elements of two sequences of equal length into one single sequence.
  
   :param: combine combine each pair of elements to a single element
   :returns: sequence of combined elements
  */
  public func zipWith<U, V>(combine: (T, U) -> V, otherSequence: SequenceOf<U>) -> SequenceOf<V> {
    var thisGenerator = generate()
    var otherGenerator = otherSequence.generate()

    return SequenceOf<V>(GeneratorOf<V> {
      
      let thisElement = thisGenerator.next()
      let otherElement = otherGenerator.next()

      if thisElement == nil || otherElement == nil {
        return nil
      } else {
        return combine(thisElement!, otherElement!)
      }
      
    })
    
  }
  
  
  /**
  Combine the elements of three sequences of equal length into one single sequence.
  
  :param: combine combine each tripple of elements to a single element
  :returns: sequence of combined elements
  */
  public func zip3With<S, U, V>(combine: (T, U, V) -> S, secondSequence: SequenceOf<U>, thirdSequence: SequenceOf<V>) -> SequenceOf<S> {
    var thisGenerator = generate()
    var secondGenerator = secondSequence.generate()
    var thirdGenerator = thirdSequence.generate()
    
    return SequenceOf<S>(GeneratorOf<S> {
      
      let thisElement = thisGenerator.next()
      let secondElement = secondGenerator.next()
      let thirdElement = thirdGenerator.next()
      
      if thisElement == nil || secondElement == nil || thirdElement == nil {
        return nil
      } else {
        return combine(thisElement!, secondElement!, thirdElement!)
      }
      
    })
    
  }
  
  
  /**
   Convert the sequence to an array.
   
   @return an array representation of the sequence
  */
  public func asArray() -> [T] {
    return Array(self)
    
  }
  
  
}
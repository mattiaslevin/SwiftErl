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
    var startAppending = false
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      var next: T?
      if !startAppending {
        next = thisGenerator.next()
        if next == nil {
          startAppending = true
          next = otherGenerator.next()
        }
      } else {
        next = otherGenerator.next()
      }
      
      return next
      
    })
    
  }
  
  
  /**
   Create a new sequence with the first element matching element deleted, if there is such an element.
  
   :param: element element to delete
   :returns: a new sequence with the first element matching element deleted, if there is such an element
  */
  public func delete<E: Equatable>(element: E) -> SequenceOf<T> {
    var generator = generate()
    var isFinished = false
    
    return SequenceOf<T>(GeneratorOf<T> {
      
      var next = generator.next()
      if !isFinished {
        if let unwrapped = next as? E {
          
          if unwrapped == element {
            isFinished = true
            next = generator.next()
          }
          
        }
      }
      
      return next
      
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
   This method is the same as first filering a sequence then applying a map function to the filtered sequence combines in one single method.
  
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
  
  
  // flatten, flatmap?
  
  
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
  public func member<E: Equatable>(element: E) -> Bool {
    var generator = generate()
    
    while let next = generator.next() as? E {
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
  public func merge<U: Comparable>(sequence: SequenceOf<U>) -> SequenceOf<U> {
    
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
      
      if thisElement == nil && otherElement == nil {
        return nil
      } else if thisElement == nil {
        pending.element = nil
        return otherElement
      } else if otherElement == nil {
        pending.element = nil
        return thisElement
      } else {
        
        if thisElement > otherElement {
          pending = (otherElement, false)
          return thisElement
        } else {
          pending = (thisElement, true)
          return otherElement
        }
        
      }
      
    })
    
  }
  
  
  // merge3
  
  
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
  public func isPrefix<U: Equatable>(sequence: SequenceOf<U>) -> Bool {
    var thisGenerator = generate()
    var otherGenerator = sequence.generate()
    
    while let otherNext = otherGenerator.next() {
      if let thisNext = thisGenerator.next() as? U {
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
  public func isSuffix<E: Equatable>(sequence: SequenceOf<E>) -> Bool {
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
  
  
  // unmerge
  
  // unzip
  
  // unzip3
  
  // unsort?
  
  // zip
  
  // zip3
  
  // zipwith
  
  // zipwith3
  
  
  /**
   Convert the sequence to an array.
   
   @return an array representation of the sequence
  */
  public func asArray() -> [T] {
    return Array(self)
    
  }
  
  
}
//
//  ArrayErl.swift
//  SwiftErl
//
//  Created by Mattias Levin on 22/10/14.
//  Copyright (c) 2014 Mattias Levin. All rights reserved.
//

import Foundation


extension Array {
  
  /**
   Convenient way to turn an array into a sequence.
  
   :returns: a sequence based on the array
  */
  public func asSequence() -> SequenceOf<T> {
    return SequenceOf<T>(self)
  }
  
  
}

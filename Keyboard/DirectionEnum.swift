//
//  Direction.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/19/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

enum Direction: Int, CustomStringConvertible
{
    case Left = 0
    case Down = 3
    case Right = 2
    case Up = 1
    
    var description: String
    {
        get
        {
            switch self
            {
            case Direction.Left:
                return "Left"
            case Direction.Right:
                return "Right"
            case Direction.Up:
                return "Up"
            case Direction.Down:
                return "Down"
            }
        }
    }
    
    func clockwise() -> Direction
    {
        switch self
        {
        case Direction.Left:
            return Direction.Up
        case Direction.Right:
            return Direction.Down
        case Direction.Up:
            return Direction.Right
        case Direction.Down:
            return Direction.Left
        }
    }
    
    func counterclockwise() -> Direction
    {
        switch self
        {
        case Direction.Left:
            return Direction.Down
        case Direction.Right:
            return Direction.Up
        case Direction.Up:
            return Direction.Left
        case Direction.Down:
            return Direction.Right
        }
    }
    
    func opposite() -> Direction
    {
        switch self
        {
        case Direction.Left:
            return Direction.Right
        case Direction.Right:
            return Direction.Left
        case Direction.Up:
            return Direction.Down
        case Direction.Down:
            return Direction.Up
        }
    }
    
    func horizontal() -> Bool
    {
        switch self
        {
        case
        Direction.Left,
        Direction.Right:
            return true
        default:
            return false
        }
    }
}

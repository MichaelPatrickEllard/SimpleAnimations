//
//  CardView.swift
//  SimpleAnimation
//
//  Created by Michael Patrick Ellard on 5/28/12.
//  Copyright (c) 2012 Michael Patrick Ellard. All rights reserved.
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/ or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.


class CardView: UILabel
{
    var homeCenter: CGPoint
    
    required init?(coder aDecoder: NSCoder) {
        
        homeCenter = CGPoint()  // A temporary hack until the rest of the classes are converted to Swift
        
        super.init(coder: aDecoder)
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 3.0
        self.layer.cornerRadius = 15.0
    }
}

//
//  Font.swift
//  Aux
//
//  Created by Sai Kambampati on 5/5/22.
//

import SwiftUI

extension Text {
    func titleOne() -> Text {
        self
            .font(.custom("FoundersGrotesk-Bold", size: 34))
            .accessibilityHeading(.h1)
    }
    
    func titleTwo() -> Text {
        self
            .font(.custom("FoundersGrotesk-Bold", size: 24))
            .accessibilityHeading(.h2)
    }
    
    func titleThree() -> Text {
        self
            .font(.custom("FoundersGrotesk-Semibold", size: 20))
            .accessibilityHeading(.h3)
    }
    
    func titleFour() -> Text {
        self
            .font(.custom("FoundersGrotesk-Semibold", size: 20))
            .accessibilityHeading(.h4)
    }
    
    func titleFive() -> Text {
        self
            .font(.custom("FoundersGrotesk-Medium", size: 20))
            .accessibilityHeading(.h4)
    }
    
    func button() -> Text {
        self
            .font(.custom("FoundersGrotesk-Bold", size: 20))
            .accessibilityHeading(.h4)
    }
    
    func headline() -> Text {
        self
            .font(.custom("FoundersGrotesk-Semibold", size: 17))
            .accessibilityHeading(.h5)
    }
    
    func body() -> Text {
        self
            .font(.custom("FoundersGrotesk-Regular", size: 17))
            .accessibilityHeading(.h5)
    }
    
    func caption() -> Text {
        self
            .font(.custom("FoundersGrotesk-Medium", size: 15))
            .accessibilityHeading(.h6)
    }
    
    func caption2() -> Text {
        self
            .font(.custom("FoundersGrotesk-Medium", size: 13))
            .accessibilityHeading(.h6)
    }
}

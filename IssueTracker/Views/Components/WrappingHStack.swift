//
//  WrappingHStack.swift
//  IssueTracker
//
//  Created by Tino on 22/3/2023.
//

import SwiftUI

struct WrappingHStack: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let layoutWidth = proposal.replacingUnspecifiedDimensions().width
        var sizes = [CGSize]()
        subviews.forEach { subview in
            sizes.append(subview.sizeThatFits(proposal))
        }
        var currentPoint = CGPoint.zero
        var maxX = 0.0
        var lineHeight = 0.0
        var horizontalSpaces = [Double]()
        var verticalSpaces = [Double]()
        
        for (i, subview) in subviews.enumerated() where i < subviews.count - 1 {
            let horizontalSpace = subview.spacing.distance(to: subviews[i + 1].spacing, along: .horizontal)
            let verticalSpace = subview.spacing.distance(to: subviews[i + 1].spacing, along: .vertical)
            horizontalSpaces.append(horizontalSpace)
            verticalSpaces.append(verticalSpace)
        }
        horizontalSpaces.append(0)
        verticalSpaces.append(0)
        
        for (i, size) in sizes.enumerated() {
            if currentPoint.x + size.width + horizontalSpaces[i] > layoutWidth {
                currentPoint.y += size.height + verticalSpaces[i]
                currentPoint.x = 0
                lineHeight = 0
            }
            currentPoint.x += size.width + horizontalSpaces[i]
            maxX = max(maxX, currentPoint.x)
            lineHeight = max(lineHeight, size.height)
        }
        
        return CGSize(width: maxX, height: currentPoint.y + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var point = bounds.origin
        
        for (i, subview) in subviews.enumerated() where i < subviews.count - 1 {
            let viewWidth = subview.sizeThatFits(proposal).width
            let viewHeight = subview.sizeThatFits(proposal).height
            let horizontalSpacing = subview.spacing.distance(to: subviews[i + 1].spacing, along: .horizontal)
            let verticalSpacing = subview.spacing.distance(to: subviews[i + 1].spacing, along: .vertical)
            
            subview.place(at: point, proposal: proposal)
            
            if point.x + viewWidth + horizontalSpacing > maxWidth {
                point.y += viewHeight + verticalSpacing
                point.x = bounds.origin.x
            } else {
                point.x += viewWidth + horizontalSpacing
            }
        }
        guard let lastSubview = subviews.last else {
            return
        }
        lastSubview.place(at: point, proposal: proposal)
    }
}

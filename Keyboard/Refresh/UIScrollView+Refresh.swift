//
//  UIScrollView+Refresh.swift
//  RefreshExample
//
//  Created by SunSet on 14-6-24.
//  Copyright (c) 2014 zhaokaiyuan. All rights reserved.
//

import UIKit



extension UIScrollView {
    func addHeaderWithCallback(_ callback: (() -> Void)!){
        let header: RefreshHeaderView = RefreshHeaderView.footer()
        self.addSubview(header)
        header.beginRefreshingCallback = callback
        header.addState(RefreshState.Normal)
    }
    
    func removeHeader()
    {
        
        for view in self.subviews{
            if let header = view as? RefreshHeaderView {
                header.removeFromSuperview()
            }
        }
    }
    
    func headerBeginRefreshing()
    {
        
        for object in self.subviews{
            if let header = object as? RefreshHeaderView {
                header.beginRefreshing()
            }
        }
        
    }
    
    
    func headerEndRefreshing()
    {
        for object in self.subviews{
            if let header = object as? RefreshHeaderView {
                header.endRefreshing()
            }
        }
        
    }
    
    func setHeaderHidden(_ hidden: Bool)
    {
        for object in self.subviews{
            if let header = object as? RefreshHeaderView {
                header.isHidden = hidden
            }
        }
        
    }
    
    func isHeaderHidden() -> Bool
    {
        for object in self.subviews{
            if let header = object as? RefreshHeaderView {
                return header.isHidden
            }
        }
        return false
    }
    
   func addFooterWithCallback(_ callback: (() -> Void)!){
        let footer: RefreshFooterView = RefreshFooterView.footer()
      
        self.addSubview(footer)
        footer.beginRefreshingCallback = callback
        
        footer.addState(RefreshState.Normal)
    }
    
    
     func removeFooter()
    {
    
        for view in self.subviews{
            if let footer = view as? RefreshFooterView {
                footer.removeFromSuperview()
            }
        }
    }
    
    func footerBeginRefreshing()
    {
        for object in self.subviews{
            if let footer = object as? RefreshFooterView {
                footer.beginRefreshing()
            }
        }
        
    }

    
    func footerEndRefreshing()
    {
        for object in self.subviews{
            if let footer = object as? RefreshFooterView {
                footer.endRefreshing()
            }
        }
    }
  
    func setFooterHidden(_ hidden: Bool)
    {
        for object in self.subviews{
            if let footer = object as? RefreshFooterView {
                footer.isHidden = hidden
            }
        }
        
    }
    
    func isFooterHidden() -> Bool
    {
        for object in self.subviews{
            if let footer = object as? RefreshFooterView {
                return footer.isHidden
            }
        }
        return false
    }
}

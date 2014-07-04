//
//  Menu.swift
//  SwiftRBMenu
//
//  Created by Loarland_Yang on 14-7-4.
//  Copyright (c) 2014 CH. All rights reserved.
//

import UIKit
import QuartzCore

enum MenuState {
    case MenuShownState
    case MenuClosedState
    case MenuDisplayingState
}

enum MenuAllignment {
    case MenuTextAllignmentLeft
    case MenuTextAlignmentRight
    case MenuTextAlignmentCenter
}

let CELLIDENTIFIER = "menubutton"
let MENU_BOUNCE_OFFSET = 10
let PANGESTUREENABLE = 1
let VELOCITY_TRESHOLD = 1000
let AUTOCLOSE_VELOCITY = 1200

class MenuItem:NSObject {
    var title = String()
    var completion:(Bool) -> Void = {(Bool) in
    }
    var menuButton = UIButton()
    
    init() {
        super.init()
    }
    
    func initMenuItemWithTitle(title:String,withCompletionHandler completion:(Bool) -> Void) -> AnyObject{
        self.title = title
        self.completion = completion
        return self
    }
}

class Menu: UIView,UITableViewDataSource,UITableViewDelegate {

    var currentMenuState:MenuState?
    override var backgroundColor:UIColor!{
    willSet{
        if self.backgroundColor != newValue {
            self.menuContentTable.backgroundColor = newValue
        }
    }
    }
    var highLighedIndex:UInt = 0
    var height:Float = 0.0 {
    willSet{
        if self.height != newValue {
            var menuFrame = self.frame
            menuFrame.size.height = newValue
            menuContentTable.frame = menuFrame
            self.height = newValue
        }
    }
    }
    var textColor:UIColor = UIColor()
    var highLightTextColor = UIColor()
    var titleAllignment:MenuAllignment = MenuAllignment.MenuTextAlignmentRight
    var menuItems:NSArray = NSArray()
    var menuContentTable:UITableView = UITableView() {
    willSet{
        if self.menuContentTable != newValue {
            newValue.delegate = self
            newValue.dataSource = self
            newValue.showsVerticalScrollIndicator = false
            newValue.separatorColor = UIColor.clearColor()
            newValue.backgroundColor = UIColor.whiteColor()
            newValue.allowsMultipleSelection = false
            self.menuContentTable = newValue
            self.addSubview(self.menuContentTable)
        }
    }
    }
    var contentController:UIViewController = UIViewController() {
    willSet{
        if self.contentController != newValue {
            if newValue.navigationController != nil{
                self.contentController = newValue.navigationController
            }else {
                self.contentController = newValue
            }
            if PANGESTUREENABLE > 0 {
                self.contentController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("didPan:")))
            }
            /////////
            setShadowProperties()
            self.contentController.view.autoresizingMask = UIViewAutoresizing.None
            UIApplication.sharedApplication().delegate.window?.insertSubview(self, atIndex: 0)
        }
    }
    }
    
    let MENUITEM_FONT_NAME = "HelveticaNeue-Light"
    let MENU_ITEM_FONTSIZE = 25
    let STARTINDEX = 1
    
    func setShadowProperties() {
        self.contentController.view.layer.shadowOffset = CGSizeMake(0, 1)
        self.contentController.view.layer.shadowRadius = 4.0
        self.contentController.view.layer.shadowColor = UIColor.lightGrayColor().CGColor
        self.contentController.view.layer.shadowOpacity = 0.4
        self.contentController.view.layer.shadowPath = UIBezierPath(rect: self.contentController.view.bounds).CGPath
    }
    
    init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.highLighedIndex = UInt(STARTINDEX)
        self.height = 260
    }
    
    func initWithItems(menuItems:NSArray,textColor textColor:UIColor,hightLightTextColor hightLightTextColor:UIColor,backgroundColor backGroundColor:UIColor,andTextAllignment titleAllignment:MenuAllignment,forViewController viewController:UIViewController) -> AnyObject {
        self.frame = CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), self.height)
        self.menuItems = menuItems
        self.titleAllignment = titleAllignment
        self.menuContentTable = UITableView(frame: self.frame)
        self.textColor = textColor
        self.highLightTextColor = hightLightTextColor
        self.backgroundColor = backGroundColor
        self.currentMenuState = MenuState.MenuClosedState
        self.contentController = viewController;
        return self
    }
    
    func initWithItems(menuItems:NSArray,andTextAllignment titleAllignment:MenuAllignment,forViewController viewController:UIViewController) -> AnyObject {
        return self.initWithItems(menuItems, textColor: UIColor.grayColor(), hightLightTextColor: UIColor.blackColor(), backgroundColor: UIColor.whiteColor(), andTextAllignment: titleAllignment, forViewController: viewController)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    
    func showMenu() {
        if self.currentMenuState == MenuState.MenuShownState || self.currentMenuState == MenuState.MenuDisplayingState {
            ///////////////////////////////////////////////////////////////////////////
            self.animateMenuClosingWithCompletion(nil)
        }else {
            self.currentMenuState = MenuState.MenuDisplayingState
            self.animateMenuOpening()
        }
    }
    
    func dismissMenu() {
        if self.currentMenuState == MenuState.MenuShownState || self.currentMenuState == MenuState.MenuDisplayingState {
            self.contentController.view.frame = CGRectOffset(self.contentController.view.frame, 0, -self.height + Float(MENU_BOUNCE_OFFSET))
            self.currentMenuState = MenuState.MenuClosedState
        }
    }
    
    func didPan(panRecognizer:UIPanGestureRecognizer) {
        var viewCenter:CGPoint = panRecognizer.view.center
        if panRecognizer.state == UIGestureRecognizerState.Began || panRecognizer.state == UIGestureRecognizerState.Changed {
            var translation:CGPoint = panRecognizer.translationInView(panRecognizer.view.superview)
            if viewCenter.y >= UIScreen.mainScreen().bounds.size.height / 2 && viewCenter.y <= ((UIScreen.mainScreen().bounds.size.height / 2 + self.height) - Float(MENU_BOUNCE_OFFSET)) {
                
                self.currentMenuState = MenuState.MenuDisplayingState
                viewCenter.y = abs(viewCenter.y + translation.y)
                if viewCenter.y >= UIScreen.mainScreen().bounds.size.height / 2 && viewCenter.y < UIScreen.mainScreen().bounds.size.height / 2 + self.height - Float(MENU_BOUNCE_OFFSET) {
                    
                    self.contentController.view.center = viewCenter
                }
                panRecognizer.setTranslation(CGPointZero, inView: self.contentController.view)
            }
        }else if panRecognizer.state == UIGestureRecognizerState.Ended {
            var velocity:CGPoint = panRecognizer.velocityInView(panRecognizer.view.superview)
            if velocity.y > Float(VELOCITY_TRESHOLD) {
                ///////////////////////////////////
                self.openMenuFromCenterWithVelocity(velocity.y)
            }else if velocity.y < -Float(VELOCITY_TRESHOLD) {
                ///////////////////////////////////
                self.closeMenuFromCenterWithVelocity(abs(velocity.y))
            }else if viewCenter.y < UIScreen.mainScreen().bounds.size.height / 2 + self.height / 2 {
                ////
                self.closeMenuFromCenterWithVelocity(Float(AUTOCLOSE_VELOCITY))
            }else if viewCenter.y <= UIScreen.mainScreen().bounds.size.height / 2 + self.height - Float(MENU_BOUNCE_OFFSET) {
                ///
                self.openMenuFromCenterWithVelocity(Float(AUTOCLOSE_VELOCITY))
            }
        }
    }
    
    func animateMenuOpening() {
        if self.currentMenuState != MenuState.MenuShownState {
            UIView.animateWithDuration(0.2, animations: {() in
                self.contentController.view.center = CGPointMake(self.contentController.view.center.x, UIScreen.mainScreen().bounds.size.height / 2 + self.height)
                }, completion: {(finished) in
                    UIView.animateWithDuration(0.2, animations: {() in
                        self.contentController.view.center = CGPointMake(self.contentController.view.center.x, UIScreen.mainScreen().bounds.size.height / 2 + self.height - Float(MENU_BOUNCE_OFFSET))
                        }, completion: {(finished) in
                            self.currentMenuState = MenuState.MenuShownState
                        })
                })
        }
    }
    
    func animateMenuClosingWithCompletion(completion:((Bool) -> Void)?) {
        UIView.animateWithDuration(0.2, animations: {() in
            self.contentController.view.center = CGPointMake(self.contentController.view.center.x, self.contentController.view.center.y + Float(MENU_BOUNCE_OFFSET))
            }, completion: {(finished) in
                UIView.animateWithDuration(0.2, animations: {() in
                    self.contentController.view.center = CGPointMake(self.contentController.view.center.x, UIScreen.mainScreen().bounds.size.height / 2)
                    }, completion: {(finished) in
                        if finished {
                            self.currentMenuState = MenuState.MenuClosedState
                            if completion != nil {
                                completion!(finished)
                            }
                        }
                        
                    })
            })
    }
    
    func closeMenuFromCenterWithVelocity(velocity:Float) {
        var viewCenterY:Float = UIScreen.mainScreen().bounds.size.height / 2
        self.currentMenuState = MenuState.MenuDisplayingState
//        var time:Float = (self.contentController.view.center.y - viewCenterY) / velocity
        UIView.animateWithDuration(NSTimeInterval((self.contentController.view.center.y - viewCenterY) / velocity), animations: {() in
            self.contentController.view.center = CGPointMake(self.contentController.view.center.x, UIScreen.mainScreen().bounds.size.height / 2)
            }, completion: {(finished) in
                self.currentMenuState = MenuState.MenuClosedState
            })
    }
    
    func openMenuFromCenterWithVelocity(velocity:Float) {
        var viewCenterY:Float = UIScreen.mainScreen().bounds.size.height / 2 + self.height - Float(MENU_BOUNCE_OFFSET)
        self.currentMenuState = MenuState.MenuDisplayingState
        UIView.animateWithDuration(NSTimeInterval((viewCenterY - self.contentController.view.center.y) / velocity), animations: {() in
            self.contentController.view.center = CGPointMake(self.contentController.view.center.x, viewCenterY)
            }, completion: {(completion) in
                self.currentMenuState = MenuState.MenuShownState
            })
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count + 2 * STARTINDEX
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var menuCell:UITableViewCell!
        var menuItem:MenuItem?
        if menuCell == nil {
            menuCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "menubutton")
            ////////////////////////////////////
            self.setMenuTitleAlligmentForCell(menuCell)
            menuCell.backgroundColor = UIColor.clearColor()
            menuCell.selectionStyle = UITableViewCellSelectionStyle.None
            menuCell.textLabel.textColor = self.textColor
            menuCell.textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        }
        if self.highLighedIndex == indexPath.row {
            menuCell.textLabel.textColor = self.highLightTextColor
            menuCell.textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 25+5)
        }
        else{
            menuCell.textLabel.textColor = self.textColor
            menuCell.textLabel.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        }
        if indexPath.row >= STARTINDEX && indexPath.row <= (self.menuItems.count - 1 + STARTINDEX) {
            menuItem = self.menuItems.objectAtIndex(indexPath.row - STARTINDEX) as? MenuItem
        }
        menuCell.textLabel.text =  menuItem?.title
        return menuCell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.row < STARTINDEX || indexPath.row > self.menuItems.count - 1 + STARTINDEX {
            return
        }
        self.highLighedIndex = UInt(indexPath.row)
        self.menuContentTable.reloadData()
        var selectedItem:MenuItem = self.menuItems.objectAtIndex(indexPath.row - STARTINDEX) as MenuItem
        self.animateMenuClosingWithCompletion(selectedItem.completion)
    }
    
    func setMenuTitleAlligmentForCell(cell:UITableViewCell) {
        if self.titleAllignment != nil {
            switch(self.titleAllignment) {
            case .MenuTextAllignmentLeft:
                cell.textLabel.textAlignment = NSTextAlignment.Left
            case .MenuTextAlignmentCenter:
                cell.textLabel.textAlignment = NSTextAlignment.Center
            case .MenuTextAlignmentRight:
                cell.textLabel.textAlignment = NSTextAlignment.Right
            default:
                break
            }
        }
    }
    
}

























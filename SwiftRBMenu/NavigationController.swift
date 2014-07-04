//
//  NavigationController.swift
//  SwiftRBMenu
//
//  Created by Loarland_Yang on 14-7-4.
//  Copyright (c) 2014 CH. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    var menu:Menu
    
    init(coder aDecoder: NSCoder!)  {
        menu = Menu(frame: UIScreen.mainScreen().bounds)
        super.init(coder: aDecoder)
    }

    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        menu = Menu(frame: UIScreen.mainScreen().bounds)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var firstViewController:FirstViewController = storyboard.instantiateViewControllerWithIdentifier("firstView") as FirstViewController
        self.setViewControllers([firstViewController], animated: false)
        
        var item:MenuItem = MenuItem()
        item.initMenuItemWithTitle("First", withCompletionHandler: {(finished) in
            var firstViewController:FirstViewController = storyboard.instantiateViewControllerWithIdentifier("firstView") as FirstViewController
            self.setViewControllers([firstViewController], animated: false)
            })
        
        var item2:MenuItem = MenuItem()
        item2.initMenuItemWithTitle("Second", withCompletionHandler: {(finished) in
            var secondViewController:SecondViewController = storyboard.instantiateViewControllerWithIdentifier("secondView") as SecondViewController
            self.setViewControllers([secondViewController], animated: false)
            })
        
        self.menu.initWithItems([item,item2], andTextAllignment: MenuAllignment.MenuTextAllignmentLeft, forViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMenu() {
        self.menu.showMenu()
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}

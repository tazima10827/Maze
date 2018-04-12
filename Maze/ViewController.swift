//
//  ViewController.swift
//  Maze
//
//  Created by 田嶋智洋 on 2018/04/13.
//  Copyright © 2018年 田嶋智洋. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    var playerView: UIView!
    var playerMotionManager: CMMotionManager!
    var speesX: Double = 0.0
    var speesY: Double = 0.0
    let screenSize = UIScreen.main.bounds.size
    let maze = [
        [1,0,0,0,1,0],
        [1,0,1,0,1,0],
        [3,0,1,0,1,0],
        [1,1,1,0,0,0],
        [1,0,0,1,1,0],
        [0,0,1,0,0,0],
        [0,1,1,0,1,0],
        [0,0,0,0,1,1],
        [0,1,1,0,0,0],
        [0,0,1,1,1,2],
    ]
    //スタートとゴールを表すUIView
    var startViwe: UIView!
    var goalView: UIView!
    //wallViewのフレームの情報を入れておく
    var wallRectArray = [CGRect]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let cellWidth = screenSize.width / CGFloat(maze[0].count)
        let cellHeight = screenSize.height / CGFloat(maze.count)
        let cellOffsetX = screenSize.width / CGFloat(maze[0].count * 2)
        let cellOffsetY = screenSize.height / CGFloat(maze.count * 2)
        
        for y in 0 ..< maze.count {
            for x in 0 ..< maze[y].count {
                switch maze[y][x] {
                    case 1://当たるとゲームオーバーになるマス
                        let wallView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.black
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                    case 2://スタート地点
                    startViwe = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startViwe.backgroundColor = UIColor.green
                    view.addSubview(startViwe)
                    case 3://ゴール地点
                    goalView = createView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.red
                    view.addSubview(goalView)
                default:
                    break
                }
            }
        }
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth / 6, height:  cellHeight / 6))
        playerView.center = startViwe.center
        playerView.backgroundColor = UIColor.gray
        self.view.addSubview(playerView)
        
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        self.startAccelerometer()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createView(x:Int, y:Int,width:CGFloat, height:CGFloat, offsetX:CGFloat, offsetY: CGFloat) -> UIView {
        let rect = CGRect(x: 0,y: 0,width: width,height:height)
        let view = UIView(frame:rect)
        let center = CGPoint(x: offsetX + width * CGFloat(x),y: offsetY + height * CGFloat(y))
        view.center = center
        return view
    }
    func startAccelerometer(){
        let handler: CMAccelerometerHandler = {(CMAccelerometerData:CMAccelerometerData?,error:Error?) -> Void in
            self.speesX += CMAccelerometerData!.acceleration.x
            self.speesY += CMAccelerometerData!.acceleration.y
            
            var posX = self.playerView.center.x + (CGFloat(self.speesX) / 3)
            var posY = self.playerView.center.y - (CGFloat(self.speesY) / 3)
            
            if posX <= self.playerView.frame.width / 2 {
                self.speesX = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.height / 2 {
                self.speesY = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= self.screenSize.width - (self.playerView.frame.width/2){
                self.speesX = 0
                posX = self.screenSize.width - (self.playerView.frame.width/2)
            }
            if posY >= self.screenSize.height - (self.playerView.frame.height/2){
                self.speesY = 0
                posY = self.screenSize.height - (self.playerView.frame.height/2)
            }
            for wallRect in self.wallRectArray {
                if  wallRect.intersects(self.playerView.frame){
                    self.gameCheck(result: "gameover", message: "壁に当たりました")
                    print("Game Over")
                    return
                }
            }
            if self.goalView.frame.intersects(self.playerView.frame){
                self.gameCheck(result: "Clear", message: "クリアしました")
                print("Clear")
            }
            self.playerView.center = CGPoint(x: posX, y: posY)
        }
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main,withHandler: handler)
    }
    
    func gameCheck(result:String,message: String){
        if playerMotionManager.isAccelerometerActive {
            playerMotionManager.stopAccelerometerUpdates()
        }
        let gameCheckAlert: UIAlertController = UIAlertController(title: result,message: message,preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "もう一度",style: .default,handler: {
            (action: UIAlertAction!) -> Void in
            self.retry()
        })
        gameCheckAlert.addAction(retryAction)
        self.present(gameCheckAlert,animated: true,completion: nil)
    }
    func retry() {
        playerView.center = startViwe.center
        
        if !playerMotionManager.isAccelerometerActive {
            self.startAccelerometer()
        }
        speesX = 0.0
        speesY = 0.0
    }


}


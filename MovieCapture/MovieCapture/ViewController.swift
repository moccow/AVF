//
//  ViewController.swift
//
//  画面右下のボタンを押すと録画が始まり、もう一度押すと録画が終了。
//  録画ファイルは/Users/USER_NAME/Documents/temp.movに保存される。
//


import Cocoa
import AVFoundation
import AppKit


class ViewController: NSViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var videoView: NSView!
    
    @IBAction func testBtn(_ sender: NSButton) {
        
        if self.isRecording {
            self.isRecording = false
            self.stopRecording()
        } else {
            self.isRecording = true
            self.startRecording()
        }
        
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    // AVFoundation Objs
    ////////////////////////////////////////////////////////////////////////////////
    
    // ビデオデバイス←カメラ
    private var videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    // オーディオバイス←マイク
    private var audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    
    
    // 入力デバイスを指定してインスタンスを生成し、デバイスから得られるメディア（映像、音声）を
    // AVCaptureSessionのインスタンスに追加する
    private var videoInput:AVCaptureDeviceInput!
    private var audioInput:AVCaptureDeviceInput!
    
    
    // キャプチャしたメディア（映像、音声）を"QuickTime形式（.mov）"で記録する
    private let fileOutput = AVCaptureMovieFileOutput()
    
    
    // デバイス（カメラ、マイク）からキャプチャしたメディア（映像、音声）を管理するオブジェクト
    private var captureSession = AVCaptureSession()
    
    
    // デバイスからキャプチャした映像を表示するレイヤー（CALayerのサブクラス）
    private var videoLayer : AVCaptureVideoPreviewLayer!
    
    
    
    
    private var isRecording = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
        ////////////////////////////////////////////////////////////////////////////////
        // captureSessionに各メディア（映像、音声）の入力デバイスと出力先を紐づける
        ////////////////////////////////////////////////////////////////////////////////
        
        // 入力カメラの指定
        do {
            // カメラを指定してアクセス
            videoInput = try AVCaptureDeviceInput(device: videoDevice) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        // 入力カメラをcaptureSessionに登録
        self.captureSession.addInput(videoInput)
        
        
        // 入力マイクの指定
        do {
            // マイクを指定してアクセス
            audioInput = try AVCaptureDeviceInput(device: audioDevice) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        // 入力マイクをcaptureSessionに登録
        self.captureSession.addInput(audioInput);
        
        // 出力先をcaptureSessionに登録
        self.captureSession.addOutput(self.fileOutput)
        
        
        // 画面表示用レイヤーに一連のセッションを紐づける
        self.videoLayer = AVCaptureVideoPreviewLayer(session: captureSession) as AVCaptureVideoPreviewLayer
        
        // 表示画面フレームの設定
        self.videoView.layer?.addSublayer(videoLayer)
        self.videoLayer.frame = self.videoView.frame
        
        
        // キャプチャセッション稼働開始
        self.captureSession.startRunning()
        
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        // カメラの停止とメモリ解放
        self.captureSession.stopRunning()
        for output in self.captureSession.outputs {
            self.captureSession.removeOutput(output as! AVCaptureOutput)
        }
        for input in self.captureSession.inputs {
            self.captureSession.removeInput(input as! AVCaptureInput)
        }
    }
    
    
    private func startRecording() {
        // 出力先のディレクトリパス
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        // .movにしないとちゃんと動画が出力されない（生成された動画に音声が入ってなかったりする）
        let filePath : String? = "\(documentsDirectory)/temp.mov"
        let fileURL : NSURL = NSURL(fileURLWithPath: filePath!)
        
        // ファイルが存在している場合は削除
        if FileManager.default.fileExists(atPath: filePath!) {
            try! FileManager.default.removeItem(atPath: filePath!)
        }
        self.fileOutput.startRecording(toOutputFileURL: fileURL as URL!, recordingDelegate: self)
        
    }
    
    private func stopRecording() {
        self.fileOutput.stopRecording()
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////
    // AVCaptureFileOutputRecordingDelegate methods
    ///////////////////////////////////////////////////////////////////////////////////
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("=================== didStartRecordingToOutputFileAt: \(fileURL.path)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, willFinishRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("=================== willFinishRecordingToOutputFileAt: \(fileURL.path)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didPauseRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("=================== didPauseRecordingToOutputFileAt: \(fileURL.path)")
    }
    
    @available(OSX 10.7, *)
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("=================== didFinishRecordingToOutputFileAt: \(outputFileURL.path)")
    }
}

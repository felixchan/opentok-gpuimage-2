
import Foundation
import OpenTok
import GPUImage

class FilteredPublisher:  OTPublisherKit, OTVideoCapture, GPUImageVideoCameraDelegate {
    
    let imageHeight = 240
    let imageWidth = 320
    
    var videoCaptureConsumer: OTVideoCaptureConsumer?
    var videoCamera: GPUImageVideoCamera?
    let sepiaImageFilter = GPUImageSepiaFilter()
    var videoFrame = OTVideoFrame()
    var rawOut = GPUImageRawDataOutput()
    var view = GPUImageView()
    
    override init() {
        super.init()
    }
    
    override init!(delegate: OTPublisherKitDelegate!) {
        super.init(delegate: delegate)
    }
    
    override init!(delegate: OTPublisherKitDelegate!, name: String!, audioTrack: Bool, videoTrack: Bool) {
        super.init(delegate: delegate, name: name, audioTrack: audioTrack, videoTrack: videoTrack)
    }
    
    
    override init!(delegate: OTPublisherKitDelegate!, name: String!){
        super.init(delegate: delegate, name: name)
        
        self.view = GPUImageView(frame: CGRectMake(0,0,1,1))
        self.videoCapture = self
        
//        let format = OTVideoFormat.init(NV12WithWidth: UInt32(imageWidth), height: UInt32(imageHeight))
//        self.videoFrame = OTVideoFrame(format: format)
        
        let format = OTVideoFormat.init()
        format.pixelFormat = OTPixelFormat.ARGB
        format.bytesPerRow = [ imageWidth * 4 ]
        format.imageWidth = UInt32(imageWidth)
        format.imageHeight = UInt32(imageHeight)
        videoFrame = OTVideoFrame.init(format: format)
    }

    
    
    func initCapture(){
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePosition.Front)
        videoCamera?.outputImageOrientation = UIInterfaceOrientation.Portrait
 
        
        let sepia = GPUImageSepiaFilter()
        videoCamera?.addTarget(sepia)
        sepia.addTarget(self.view)
        
        let size = CGSizeMake(CGFloat(imageWidth), CGFloat(imageHeight))
        
        self.rawOut = GPUImageRawDataOutput(imageSize: size, resultsInBGRAFormat: true)
        sepia.addTarget(rawOut)
        
        weak var weakRawOut = self.rawOut
        weak var weakVideoFrame = self.videoFrame
        weak var weakVideoCaptureConsumer = self.videoCaptureConsumer
        
        
        rawOut.newFrameAvailableBlock = {
            weakRawOut?.lockFramebufferForReading()
            let outputBytes = weakRawOut?.rawBytesForImage
            
            weakVideoFrame?.clearPlanes()
            weakVideoFrame?.planes.addPointer(outputBytes!)
            weakVideoCaptureConsumer?.consumeFrame(weakVideoFrame)
            weakRawOut?.unlockFramebufferAfterReading()
        }
        
        videoCamera?.startCameraCapture()
    }
    
    
    func releaseCapture(){
        videoCamera?.delegate = nil
        videoCamera = nil
    }
    
    
    func startCapture() -> Int32{
        return 0
    }
    
    
    func stopCapture() -> Int32{
        return 0
    }
    
    
    func isCaptureStarted() -> Bool{
        return true
    }
    
    
    func captureSettings(videoFormat: OTVideoFormat!) -> Int32{
        videoFormat.pixelFormat = OTPixelFormat.NV12
        videoFormat.imageWidth = UInt32(imageWidth)
        videoFormat.imageHeight = UInt32(imageHeight)
        return 0;
    }
}
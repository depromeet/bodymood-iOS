import AVFoundation
import UIKit
import Alamofire
import KakaoSDKTemplate

class CameraFocusSquare: UIView {
    override func draw(_ rect: CGRect) {
        let height = rect.height
        let width = rect.width
        let color: UIColor = UIColor.orange
        
        let drect = CGRect(
            x: (width * 0.25),
            y: (height * 0.25),
            width: (width * 0.5),
            height: (height * 0.5)
        )
        let bpath: UIBezierPath = UIBezierPath(rect: drect)

        color.set()
        bpath.stroke()
    }
}

class CameraViewController: UIViewController, Coordinating {
    enum CameraType {
        case front
        case back
    }

    var coordinator: Coordinator?
    private var captureSession: AVCaptureSession!
    private var backCamera: AVCaptureDevice!
    private var backCameraInput: AVCaptureInput!
    private var frontCamera: AVCaptureDevice!
    private var frontCameraInput: AVCaptureInput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var cameraOutput: AVCapturePhotoOutput!

    private var takePicture = false
    private var isBackCamera = true

    private lazy var contentView: UIView = { createContentView() }()
    private lazy var flashView: UIView = { createFlashView() }()
    private lazy var topView: UIView = { createTopView() }()
    private lazy var clearButton: UIButton = { createClearButton() }()
    private lazy var bottomView: UIView = { createBottomView()}()
    private lazy var stackView: UIView = { createStackView() }()
    private lazy var flashButton: UIButton = { createFlashButton() }()
    private lazy var shutterButton: UIButton = { createShutterButton() }()
    private lazy var cameraFlipButton: UIButton = {  createCameraFlipButton() }()
    private lazy var focusGesture: UITapGestureRecognizer = { createfocusGesture() }()

    deinit {
        Log.debug(Self.self, #function)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        overrideUserInterfaceStyle = .dark
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
        session()
        captureDevice()
        cameraLayer()
        cameraDataOutput()
        style()
        layout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.frame
        flashView.frame = view.frame
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overrideUserInterfaceStyle = .light
        setNeedsStatusBarAppearanceUpdate()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
            }

        case .restricted:
           break
        case .denied:
            break
        case .authorized:
            Log.debug("camera authorized")

        @unknown default:
        break
        }
    }

    private func session() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        if captureSession.canSetSessionPreset(.photo) {
            captureSession.sessionPreset = .photo
        }
    }

    private func captureDevice() {
        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back) {
            backCamera = device
        } else {
            Log.error("no back camera")
        }

        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front) {
            frontCamera = device
        } else {
            Log.error("no front camera")
        }

        guard let backCameraDeviceInput = try? AVCaptureDeviceInput(device: backCamera) else {
            Log.error("coult not set the input of back camera")
            return
        }
        backCameraInput = backCameraDeviceInput
        if !captureSession.canAddInput(backCameraInput) {
            Log.error("back camera is not installed")
        }

        guard let frontCameraDeviceInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            Log.error("could not set the input of front camera")
            return
        }
        frontCameraInput = frontCameraDeviceInput
        if !captureSession.canAddInput(frontCameraInput) {
            Log.error("front camera is not installed")
        }
        captureSession.addInput(backCameraInput)
    }

    private func cameraLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        self.previewLayer.frame = self.contentView.frame
        contentView.layer.insertSublayer(previewLayer, at: 0)
    }

    private func cameraDataOutput() {
        cameraOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(cameraOutput) {
            captureSession.addOutput(cameraOutput)
        } else {
            Log.debug("could not set the output")
        }
        cameraOutput.connections.first?.videoOrientation = .portrait
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
}

// MARK: - Configure UI
extension CameraViewController {
    private func createContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }

    private func createFlashView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }

    private func createTopView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }
    
    private func createClearButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "clear"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        return button
    }

    private func createBottomView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }

    private func createShutterButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "shutter"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(shutterButtonDidTap), for: .touchUpInside)
        return button
    }

    private func createFlashButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "flash"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(flashButtonDidTap), for: .touchUpInside)
        return button
    }

    private func createCameraFlipButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: "flip_camera"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(flipButtonDidTap), for: .touchUpInside)
        return button
    }

    private func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [flashButton, shutterButton, cameraFlipButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 48.0
        return stackView
    }

    private func createfocusGesture() -> UITapGestureRecognizer {
        let instance = UITapGestureRecognizer(target: self, action: #selector(tapToFocus(_: )))
        instance.cancelsTouchesInView = false
        instance.numberOfTapsRequired = 1
        instance.numberOfTouchesRequired = 1
        return instance
    }

    private func style() {
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]

        let backButton = UIButton(type: .custom)
        if let image = UIImage(named: "back") {
            backButton.setImage(image, for: .normal)
        }
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white

        let flipButton = UIButton(type: .custom)
        if let image = UIImage(named: "flip_camera") {
            flipButton.setImage(image, for: .normal)
        }
        flipButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        flipButton.addTarget(self, action: #selector(flipButtonDidTap), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: flipButton)
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    private func layout() {
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        let guide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            contentView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            contentView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: guide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])

        contentView.layer.addSublayer(previewLayer)
        contentView.addGestureRecognizer(focusGesture)
        contentView.addSubview(flashView)
        contentView.addSubview(shutterButton)

        view.addSubview(topView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        topView.addSubview(clearButton)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clearButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 21),
            clearButton.widthAnchor.constraint(equalToConstant: 24),
            clearButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 154)
        ])

        bottomView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20),
            stackView.heightAnchor.constraint(equalToConstant: 80)
        ])

        flashButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flashButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            flashButton.widthAnchor.constraint(equalToConstant: 28),
            flashButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shutterButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: 80),
            shutterButton.heightAnchor.constraint(equalToConstant: 80)
        ])

        cameraFlipButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraFlipButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            cameraFlipButton.widthAnchor.constraint(equalToConstant: 28),
            cameraFlipButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
}

// MARK: - Configure Actions
extension CameraViewController {
    @objc func backButtonDidTap() {
        navigationController?.popViewController(animated: true)
    }

    @objc func shutterButtonDidTap() {
        UIView.animate(
            withDuration: 0.1,
            delay: 0.0,
            options: [.curveEaseOut],
            animations: {() -> Void in
            self.flashView.alpha = 1.0
            }, completion: { (_: Bool) -> Void in
                UIView.animate(withDuration: 0.1, delay: 0.0, animations: {() -> Void in
                    self.flashView.alpha = 0.0
                })
            })

        cameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    @objc func flashButtonDidTap() {
        if isBackCamera {
            if backCamera.hasTorch {
                do {
                    try backCamera.lockForConfiguration()
                } catch {
                    Log.error("back camera has not torch")
                }
            }
            
            if backCamera.isTorchActive {
                backCamera.torchMode = .off
            } else {
                backCamera.torchMode = .on
            }
            
            backCamera.unlockForConfiguration()
        }
    }

    @objc func flipButtonDidTap() {
        switchCameraInput()
    }

    func switchCameraInput() {
        navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
        captureSession.beginConfiguration()
        if isBackCamera {
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
            UIView.transition(
                with: contentView,
                duration: 0.3,
                options: .transitionFlipFromLeft,
                animations: nil,
                completion: nil)

            isBackCamera = false
        } else {
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
            UIView.transition(
                with: contentView,
                duration: 0.3,
                options: .transitionFlipFromRight,
                animations: nil,
                completion: nil)
            isBackCamera = true
        }
        cameraOutput.connections.first?.videoOrientation = .portrait
        cameraOutput.connections.first?.isVideoMirrored = !isBackCamera

        captureSession.commitConfiguration()
        navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = true
    }

    @objc func tapToFocus(_ gesture: UITapGestureRecognizer) {
        guard previewLayer != nil else {
            return
        }

        let touchPoint: CGPoint = gesture.location(in: contentView)
        let convertedPoint: CGPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)

        if let device = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = convertedPoint
                    device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                }

                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = convertedPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
                }
            } catch {
            }

            let location = gesture.location(in: contentView)
            let locationX = location.x-125
            let locationY = location.y-125
            let lineView = CameraFocusSquare(frame: CGRect(
                x: locationX,
                y: locationY,
                width: 250,
                height: 250)
            )
            lineView.backgroundColor = UIColor.clear
            lineView.alpha = 0.9
            contentView.addSubview(lineView)

            CameraFocusSquare.animate(
                withDuration: 0.5,
                animations: {
                    lineView.alpha = 1
                }, completion: { _ in
                    lineView.alpha = 0
                }
            )
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }

        let image = UIImage(data: data)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = self.view.bounds
        self.contentView.addSubview(imageView)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }
}

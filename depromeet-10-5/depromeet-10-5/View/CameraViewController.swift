import AVFoundation
import UIKit

class CameraViewController: UIViewController, AuthCoordinating {
    enum CameraType {
        case front
        case back
    }

    var coordinator: AuthCoordinatorProtocol?
    private var captureSession: AVCaptureSession!
    private var backCamera: AVCaptureDevice!
    private var backCameraInput: AVCaptureInput!
    private var frontCamera: AVCaptureDevice!
    private var frontCameraInput: AVCaptureInput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var cameraOutput: AVCapturePhotoOutput!
    
    private var takePicture = false
    private var isBackCamera = true

    private lazy var contentView: UIView = {createContentView()}()
    private lazy var shutterButton: UIButton = {createShutterButton()}()

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
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    return
                }

                DispatchQueue.main.async {
                    self?.cameraView()
                }
            }

        case .restricted:
           break
        case .denied:
            break
        case .authorized:
            cameraView()

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
        // 후면 카메라 설정
        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back) {
            backCamera = device
        } else {
            Log.error("no back camera")
        }
        
        // 전면 카메라 설정
        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front) {
            frontCamera = device
        } else {
            Log.error("no front camera")
        }

        // 후면 카메라 input 설정
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

    func cameraView() {
//        if cameraCheck == CameraType.back {
//            cameraCheck = CameraType.front
//            let session = AVCaptureSession()
//            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//                do {
//                    let input = try AVCaptureDeviceInput(device: device)
//                    if session.canAddInput(input) {
//                        session.addInput(input)
//                    }
//
//                    if session.canAddOutput(output) {
//                        session.addOutput(output)
//                    }
//
//                    previewLayer.videoGravity = .resizeAspectFill
//                    previewLayer.session = session
//
//                    session.startRunning()
//                    self.session = session
//
//                } catch {
//                    Log.debug(error)
//                }
//            }
//        } else if cameraCheck == CameraType.front {
//            cameraCheck = CameraType.back
//            let session = AVCaptureSession()
//            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
//                do {
//                    let input = try AVCaptureDeviceInput(device: device)
//                    if session.canAddInput(input) {
//                        session.addInput(input)
//                    }
//
//                    if session.canAddOutput(output) {
//                        session.addOutput(output)
//                    }
//
//                    previewLayer.videoGravity = .resizeAspectFill
//                    previewLayer.session = session
//
//                    session.startRunning()
//                    self.session = session
//
//                } catch {
//                    Log.debug(error)
//                }
//            }
//        }
//
    }

    @objc func shutterButtonDidTap() {
        cameraOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    @objc func backButtonDidTap() {
        Log.debug("backButtonDidTap")
        navigationController?.popViewController(animated: true)
    }

    @objc func flipButtonDidTap() {
        Log.debug("flipButtonDidTap")
        switchCameraInput()
    }

    func switchCameraInput() {
        navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = false
        captureSession.beginConfiguration()
        if isBackCamera {
            captureSession.removeInput(backCameraInput)
            captureSession.addInput(frontCameraInput)
            isBackCamera = false
        } else {
            captureSession.removeInput(frontCameraInput)
            captureSession.addInput(backCameraInput)
            isBackCamera = true
        }
        cameraOutput.connections.first?.videoOrientation = .portrait
        cameraOutput.connections.first?.isVideoMirrored = !isBackCamera

        captureSession.commitConfiguration()
        navigationItem.rightBarButtonItem?.customView?.isUserInteractionEnabled = true
    }
}

// MARK: - Configure UI
extension CameraViewController {
    private func createContentView() -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }

    private func createShutterButton() -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button.setImage(UIImage(named: "shutter"), for: UIControl.State.normal)
        button.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 100)
        button.addTarget(self, action: #selector(shutterButtonDidTap), for: .touchUpInside)
        return button
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
        contentView.addSubview(shutterButton)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
        ])
    }
}

/// TODO: 테스트용 코드. 추후 제거할 것
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }

        let image = UIImage(data: data)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        contentView.addSubview(imageView)
    }
}

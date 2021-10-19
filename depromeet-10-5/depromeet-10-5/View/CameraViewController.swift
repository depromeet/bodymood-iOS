import AVFoundation
import UIKit

class CameraViewController: UIViewController, AuthCoordinating {
    enum CameraType {
        case Front
        case Back
    }

    var coordinator: AuthCoordinatorProtocol?
    private var cameraCheck = CameraType.Back
    private var session: AVCaptureSession?
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()

    private lazy var contentView: UIView = {createContentView()}()
    private lazy var shutterButton: UIButton = {createShutterButton()}()

    override func viewDidLoad() {
        super.viewDidLoad()

        style()
        layout()
        checkCameraPermission()
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

    func cameraView() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session

                session.startRunning()
                self.session = session

            } catch {
                print(error)
            }
        }
    }
    
    private func switchCamera(captureSession: AVCaptureSession?) {
        
    }

    @objc func shutterButtonDidTap() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    @objc func backButtonDidTap() {
        Log.debug("backButtonDidTap")
        navigationController?.popViewController(animated: true)
    }

    @objc func flipButtonDidTap() {
        Log.debug("flipButtonDidTap")
        
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

        session?.stopRunning()

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        contentView.addSubview(imageView)
    }
}

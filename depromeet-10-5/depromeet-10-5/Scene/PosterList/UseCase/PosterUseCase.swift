import Photos
import Combine

protocol PosterUseCaseType {
    func fetch(page: Int, size: Int) -> AnyPublisher<PosterPhotoListResponseModel, Error>
}

class PosterUseCase: PosterUseCaseType {

    func fetch(page: Int, size: Int) -> AnyPublisher<PosterPhotoListResponseModel, Error> {
        BodyMoodAPIService.shared.fetchPosterList(page: page, size: size)
    }
}

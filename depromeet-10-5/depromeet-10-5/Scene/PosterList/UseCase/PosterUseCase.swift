import Photos
import Combine

protocol PosterUseCaseType {
    func fetch(page: Int, size: Int) -> AnyPublisher<[PosterPhotoResponseModel], Error>
}

class PosterUseCase: PosterUseCaseType {

    func fetch(page: Int, size: Int) -> AnyPublisher<[PosterPhotoResponseModel], Error> {
        BodyMoodAPIService.shared.fetchPosterList(page: page, size: size)
    }
}

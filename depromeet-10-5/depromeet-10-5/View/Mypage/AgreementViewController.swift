import Combine
import UIKit

class AgreementViewController: UIViewController {
    private let viewModel: AgreementViewModelType
    private var subscriptions = Set<AnyCancellable>()
    private lazy var titleLabel: UILabel = { createTitleLabel() }()
    private lazy var contentLabel: UILabel = { createContentLabel() }()
    private lazy var scrollView: UIScrollView = { createScrollView() }()
    private lazy var agreementTextView: UILabel = { createAgreementTextView() }()
    
    private lazy var contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+500)
    
    private
    let agreementText = "< Bodymood >('https://suzy8347.notion.site/Bodymood-e317364017e0'이하 'Bodymood')은(는) 「개인정보 보호법」 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다. \n\n○ 이 개인정보처리방침은 2021년 11월 8부터 적용됩니다.\n\n\n제1조(개인정보의 처리 목적) \n\n< Bodymood >('https://suzy8347.notion.site/Bodymood-e317364017e0'이하 'Bodymood')은(는) 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며 이용 목적이 변경되는 경우에는 「개인정보 보호법」 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.\n\n1. 홈페이지 회원가입 및 관리\n\n회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지, 각종 고지·통지 목적으로 개인정보를 처리합니다.\n\n\n2. 재화 또는 서비스 제공\n\n서비스 제공, 콘텐츠 제공, 맞춤서비스 제공, 본인인증을 목적으로 개인정보를 처리합니다.\n\n3. 마케팅 및 광고에의 활용\n신규 서비스(제품) 개발 및 맞춤 서비스 제공, 이벤트 및 광고성 정보 제공 및 참여기회 제공 , 인구통계학적 특성에 따른 서비스 제공 및 광고 게재 , 서비스의 유효성 확인, 접속빈도 파악 또는 회원의 서비스 이용에 대한 통계 등을 목적으로 개인정보를 처리합니다.\n\n\n제2조(개인정보의 처리 및 보유 기간)\n\n① < Bodymood >은(는) 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.\n\n② 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.\n\n\n1.<홈페이지 회원가입 및 관리>\n\n<홈페이지 회원가입 및 관리>와 관련한 개인정보는 수집.이용에 관한 동의일로부터<1년>까지 위 이용목적을 위하여 보유.이용됩니다.\n\n보유근거 : 관련 법령에 의한 정보보유 사유\n\n관련법령 : 1)신용정보의 수집/처리 및 이용 등에 관한 기록 : 3년\n\n2) 소비자의 불만 또는 분쟁처리에 관한 기록 : 3년\n\n3) 표시/광고에 관한 기록 : 6개월\n\n예외사유 :\n\n\n제3조(개인정보의 제3자 제공)\n\n① < Bodymood >은(는) 개인정보를 제1조(개인정보의 처리 목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 「개인정보 보호법」 제17조 및 제18조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.\n\n② < Bodymood >은(는) 다음과 같이 개인정보를 제3자에게 제공하고 있습니다.\n\n1. < >\n\n개인정보를 제공받는 자 :\n\n제공받는 자의 개인정보 이용목적 :\n\n제공받는 자의 보유.이용기간:\n\n\n제4조(개인정보처리 위탁)\n\n① < Bodymood >은(는) 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다.\n\n1. < >\n\n위탁받는 자 (수탁자) :\n\n위탁하는 업무의 내용 :\n\n위탁기간 :\n\n② < Bodymood >은(는) 위탁계약 체결시 「개인정보 보호법」 제26조에 따라 위탁업무 수행목적 외 개인정보 처리금지, 기술적․관리적 보호조치, 재위탁 제한, 수탁자에 대한 관리․감독, 손해배상 등 책임에 관한 사항을 계약서 등 문서에 명시하고, 수탁자가 개인정보를 안전하게 처리하는지를 감독하고 있습니다.\n\n③ 위탁업무의 내용이나 수탁자가 변경될 경우에는 지체없이 본 개인정보 처리방침을 통하여 공개하도록 하겠습니다.\n\n\n제5조(정보주체와 법정대리인의 권리·의무 및 그 행사방법)\n\n① 정보주체는 Bodymood에 대해 언제든지 개인정보 열람·정정·삭제·처리정지 요구 등의 권리를 행사할 수 있습니다.\n\n② 제1항에 따른 권리 행사는Bodymood에 대해 「개인정보 보호법」 시행령 제41조제1항에 따라 서면, 전자우편, 모사전송(FAX) 등을 통하여 하실 수 있으며 Bodymood은(는) 이에 대해 지체 없이 조치하겠습니다.\n\n③ 제1항에 따른 권리 행사는 정보주체의 법정대리인이나 위임을 받은 자 등 대리인을 통하여 하실 수 있습니다.이 경우 “개인정보 처리 방법에 관한 고시(제2020-7호)” 별지 제11호 서식에 따른 위임장을 제출하셔야 합니다.\n\n④ 개인정보 열람 및 처리정지 요구는 「개인정보 보호법」 제35조 제4항, 제37조 제2항에 의하여 정보주체의 권리가 제한 될 수 있습니다.\n\n⑤ 개인정보의 정정 및 삭제 요구는 다른 법령에서 그 개인정보가 수집 대상으로 명시되어 있는 경우에는 그 삭제를 요구할 수 없습니다.\n\n⑥ Bodymood은(는) 정보주체 권리에 따른 열람의 요구, 정정·삭제의 요구, 처리정지의 요구 시 열람 등 요구를 한 자가 본인이거나 정당한 대리인인지를 확인합니다.\n\n\n제6조(처리하는 개인정보의 항목 작성)\n\n① < Bodymood >은(는) 다음의 개인정보 항목을 처리하고 있습니다.\n\n1< 홈페이지 회원가입 및 관리 >\n\n필수항목 : 이름\n\n선택항목 :\n\n\n제7조(개인정보의 파기)\n\n① < Bodymood > 은(는) 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.\n\n② 정보주체로부터 동의받은 개인정보 보유기간이 경과하거나 처리목적이 달성되었음에도 불구하고 다른 법령에 따라 개인정보를 계속 보존하여야 하는 경우에는, 해당 개인정보를 별도의 데이터베이스(DB)로 옮기거나 보관장소를 달리하여 보존합니다.\n\n1. 법령 근거 :\n\n2. 보존하는 개인정보 항목 : 계좌정보, 거래날짜\n\n③ 개인정보 파기의 절차 및 방법은 다음과 같습니다.\n\n\n1. 파기절차\n\n< Bodymood > 은(는) 파기 사유가 발생한 개인정보를 선정하고, < Bodymood > 의 개인정보 보호책임자의 승인을 받아 개인정보를 파기합니다.\n\n\n제8조(개인정보의 안전성 확보 조치)\n\n< Bodymood >은(는) 개인정보의 안전성 확보를 위해 다음과 같은 조치를 취하고 있습니다.\n\n1. 정기적인 자체 감사 실시\n\n개인정보 취급 관련 안정성 확보를 위해 정기적(분기 1회)으로 자체 감사를 실시하고 있습니다.\n\n\n제9조(개인정보 자동 수집 장치의 설치•운영 및 거부에 관한 사항)\n\nBodymood 은(는) 정보주체의 이용정보를 저장하고 수시로 불러오는 ‘쿠키(cookie)’를 사용하지 않습니다.\n\n\n제10조 (개인정보 보호책임자)\n\n① Bodymood 은(는) 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.\n\n\n▶ 개인정보 보호책임자\n\n성명 :남수지\n\n직책 :운영\n\n직급 :운영\n\n연락처 :01025426163, suzy8347@gmail.com,\n\n※ 개인정보 보호 담당부서로 연결됩니다.\n\n\n▶ 개인정보 보호 담당부서\n\n부서명 :\n\n담당자 :\n\n연락처 :, ,\n\n② 정보주체께서는 Bodymood 의 서비스(또는 사업)을 이용하시면서 발생한 모든 개인정보 보호 관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자 및 담당부서로 문의하실 수 있습니다. Bodymood 은(는) 정보주체의 문의에 대해 지체 없이 답변 및 처리해드릴 것입니다.\n\n\n제11조(개인정보 열람청구)\n\n정보주체는 ｢개인정보 보호법｣ 제35조에 따른 개인정보의 열람 청구를 아래의 부서에 할 수 있습니다.\n\n< Bodymood >은(는) 정보주체의 개인정보 열람청구가 신속하게 처리되도록 노력하겠습니다.\n\n\n▶ 개인정보 열람청구 접수·처리 부서\n\n부서명 :\n\n담당자 :\n\n연락처 : , ,\n\n\n제12조(권익침해 구제방법)\n\n\n정보주체는 개인정보침해로 인한 구제를 받기 위하여 개인정보분쟁조정위원회, 한국인터넷진흥원 개인정보침해신고센터 등에 분쟁해결이나 상담 등을 신청할 수 있습니다. 이 밖에 기타 개인정보침해의 신고, 상담에 대하여는 아래의 기관에 문의하시기 바랍니다.\n\n1. 개인정보분쟁조정위원회 : (국번없이) 1833-6972 (www.kopico.go.kr)\n\n2. 개인정보침해신고센터 : (국번없이) 118 (privacy.kisa.or.kr)\n\n3. 대검찰청 : (국번없이) 1301 (www.spo.go.kr)\n\n4. 경찰청 : (국번없이) 182 (ecrm.cyber.go.kr)\n\n\n「개인정보보호법」제35조(개인정보의 열람), 제36조(개인정보의 정정·삭제), 제37조(개인정보의 처리정지 등)의 규정에 의한 요구에 대 하여 공공기관의 장이 행한 처분 또는 부작위로 인하여 권리 또는 이익의 침해를 받은 자는 행정심판법이 정하는 바에 따라 행정심판을 청구할 수 있습니다.\n\n※ 행정심판에 대해 자세한 사항은 중앙행정심판위원회(www.simpan.go.kr) 홈페이지를 참고하시기 바랍니다.\n\n\n제13조(개인정보 처리방침 변경)\n\n① 이 개인정보처리방침은 2021년 11월 8부터 적용됩니다.\n\n② 이전의 개인정보 처리방침은 아래에서 확인하실 수 있습니다."

    init(viewModel: AgreementViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Log.debug(Self.self, #function)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        bind()
    }
}

// MARK: - Configure bind
extension AgreementViewController {
    private func bind() {
        viewModel.title.sink { [weak self] title in
            self?.titleLabel.text = title
        }.store(in: &subscriptions)

        navigationItem.leftBarButtonItem?.tap
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscriptions)
    }
}

// MARK: - Configure UI
extension AgreementViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Pretendard-Regular", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        navigationItem.titleView = label
        return label
    }

    private func createContentLabel() -> UILabel {
        let label = UILabel()
        label.text = "Coming Soon"
        label.font = UIFont(name: "PlayfairDisplay-Bold", size: 35)
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }

    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.contentSize = contentSize
        scrollView.autoresizingMask = .flexibleHeight
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        return scrollView
    }

    private func createAgreementTextView() -> UILabel {
        let textView = UILabel()
//        textView.contentInsetAdjustmentBehavior = .automatic
        textView.center = self.view.center
        textView.textAlignment = .justified
        textView.numberOfLines = 0
//        textView.isEditable = false
        textView.backgroundColor = .white
        textView.text = agreementText
        textView.textColor = .black
        textView.font = UIFont(name: "Pretendard-Regular", size: 14)
        textView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(textView)
        return textView
    }

    private func style() {
        scrollView.delegate = self
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = .init(
            image: UIImage(named: "back_black"),
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
    }

    private func layout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: agreementTextView.widthAnchor),
        ])
        
        NSLayoutConstraint.activate([
            agreementTextView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            agreementTextView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            agreementTextView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            agreementTextView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
        ])
    }
}

extension AgreementViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.panGestureRecognizer.translation(in: scrollView).y
        navigationController?.setNavigationBarHidden(value < 0, animated: true)
    }
}

extension AgreementViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !self.isEqual(navigationController?.topViewController)
    }
}

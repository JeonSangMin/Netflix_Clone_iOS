//
//  PreViewController.swift
//  NetflixClone
//
//  Created by MyMac on 2020/04/13.
//  Copyright © 2020 Netflex. All rights reserved.
//

import UIKit
import AVFoundation

class PreViewController: UIViewController {
    let label = UILabel()
    let playButton = UIButton()
    private let dibsView = CustomButtonView(imageName: "plus", labelText: "내가 찜한 콘텐츠")
    private let infoView = CustomButtonView(imageName: "info.circle", labelText: "정보")
    private let dismissButton = UIButton()
    private let playerScrollView = UIScrollView()
    
    // 유진이 decode 끝나면, 이 부분이랑 receivedPreviewIndex(cell Indexpath도 넘겨달라고 요청)
    private var preview = [PreviewContent]()

    private var previewSubviews = [PreviewView]()
    
    private let receivedPreviewIndex: Int
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    init(index: Int = 0) {
        self.receivedPreviewIndex = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setConstraints()
        request(id: LoginStatus.shared.getProfileID() ?? 0)
    }
    
    override func viewWillLayoutSubviews() {
        playerScrollView.setContentOffset(CGPoint(x: CGFloat(receivedPreviewIndex) * playerScrollView.bounds.width, y: 0), animated: false)
//        previewSubviews[receivedPreviewIndex].player.play()
    }
    
    private func request(id: Int) {
        guard let url = URL(string: "https://www.netflexx.ga/profiles/\(id)/contents/"),
            let token = LoginStatus.shared.getToken()
            else { return }
        
        APIManager().request(url: url, method: .get, token: token) { (result) in
            switch result {
            case .success(let data):
                
                if let home = try? JSONDecoder().decode(HomeContent.self, from: data) {
                    self.preview = home.previewContents
                    self.createPreviewSubviews()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setUI() {
        [playerScrollView, dibsView, infoView, playButton, dismissButton].forEach {
            view.addSubview($0)
        }
        
        dibsView.button.tag = 0
        infoView.button.tag = 1
        playButton.tag = 2
        
        playButton.layer.borderWidth = 2
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.setTitle("▶︎ 재생", for: .normal)
        playButton.setTitleColor(UIColor.setNetfilxColor(name: .white), for: .normal)
        playButton.tintColor = .clear
        
        dibsView.label.textColor = UIColor.setNetfilxColor(name: .white)
        infoView.label.textColor = UIColor.setNetfilxColor(name: .white)
        dibsView.label.font = UIFont.dynamicFont(fontSize: 10, weight: .regular)
        infoView.label.font = UIFont.dynamicFont(fontSize: 10, weight: .regular)
        
        dibsView.button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        infoView.button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.setNetfilxColor(name: .white)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton(_:)), for: .touchUpInside)
        view.bringSubviewToFront(dismissButton)
        
        playerScrollView.isPagingEnabled = true
        playerScrollView.delegate = self
    }
    
    
    
    private func createPreviewSubviews() {
        self.previewSubviews = preview.compactMap {
            guard let url = URL(string: $0.previewVideoURL) else {
                print("makeURL Fail")
                return nil
            }
            let view = PreviewView(url: url)
            return view
        }
        
        for (index, view) in previewSubviews.enumerated() {
            playerScrollView.addSubview(view)
            let leading = index == 0 ? playerScrollView.snp.leading : previewSubviews[index-1].snp.trailing
            view.backgroundColor = random
            
//            view.blurredBackgroundView.configure(backgroundImage: preview[index].image)
            
            view.snp.makeConstraints {
                $0.leading.equalTo(leading)
                $0.top.bottom.width.height.equalTo(playerScrollView)
            }
            
            if index == previewSubviews.count - 1 {
                view.snp.makeConstraints {
                    $0.trailing.equalTo(playerScrollView.snp.trailing)
                }
            }
            
        }
    }
    
    @objc private func didTapDismissButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        var dibsButtonClicked = dibsView.isClicked
        
        switch sender.tag {
        case 0:
            // MARK: 찜하기 버튼 눌렀을 때 액션, 서버로 보내기
            if dibsButtonClicked {
                print("찜하기 버튼 클릭: ", dibsButtonClicked)
                // MARK: 눌렀을 때 애니메이션 (숫자의 크기에 따라서 도는 방향이 결정 됨)
                self.dibsView.imageView.transform = .init(rotationAngle: CGFloat.pi)
                UIView.transition(with: self.dibsView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.dibsView.imageView.transform = .identity
                    self.dibsView.imageView.image = UIImage(systemName: "checkmark")})
                
            } else {
                print("찜하기 버튼 풀기: ", dibsButtonClicked)
                // MARK: 찜하기 버튼 한번 더 눌러서 액션 풀기, 서버로 보내기
                self.dibsView.imageView.transform = .init(rotationAngle: CGFloat.pi / 2)
                UIView.transition(with: self.dibsView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.dibsView.imageView.transform = .identity
                    self.dibsView.imageView.image = UIImage(systemName: "plus")
                })
            }
            //            delegate?.dibButtonIsCliked()
            dibsButtonClicked.toggle()
            
        // 정보버튼 눌렀을 때
        case 1:
            print("정보버튼 눌렀다~")
            //            delegate?.infoButtonClicked()
        //            infoButtonClicked.toggle()
        case 2:
            print("재생하자~")
        default:
            break
        }
    }
    
    private func setConstraints() {
        playerScrollView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(view)
        }
        
        let buttonHeight = CGFloat.dynamicYMargin(margin: 40)
        let bottomOffset = CGFloat.dynamicYMargin(margin: -40)
        let dismissButtonSize = CGFloat.dynamicXMargin(margin: 25)
        
        playButton.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.equalTo(view.snp.width).multipliedBy(0.3)
            $0.height.equalTo(buttonHeight)
            $0.bottom.equalTo(view.snp.bottom).offset(bottomOffset)
        }
        
        dibsView.snp.makeConstraints {
            $0.width.height.bottom.equalTo(playButton)
            $0.trailing.equalTo(playButton.snp.leading)
        }
        
        infoView.snp.makeConstraints {
            $0.width.height.bottom.equalTo(playButton)
            $0.leading.equalTo(playButton.snp.trailing)
        }
        
        dismissButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            $0.trailing.equalTo(view).offset(-10)
            $0.width.height.equalTo(dismissButtonSize)
        }
    }
    
}

var random: UIColor {
    get {
        let min: CGFloat = 0.1
        let max: CGFloat = 0.9
        let red = CGFloat.random(in: min ... max)
        let green = CGFloat.random(in: min ... max)
        let blue = CGFloat.random(in: min ... max)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension PreViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let displayingViewIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        previewSubviews[displayingViewIndex].player.play()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        previewSubviews.forEach {
            $0.player.pause()
        }
    }
    
    
}

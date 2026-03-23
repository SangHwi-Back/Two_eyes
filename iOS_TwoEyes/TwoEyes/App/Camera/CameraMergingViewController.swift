//
//  CameraMergingViewController.swift
//  TwoEyes
//
//  Created by 백상휘 on 3/20/26.
//

import UIKit

class CameraMergingViewController: UIViewController {
    @IBOutlet var imageViews: [MergingImageView]!
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    // TODO: Should remove '!'
    private var viewModel: CameraMergingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViews.first?.onPositionChanged = { [weak self] position in
            self?.viewModel.updatePosition(at: 0, position: position)
            self?.updateOverlapEffect()
        }
        imageViews.last?.onPositionChanged = { [weak self] position in
            self?.viewModel.updatePosition(at: 1, position: position)
            self?.updateOverlapEffect()
        }
        
        self.viewModel = .init(
            self,
            initialStatus: imageViews.map({
                .init(image: $0.image, frame: $0.frame)
            }),
            previewSize: previewImageView.frame.size
        )
    }
    
    @IBAction func refreshButtonTouchUpInside(_ sender: UIButton) {
        viewModel.callEffectInitialStatus()
    }
    
    @IBAction func zPositionFlipButtonTouchUpInside(_ sender: UIButton) {
        viewModel.swapZPosition()
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmButtonTouchUpInside(_ sender: UIButton) {
        // TODO: SAVE & Toast & Move Main
    }
    
    private func setStatus(_ status: [CameraImageViewStatus]) {
        guard status.count >= 2 else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.imageViews.first?.image = status[0].image
            self?.imageViews.first?.frame = status[0].frame
            self?.imageViews.last?.image = status[1].image
            self?.imageViews.last?.frame = status[1].frame
        }
    }
    private func setPositions() {
        DispatchQueue.main.async { [weak self] in
            (self?.imageViews.first as? UIImageView)?.layer.zPosition = self?.imageViews.first?.viewOrder == .top ? 1 : 0
            (self?.imageViews.last as? UIImageView)?.layer.zPosition = self?.imageViews.last?.viewOrder == .top ? 1 : 0
        }
    }
    
    private func updateOverlapEffect() {
        guard let topView = imageViews.first(where: { $0.viewOrder == .top }),
              let bottomView = imageViews.first(where: { $0.viewOrder == .bottom }) else { return }
        
        let intersection = topView.frame.intersection(bottomView.frame)
        
        // 겹치지 않으면 마스크 제거
        guard !intersection.isNull else {
            topView.layer.mask = nil
            return
        }
        
        // intersection을 topView의 로컬 좌표로 변환
        let localRect = CGRect(
            x: intersection.minX - topView.frame.minX,
            y: intersection.minY - topView.frame.minY,
            width: intersection.width,
            height: intersection.height
        )
        
        let renderer = UIGraphicsImageRenderer(size: topView.bounds.size)
        let maskImage = renderer.image { ctx in
            let cgCtx = ctx.cgContext
            
            // 기본: 전체 영역 완전 불투명
            cgCtx.setFillColor(UIColor.white.cgColor)
            cgCtx.fill(topView.bounds)
            
            // 겹치는 영역만 반투명으로 덮어쓰기 (.copy = alpha 직접 지정)
            cgCtx.setBlendMode(.copy)
            cgCtx.setFillColor(UIColor(white: 1.0, alpha: 0.4).cgColor)
            cgCtx.fill(localRect)
        }
        
        let maskLayer = CALayer()
        maskLayer.frame = topView.bounds
        maskLayer.contents = maskImage.cgImage
        topView.layer.mask = maskLayer
    }

}

extension CameraMergingViewController: CameraMergingViewModel.Observer {
    func didEffect(_ effect: CameraMergingViewModel.Effect) {
        switch effect {
        case .onCallInitialStatus(let status):
            setStatus(status)
            
        case .onSwapZPosition(let orders):
            guard orders.count >= 2 else {
                return
            }
            
            self.imageViews.first?.viewOrder = orders[0]
            self.imageViews.last?.viewOrder = orders[1]
            self.setPositions()
            self.updateOverlapEffect()
            
        case .onStatusChanged(let image):
            self.previewImageView.image = image
        }
    }
}

class MergingImageView: UIImageView {
    var viewOrder: CameraMergingViewModel.ImageOrder = .top
    var onPositionChanged: ((CGPoint) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isUserInteractionEnabled = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: superview)
        self.center = location
        self.onPositionChanged?(location)
    }
}

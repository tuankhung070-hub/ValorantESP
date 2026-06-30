import UIKit

class ESPRenderer: NSObject {
    static let shared = ESPRenderer()
    private var players: [PlayerESP] = []
    private var renderTimer: Timer?
    
    override init() {
        super.init()
        renderTimer = Timer.scheduledTimer(timeInterval: 0.016, target: self, selector: #selector(renderLoop), userInfo: nil, repeats: true)
    }
    
    func updatePlayers(_ newPlayers: [PlayerESP]) {
        players = newPlayers
    }
    
    @objc private func renderLoop() {
        guard let window = UIApplication.shared.windows.first(where: { $0.windowLevel == .statusBar + 1 }),
              let view = window.rootViewController?.view else { return }
        view.layer.sublayers?.removeAll(where: { $0.name == "ESPBox" })
        for player in players {
            drawESPBox(for: player, in: view)
        }
    }
    
    private func drawESPBox(for player: PlayerESP, in view: UIView) {
        let rect = player.rect
        let boxLayer = CAShapeLayer()
        boxLayer.name = "ESPBox"
        boxLayer.path = UIBezierPath(rect: rect).cgPath
        boxLayer.strokeColor = UIColor.green.cgColor
        boxLayer.lineWidth = 2.0
        boxLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(boxLayer)
        
        let healthWidth = rect.width
        let healthHeight: CGFloat = 4
        let healthX = rect.origin.x
        let healthY = rect.origin.y - healthHeight - 2
        let healthBackground = CALayer()
        healthBackground.name = "ESPBox"
        healthBackground.frame = CGRect(x: healthX, y: healthY, width: healthWidth, height: healthHeight)
        healthBackground.backgroundColor = UIColor.darkGray.cgColor
        view.layer.addSublayer(healthBackground)
        let healthFill = CALayer()
        healthFill.name = "ESPBox"
        let fillWidth = healthWidth * CGFloat(player.health) / 100.0
        healthFill.frame = CGRect(x: healthX, y: healthY, width: fillWidth, height: healthHeight)
        healthFill.backgroundColor = UIColor.green.cgColor
        view.layer.addSublayer(healthFill)
        
        let distanceText = "\(Int(player.distance))m"
        let label = UILabel()
        label.text = distanceText
        label.textColor = .white
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
        label.sizeToFit()
        label.frame.origin = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.height + 2)
        view.addSubview(label)
        
        let nameLabel = UILabel()
        nameLabel.text = player.name
        nameLabel.textColor = .cyan
        nameLabel.font = UIFont.boldSystemFont(ofSize: 10)
        nameLabel.sizeToFit()
        nameLabel.frame.origin = CGPoint(x: rect.origin.x, y: rect.origin.y - 20)
        view.addSubview(nameLabel)
    }
}

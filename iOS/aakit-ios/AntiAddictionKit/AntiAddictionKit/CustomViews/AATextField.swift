
import UIKit

class AATextField: UITextField {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawUnderline()
    }
    
    private func drawUnderline() {
        //下划线
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(RGBA(245, 245, 245, 1).cgColor)
        context?.fill(cgRect(0, frame.height - 1, frame.width, 1))
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 10, dy: 0))
    }
    
//    override func drawPlaceholder(in rect: CGRect) {
//        super.drawPlaceholder(in: rect.insetBy(dx: 10, dy: 0))
//    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }

}


import UIKit

/**
*  UIView extension to ease creating Auto Layout Constraints
*/
extension UIView {


    // MARK: - Fill
    @discardableResult
    public func fillSuperView(_ edges: UIEdgeInsets = UIEdgeInsets.zero) -> [NSLayoutConstraint] {

        var constraints: [NSLayoutConstraint] = []

        if let superview = superview {

            let topConstraint = addTopConstraint(toView: superview, constant: edges.top)
            let leadingConstraint = addLeadingConstraint(toView: superview, constant: edges.left)
            let bottomConstraint = addBottomConstraint(toView: superview, constant: -edges.bottom)
            let trailingConstraint = addTrailingConstraint(toView: superview, constant: -edges.right)

            constraints = [topConstraint, leadingConstraint, bottomConstraint, trailingConstraint]
        }

        return constraints
    }


    // MARK: - Leading / Trailing
    @discardableResult
    public func addLeadingConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .leading, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .leading, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }

    
    @discardableResult
    public func addTrailingConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .trailing, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .trailing, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Left
    @discardableResult
    public func addLeftConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .left, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .left, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Right
    @discardableResult
    public func addRightConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .right, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .right, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Top
    @discardableResult
    public func addTopConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .top, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .top, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Bottom
    @discardableResult
    public func addBottomConstraint(toView view: UIView?, attribute: NSLayoutConstraint.Attribute = .bottom, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .bottom, toView: view, attribute: attribute, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Center XY
    @discardableResult
    public func addCenterXYConstraint(toView view: UIView?, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> [NSLayoutConstraint] {

        let constraint1 = createConstraint(attribute: .centerX, toView: view, attribute: .centerX, relation: relation, constant: constant)
        let constraint2 = createConstraint(attribute: .centerY, toView: view, attribute: .centerY, relation: relation, constant: constant)
        let constraints = [constraint1, constraint2]
        addConstraintsToSuperview(constraints)

        return constraints
    }
    
    // MARK: - Center X
    @discardableResult
    public func addCenterXConstraint(toView view: UIView?, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .centerX, toView: view, attribute: .centerX, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Center Y
    @discardableResult
    public func addCenterYConstraint(toView view: UIView?, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .centerY, toView: view, attribute: .centerY, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }
    
    // MARK: - Width+Height
    @discardableResult
    public func addWidthAndHeightConstraint(toView view: UIView? = nil, relation: NSLayoutConstraint.Relation = .equal, width: CGFloat = 0.0, height: CGFloat = 0.0) -> [NSLayoutConstraint] {

        let constraint1 = createConstraint(attribute: .width, toView: view, attribute: .width, relation: relation, constant: width)
        let constraint2 = createConstraint(attribute: .height, toView: view, attribute: .height, relation: relation, constant: height)
        let constraints = [constraint1, constraint2]
        addConstraintsToSuperview(constraints)

        return constraints
    }


    // MARK: - Width
    @discardableResult
    public func addWidthConstraint(toView view: UIView? = nil, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .width, toView: view, attribute: .width, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }


    // MARK: - Height
    @discardableResult
    public func addHeightConstraint(toView view: UIView? = nil, relation: NSLayoutConstraint.Relation = .equal, constant: CGFloat = 0.0) -> NSLayoutConstraint {

        let constraint = createConstraint(attribute: .height, toView: view, attribute: .height, relation: relation, constant: constant)
        addConstraintToSuperview(constraint)

        return constraint
    }
    
    // MARK: - Remove All Constraints
    public func removeAllConstraints() {
        removeConstraints(constraints)
    }


    // MARK: - Private
    /// Adds an NSLayoutConstraint to the superview
    fileprivate func addConstraintToSuperview(_ constraint: NSLayoutConstraint) {

        translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraint(constraint)
    }
    /// Adds [NSLayoutConstraint] to the superview
    fileprivate func addConstraintsToSuperview(_ constraints: [NSLayoutConstraint]) {

        translatesAutoresizingMaskIntoConstraints = false
        superview?.addConstraints(constraints)
    }

    /// Creates an NSLayoutConstraint using its factory method given both views, attributes a relation and offset
    fileprivate func createConstraint(attribute attr1: NSLayoutConstraint.Attribute, toView: UIView?, attribute attr2: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation, constant: CGFloat) -> NSLayoutConstraint {

        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attr1,
            relatedBy: relation,
            toItem: toView,
            attribute: attr2,
            multiplier: 1.0,
            constant: constant)

        return constraint
    }
}

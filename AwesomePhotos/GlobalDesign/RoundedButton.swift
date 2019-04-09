import UIKit

@IBDesignable class RoundedButton : UIButton
{
    @IBInspectable var cornerRadius : CGFloat = 15 {
        didSet
        {
            refreshCorners(value: cornerRadius)
        }
    }
    
    @IBInspectable var backgroundImageColor : UIColor = UIColor.init(red: 0, green: 122/155.0, blue: 255/255.0, alpha: 1)
        {
        didSet{
            refreshColor(color: backgroundImageColor)
        }
    }
    
    func refreshCorners(value : CGFloat)
    {
        layer.cornerRadius = value
    }
    
    //Used to create a blank image and later set it to the prefered color
    func createImage(color : UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0.0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }
    
    func refreshColor(color : UIColor)
    {
        let image = createImage(color: color)
        setBackgroundImage(image, for: UIControl.State.normal)
        clipsToBounds = true
    }
    
    //These methods needs to be overwritten, because when it compiles it will look differently
    // This is for programmaticly created buttons
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    //This is for Storyboard/.xib files
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    //This is called within the Storyboard editor itself for rendering IBDesignable controls
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit()
    {
        refreshCorners(value: cornerRadius)
        refreshColor(color: backgroundImageColor)
    }
}

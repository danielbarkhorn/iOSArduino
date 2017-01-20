

import UIKit
import CoreBluetooth
import QuartzCore

/// The option to add a \n or \r or \r\n to the end of the send message
enum MessageOption: Int {
    case noLineEnding,
         newline,
         carriageReturn,
         carriageReturnAndNewline
}

/// The option to add a \n to the end of the received message (to make it more readable)
enum ReceivedMessageOption: Int {
    case none,
         newline
}

final class SerialViewController: UIViewController, UITextFieldDelegate, BluetoothSerialDelegate {

//MARK: IBOutlets
    

    
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var contrastLabel: UILabel!
    
    var redSwitchBool = false
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var redLabel: UILabel!
    
    var greenSwitchBool = false
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var greenLabel: UILabel!
    
    var blueSwitchBool = false
    @IBOutlet weak var blueSwitch: UISwitch!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var blueLabel: UILabel!
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!


//MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init serial
        serial = BluetoothSerial(delegate: self)
        serial.writeType = UserDefaults.standard.bool(forKey: WriteWithResponseKey) ? .withResponse : .withoutResponse
        

        reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SerialViewController.reloadView), name: NSNotification.Name(rawValue: "reloadStartViewController"), object: nil)
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        
        if serial.isReady {
            navItem.title = serial.connectedPeripheral!.name
            barButton.title = "Disconnect"
            barButton.tintColor = UIColor.red
            barButton.isEnabled = true
        } else if serial.centralManager.state == .poweredOn {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = true
        } else {
            navItem.title = "Bluetooth Serial"
            barButton.title = "Connect"
            barButton.tintColor = view.tintColor
            barButton.isEnabled = false
        }
    }

    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        reloadView()
        //        dismissKeyboard()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidChangeState() {
        reloadView()
        if serial.centralManager.state != .poweredOn {
//            dismissKeyboard()
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    
//MARK: Sliders

    @IBAction func contrastValueChanged(_ sender: Any) {
        serial.sendMessageToDevice("C"+String(Int(contrastSlider.value)))
        contrastLabel.text = String(Int(contrastSlider.value))+"%"
    }
    @IBAction func redValueChanged(_ sender: Any)
    {
        serial.sendMessageToDevice("R"+String(Int(redSlider.value)))
        redLabel.text = String(Int(redSlider.value))+"%"
    }
    @IBAction func greenValueChanged(_ sender: Any)
    {
        serial.sendMessageToDevice("G"+String(Int(greenSlider.value)))
        greenLabel.text = String(Int(greenSlider.value))+"%"
    }
    @IBAction func blueValueChanged(_ sender: Any)
    {
        serial.sendMessageToDevice("B"+String(Int(blueSlider.value)))
        blueLabel.text = String(Int(blueSlider.value))+"%"
    }
    

//MARK: Switches
    
    @IBAction func redSwitchValueChanged(_ sender: Any) {
        if(redSwitch.isOn)
        {
            for i in 0 ..< 20
            {
            serial.sendMessageToDevice("r01")
            }
            //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScannerViewController.connectTimeOut), userInfo: nil, repeats: false)
//            if(!redSwitchBool)
//            {
//                redSwitch.setOn(false, animated: true)
//            }
        }
        else
        {
            for i in 0 ..< 20
            {
            serial.sendMessageToDevice("r00")
            }
            //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScannerViewController.connectTimeOut), userInfo: nil, repeats: false)
//            if(redSwitchBool)
//            {
//                redSwitch.setOn(true, animated: true)
//            }
        }
        
    }
    
    @IBAction func greenSwitchValueChanged(_ sender: Any)
    {
        if(greenSwitch.isOn)
        {
            for i in 0 ..< 20
            {
            serial.sendMessageToDevice("g01")
            }
        }
        else
        {
            for i in 0 ..< 20
            {
            serial.sendMessageToDevice("g00")
            }
        }
    }
    @IBAction func blueSwitchValueChanged(_ sender: Any)
    {
        if(blueSwitch.isOn)
        {
            for i in 0 ..< 20
            {
            serial.sendMessageToDevice("b01")
            }
        }
        else{
            for i in 0 ..< 20
            {
            serial.sendMessageToDevice("b00")
            }
        }
    }
//MARK: IBActions

    @IBAction func barButtonPressed(_ sender: AnyObject) {
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }
    
//MARK: Serial Delegate Bluetooth Methdods
    func serialDidReceiveString(_ message: String)
    {
        if(message[message.startIndex] == "r")
        {
            if(message[message.endIndex] == "1")
            {
                redSwitchBool = true;
                return;
            }
            else
            {
                redSwitchBool = false;
                return;
            }
        }
        if(message[message.startIndex] == "g")
        {
            if(message[message.endIndex] == "1")
            {
                greenSwitchBool = true;
                return;
            }
            else
            {
                greenSwitchBool = false;
                return;
            }
        }
        if(message[message.startIndex] == "b")
        {
            if(message[message.endIndex] == "1")
            {
                blueSwitchBool = true;
                return;
            }
            else
            {
                blueSwitchBool = false;
                return;
            }
        }
    }
    func doNothing()
    {
        return;
    }
}


























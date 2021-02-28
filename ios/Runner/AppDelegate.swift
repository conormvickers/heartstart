import UIKit
import Flutter
import CoreBluetooth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/battery",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Note: this method is invoked on the UI thread.
      guard call.method == "getBatteryLevel" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.receiveBatteryLevel(result: result)
    })

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            //call any function
        self.ble = BLE()
        self.ble.channel = batteryChannel
        batteryChannel.invokeMethod("test", arguments: nil, result: nil)

    }


    print("here")


    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    var ble: BLE!

    func receiveBatteryLevel(result: FlutterResult) {
       // self.ble = BLE()
        result(1)
    }
}


class BLE:  NSObject, CBPeripheralManagerDelegate {

    var peripheralManager : CBPeripheralManager!
    var channel: FlutterMethodChannel!


    required override init() {
        print("loading")
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

        var consoleLog = ""

        switch peripheral.state {
        case .poweredOff:
            consoleLog = "BLE is powered off"
        case .poweredOn:
            consoleLog = "BLE is poweredOn"
        case .resetting:
            consoleLog = "BLE is resetting"
        case .unauthorized:
            consoleLog = "BLE is unauthorized"
        case .unknown:
            consoleLog = "BLE is unknown"
        case .unsupported:
            consoleLog = "BLE is unsupported"
        default:
            consoleLog = "default"
        }
        print(consoleLog)
        let WR_UUID = CBUUID(string: "a228b618-d7a0-4ec7-87a5-a7b4e6b865cf")
        let WR_PROPERTIES: CBCharacteristicProperties = .write
        let WR_PERMISSIONS: CBAttributePermissions = .writeable


            if (peripheral.state == .poweredOn) {

                let serialService = CBMutableService(type: WR_UUID, primary: true)
                let writeCharacteristics = CBMutableCharacteristic(type: WR_UUID,
                                                 properties: WR_PROPERTIES, value: nil,
                                                 permissions: WR_PERMISSIONS)
                serialService.characteristics = [writeCharacteristics]
                peripheralManager.add(serialService)

                print("added service")
                let advertisementData = [CBAdvertisementDataLocalNameKey: "a228b618Some iPhone", CBAdvertisementDataServiceDataKey: "a228b618"]
                peripheralManager.startAdvertising(advertisementData)

                print("done")
                print(peripheralManager.isAdvertising)

            }
        }


        func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {

            for request in requests {
                if let value = request.value {

                    //here is the message text that we receive, use it as you wish.
                    let messageText = String(data: value, encoding: String.Encoding.utf8) as String?
                    print(messageText)
                    channel.invokeMethod(messageText ?? "no string found", arguments: nil, result: nil)
                }
                self.peripheralManager.respond(to: request, withResult: .success)
            }
        }
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?)
    {
        if let error = error {
            print(error)
            return
        }

        print("service: \(service)” ")
    }

}

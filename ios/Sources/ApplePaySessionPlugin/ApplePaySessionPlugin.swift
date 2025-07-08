import Foundation
import Capacitor
import PassKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(ApplePaySessionPlugin)
public class ApplePaySessionPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "ApplePaySessionPlugin"
    public let jsName = "ApplePaySession"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getSession", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "initiatePayment", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = ApplePaySession()
   
    private var currentCall: CAPPluginCall?
    
    @objc func getSession(_ call: CAPPluginCall){
        let validator = ApplePaySessionValidator(getConfig: self.getConfig())
        self.currentCall = call
        
        do {
            let request = try validator.validateAndCreateRequest(from: call)
            print("[ApplePay Session] Initiating Apple Pay session")
            implementation.getSession(request: request, delegate: self)
           } catch let error as ApplePayValidationError {
               call.reject(error.message, error.code, nil)
               currentCall = nil
           } catch let error as ApplePayProcessError {
               call.reject(error.message, error.code, nil)
               currentCall = nil
           } catch {
               call.reject("An error ocurred while validating parameters", ApplePayCode.UKNOWN_ERROR, nil)
               currentCall = nil
           }
    }
    
    @objc func initiatePayment(_ call: CAPPluginCall){
        let validator = ApplePaySessionValidator(getConfig: self.getConfig())
        self.currentCall = call
        
        do {
            let request = try validator.validateAndCreateRequest(from: call)
            let paymentInfo = try validator.validateAndCreatePaymentRequest(from: call)
            print("[ApplePay Session] Request And Payment info correct; initiating Apple Pay payment")
            implementation.initiatePayment(request: request, paymentInfo: paymentInfo, delegate: self)
           } catch let error as ApplePayValidationError {
               call.reject(error.message, error.code, nil)
               currentCall = nil
           } catch let error as ApplePayProcessError {
               call.reject(error.message, error.code, nil)
               currentCall = nil
           } catch {
               call.reject("An error ocurred while validating parameters", ApplePayCode.UKNOWN_ERROR, nil)
               currentCall = nil
           }
    }
}

extension ApplePaySessionPlugin: ApplePayManagerDelegate {
    
    public func applePayDidAuthorize(token: String) {
        print("[ApplePay Session] Apple Pay session authorized")
        
        currentCall?.resolve(["token": token])
        currentCall = nil
    }
    
    public func applePayDidFail(message: String, code: String) {
        print("[ApplePay Session] Apple Pay session failed: \(message)")
        currentCall?.reject(message, code)
        currentCall = nil
    }
    
    public func applePayDidFinish( message: String?, code: String?) {
        if (message != nil) && (code != nil) {
            currentCall?.reject(message!, code!)
            currentCall = nil
        }
        print("[ApplePay Session] Apple Pay session finished")
    }
    
    public func applePayDidPaySuccessfully(response: [String: Any]) {
        
        self.currentCall?.resolve(["response": response])
 
        self.currentCall = nil

    }
    
    public func applePayDidPayError(error: String) {
        self.currentCall?.reject(error, ApplePayCode.APPLEPAY_ERROR)
        self.currentCall = nil
    }
}

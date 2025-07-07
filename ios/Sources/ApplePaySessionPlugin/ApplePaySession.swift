import Foundation
import PassKit


@objc public class ApplePaySession: NSObject {
    weak var delegate: ApplePayManagerDelegate?
    private var paymentWasAuthorized: Bool = false
    
    // Properties for backend communication
    private var paymentInfo: ApplePayPaymentRequest?
    
        
    @objc public func getSession(request: ApplePayRequest, delegate: ApplePayManagerDelegate){
        self.delegate = delegate
        self.paymentWasAuthorized = false
        
        // TODO: Assign backendUrl and authToken here from the request
        // self.backendUrl = URL(string: "your_backend_url_from_request")
        // self.authToken = "your_auth_token_from_request"
        
        guard PKPaymentAuthorizationController.canMakePayments() else {
            delegate.applePayDidFail(message: "Apple Pay is not available on this device", code: "applepay_not_available")
            return
        }
        
        let paymentRequest = createPaymentRequest(request: request)
        let controller = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        controller.delegate = self
        controller.present(completion: { success in
            if(!success){
                let error = ApplePayProcessError.problemOpeningPaymentSheet;
                delegate.applePayDidFail(message: error.message, code: error.code)
                self.delegate = nil
            }
            return
        })
         
    }
    
    @objc public func initiatePayment(request: ApplePayRequest, paymentInfo: ApplePayPaymentRequest, delegate: ApplePayManagerDelegate){
        self.paymentInfo = paymentInfo;
        self.getSession(request: request, delegate: delegate)
    }
    
    private func createPaymentRequest(request: ApplePayRequest) -> PKPaymentRequest {
        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = request.merchantId
        paymentRequest.supportedNetworks = request.supportedNetworks
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = request.countryCode
        paymentRequest.currencyCode = request.currencyCode
        paymentRequest.paymentSummaryItems = request.items
        return paymentRequest
    }
    
    private func requestPayment(session: String, completion: @escaping (ApplePayPaymentResponse) -> Void){
        print("[ApplePay Session] Requesting payment...")
        let sessionRequest = ApplePaySessionRequest()
        let url = URL(string:self.paymentInfo!.url)
        var body = self.paymentInfo!.body
        let sessionIn = paymentInfo!.sessionIn
        body[sessionIn] = session
        
        sessionRequest.post(url: url!, body: body, headers: self.paymentInfo!.headers){ result in
            switch result{
            case .success(let data):
                completion(ApplePayPaymentResponse(data:data, success: true))
            case .failure(let error):
                completion(ApplePayPaymentResponse(error: (error as? NetworkError)?.messagge ?? "A error ocurred", success: false))
            }
        }
    }

}

extension ApplePaySession:PKPaymentAuthorizationControllerDelegate{
    public func paymentAuthorizationControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationController) {
        //This method is mandatory and runs before the user approves the payment.
        print("[ApplePay Session] Wait for user response...")
       }
   
   public func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
       controller.dismiss(completion: nil)
       if !paymentWasAuthorized {
           delegate?.applePayDidFail(message: "The user canceled the payment.", code: "payment_canceled")
       }else{
           delegate?.applePayDidFinish(message: nil, code: nil)
       }
       
   }
   
   public func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                              didAuthorizePayment payment: PKPayment,
                                              handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
       paymentWasAuthorized = true
       let paymentToken = payment.token.paymentData.base64EncodedString()
      if(paymentToken.isEmpty){
           self.delegate?.applePayDidFail(message: "Was not able to obtain a payment token.", code: "payment_failed")
           completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
           return
       }

       if(self.paymentInfo !== nil){
           self.requestPayment(session: paymentToken){ [weak self] response in
               if(response.success){
                   self?.delegate?.applePayDidPaySuccessfully(response: response.data!)
                   completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                   return
               }
               
               self?.delegate?.applePayDidPayError(error: response.error!)
               completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
               
           }
           return
       }else{
           self.delegate?.applePayDidAuthorize(token: paymentToken)
           completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
       }
       
       
   }
}



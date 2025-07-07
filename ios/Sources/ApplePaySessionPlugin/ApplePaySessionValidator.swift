import Capacitor
import PassKit
import Foundation

public class ApplePaySessionValidator {
    private var getConfig: PluginConfig
    
    init(getConfig: PluginConfig){
        self.getConfig = getConfig
    }

    public func validateAndCreateRequest(from call: CAPPluginCall) throws -> ApplePayRequest {

        guard let merchantId = call.getString("merchantId") ?? getConfig.getString("merchantId"), !merchantId.isEmpty else {
            throw ApplePayValidationError.missingMerchantId
        }
        
        let supportedNetworksArray = call.getArray("supportedNetworks") as? [String] ??  getConfig.getArray("supportedNetworks") as? [String] ?? []
        guard !supportedNetworksArray.isEmpty else {
            throw ApplePayValidationError.emptySupportedNetworks
        }
        
        let validNetworks = convertToPaymentNetworks(supportedNetworksArray)
        guard !validNetworks.isEmpty else {
            throw ApplePayValidationError.noValidNetworks
        }
        
        let countryCode = call.getString("countryCode") ?? getConfig.getString("countryCode") ?? ""
        guard countryCode.count == 2 else {
            throw ApplePayValidationError.invalidCountryCode
        }
        
        let currencyCode = call.getString("currencyCode") ?? getConfig.getString("currencyCode") ?? ""
        guard currencyCode.count == 3 else {
            throw ApplePayValidationError.invalidCurrencyCode
        }
        
        let itemsArray: [[String: String]] = call.getArray("items") as? [[String: String]] ?? []
        guard !itemsArray.isEmpty else {
            throw ApplePayValidationError.emptyItems
        }
        
        let validItems = convertToPaymentItems(itemsArray)
        
        return ApplePayRequest(
            merchantId: merchantId,
            supportedNetworks: validNetworks,
            countryCode: countryCode,
            currencyCode: currencyCode,
            items: validItems
        )
    }
    
    public func validateAndCreatePaymentRequest(from call: CAPPluginCall) throws -> ApplePayPaymentRequest {
        guard let url = call.getString("url"), !url.isEmpty else {
            throw ApplePayValidationError.missingURL
        }
        
        guard let body = call.getObject("body") else {
            throw ApplePayValidationError.missingBody
        }
        
        guard let sessionin = call.getString("sessionIn") else {
            throw ApplePayValidationError.missingBody
        }
        
        let headers = call.getObject("headers") as? [String: String] ?? nil
        
        
        
        return ApplePayPaymentRequest(
            url: url,
            sessionIn: sessionin,
            body: body,
            headers: headers
        )
    }
    
    
    private func convertToPaymentNetworks(_ networkStrings: [String]) -> [PKPaymentNetwork] {
        var networks: [PKPaymentNetwork] = []
        
        for networkString in networkStrings {
            switch networkString.lowercased() {
            case "visa":
                networks.append(.visa)
            case "mastercard", "masterCard":
                networks.append(.masterCard)
            case "amex":
                networks.append(.amex)
            case "discover":
                networks.append(.discover)
            default:
                print("[ApplePay Session] Network not supported: \(networkString)")
            }
        }
        
        return networks
    }
    
    private func convertToPaymentItems(_ paymentItems: [[String: String]]) -> [PKPaymentSummaryItem] {
        var summaryItems: [PKPaymentSummaryItem] = []
        
        for item in paymentItems {
            let quantity = 100 * 10
            let amount = NSDecimalNumber(string: item["amount"]!, )
            print("AMOUNT: \(amount)")
            let summaryItem = PKPaymentSummaryItem(label: item["label"]!, amount: 100.00 )
            summaryItems.append(summaryItem)
        }
        
        return summaryItems
    }
    
    
}


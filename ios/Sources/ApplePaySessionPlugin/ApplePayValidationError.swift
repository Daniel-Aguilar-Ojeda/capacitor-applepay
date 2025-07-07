/*public struct ApplePayCode {
    static var MISS_MERCHANT_ID: return "missing_merchant_id"
    static var MISS_AMOUNT: return "missing_amount"
    static var MISS_URL: return "missing_url"
    static var MISS_BODY: return "missing_body"
    static var MISS_SESSION_IN: return "missing_session_in"
    
    /*case .invalidAmount: return "invalid_amount"
    case .invalidCountryCode: return "invalid_country_code"
    case .invalidCurrencyCode: return "invalid_currency_code"
    case .emptySupportedNetworks: return "empty_supported_networks"
    case .emptyItems: return "empty_items"
    case .noValidNetworks: return "no_valid_networks"
     */

}
 */
public enum ApplePayValidationError: Error {
    case missingMerchantId
    case missingAmount
    case invalidAmount
    case invalidCountryCode
    case invalidCurrencyCode
    case emptySupportedNetworks
    case emptyItems
    case noValidNetworks
    case missingURL
    case missingBody
    case missinSesionIn
    
    var code: String {
        switch self {
        case .missingMerchantId: return "missing_merchant_id"
        case .missingAmount: return "missing_amount"
        case .invalidAmount: return "invalid_amount"
        case .invalidCountryCode: return "invalid_country_code"
        case .invalidCurrencyCode: return "invalid_currency_code"
        case .emptySupportedNetworks: return "empty_supported_networks"
        case .emptyItems: return "empty_items"
        case .noValidNetworks: return "no_valid_networks"
        case .missingURL: return "missing_url"
        case .missingBody: return "missing_body"
        case .missinSesionIn: return "missing_session_in"
        }
    }
    
    var message: String {
        switch self {
        case .missingMerchantId:
            return "merchantId is required."
        case .missingAmount:
            return "amount is required."
        case .invalidAmount:
            return "amount must be greater than zero."
        case .invalidCountryCode:
            return "countryCode must be a valid ISO 3166 code (ej: 'US', 'MX')."
        case .invalidCurrencyCode:
            return "currencyCode must be a valid ISO 4217 currency code (ej: 'USD', 'MXN')."
        case .emptySupportedNetworks:
            return "supportedNetworks must not be empty."
        case .emptyItems:
            return "Payment items must not be empty."
        case .noValidNetworks:
            return "No valid payment networks were found in supportedNetworks."
        case .missingURL:
            return "url is required."
        case .missingBody:
            return "body is required."
        case .missinSesionIn:
            return "sessionIn is required."
        }
    }
}

public enum ApplePayProcessError: Error {
    case problemOpeningPaymentSheet
    case unknown
    
    var code : String {
        switch self {
        case .problemOpeningPaymentSheet:
            return "problem_opening_paymentsheet"
        case .unknown:
            return "uknown_error"
        }
    }
    
    var message: String {
        switch self {
        case .problemOpeningPaymentSheet:
            return "Problem opening Apple Pay sheet."
        case .unknown:
            return "Unknown error."
        }
    }
}


public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case serializationError(Error)
    case serverError(String)
    
    var messagge: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response"
        case .serializationError(let error):
            return "Serialization error: \(error.localizedDescription)"
        case .serverError(let error):
            return error
            
        }
    }
}

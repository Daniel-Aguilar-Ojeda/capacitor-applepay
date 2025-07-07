import PassKit

@objc public class ApplePayRequest: NSObject {
   let merchantId: String
   let supportedNetworks: [PKPaymentNetwork]
   let countryCode: String
   let currencyCode: String
   let items: [PKPaymentSummaryItem]

    @objc public init(merchantId: String, supportedNetworks: [PKPaymentNetwork], countryCode: String, currencyCode: String, items: [PKPaymentSummaryItem]) {
       self.merchantId = merchantId
       self.supportedNetworks = supportedNetworks
       self.countryCode = countryCode
       self.currencyCode = currencyCode
       self.items = items
   }
}

@objc public class ApplePayPaymentRequest: NSObject {
    let url: String
    let sessionIn: String
    let headers: [String: String]?
    let body: [String: Any]
    
    @objc public init(url: String, sessionIn: String,body: [String: Any], headers: [String: String]? = nil ) {
        self.url = url
        self.sessionIn = sessionIn
        self.headers = headers
        self.body = body
    }
    
}

@objc public class ApplePayPaymentResponse: NSObject {
    let data: [String: Any]?
    let error: String?
    let success: Bool
    
    @objc public init(data: [String: Any]? = nil, error: String? = nil, success: Bool = false) {
        self.data = data
        self.error = error
        self.success = success
    }
    
    
}


public class ApplePaySessionRequest {
    
   /**
     Performs a POST request to a specified URL.
     - Parameters:
       - url: The destination URL.
       - body: A dictionary representing the JSON body to be sent.
       - headers: An optional dictionary of headers to be added to the request.
       - completion: A closure that is called when the request is complete, returning a `Result` with either the response `[String: Any]` or a `NetworkError`.
     */
    public func post(
        url: URL,
        body: [String: Any],
        headers: [String: String]?,
        completion: @escaping (Result<[String: Any]?, Error>) -> Void
    ) {
        print("[ApplePay Session] Iniciando post request")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in headers ?? [:] {
            request.setValue(value, forHTTPHeaderField: key)
        }

        
        // Serialize body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(NetworkError.serializationError(error)))
            return
        }
        
        // Create and start the data task
        print("[ApplePay Session] Iniciando request...")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Ensure we switch back to the main thread to return the result,
            // as URLSession completion handlers run on a background thread.
            DispatchQueue.main.async {
                print("[ApplePay Session] Request completado...")
                let dataJson = self.dataToJSONObject( data ?? Data()) ?? [:]
                
                if let error = error {
                    completion(.failure(NetworkError.requestFailed(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }

                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("[ApplePay Session] Request no exitoso: \(httpResponse.statusCode)")
                    let errorResponse = ["statusCode": httpResponse.statusCode, "error":dataJson]
                    completion(.failure(NetworkError.serverError(self.toJSONString(dataResponse: errorResponse))))
                    return
                }
                print("[ApplePay Session] Request exitoso...")
                completion(.success(dataJson))
            }
        }
        
        task.resume()
    }
    
    private func toJSONString(dataResponse: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dataResponse, options: [])
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("[ApplePay Session] An error occurred while converting data to JSON string: \(error)")
            return "{}"
        }
    }
    

    
    private func dataToJSONObject(_ data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("[ApplePay Session] An error occurred while converting data to JSON object: \(error)")
            let jsonString = String(data: data, encoding: .utf8) ?? "{}"
            return ["response": jsonString]
        }
    }
}

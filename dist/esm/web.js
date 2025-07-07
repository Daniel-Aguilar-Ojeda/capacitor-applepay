import { WebPlugin } from '@capacitor/core';
class AppleyPayError extends Error {
    constructor(message, code) {
        super(message);
        this.code = "payment_reject";
        this.code = code;
    }
}
export class ApplePaySessionWeb extends WebPlugin {
    async getSession(request) {
        console.log({ request });
        throw new AppleyPayError("Apple Pay is not available on WEB", "applepay_not_available");
    }
    initiatePayment(paymentRequest) {
        console.log({ paymentRequest });
        throw new AppleyPayError("Appl Pay is not available on WEB", "applepay_not_available");
    }
}
//# sourceMappingURL=web.js.map
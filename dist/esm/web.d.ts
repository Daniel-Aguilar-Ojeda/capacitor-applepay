import { WebPlugin } from '@capacitor/core';
import type { ApplePayPayment, ApplePayPaymentResponse, ApplePayRequest, ApplePaySessionPlugin, AppleyPayToken } from './definitions';
export declare class ApplePaySessionWeb extends WebPlugin implements ApplePaySessionPlugin {
    getSession(request: ApplePayRequest): Promise<AppleyPayToken>;
    initiatePayment<Body, Response>(paymentRequest: ApplePayPayment<Body>): Promise<ApplePayPaymentResponse<Response>>;
    completeSession(status: 'success' | 'error'): Promise<void>;
}

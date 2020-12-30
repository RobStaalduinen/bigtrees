import axiosFunc from '../../../mixins/axiosFunctions';

function invoiceSent(estimate, params) {
  return axiosFunc.post(`/estimates/${estimate.id}/invoice_mailouts`, params);
}

function paymentReceived(estimate, params) {
  return axiosFunc.post(`/estimates/${estimate.id}/invoice_receipts`, params);
}
export {
  invoiceSent,
  paymentReceived
}

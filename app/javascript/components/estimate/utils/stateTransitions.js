import axiosFunc from '../../../mixins/axiosFunctions';

function invoiceSent(estimate, params) {
  return axiosFunc.post(`/estimates/${estimate.id}/invoice_mailouts`, params);
}

function setInitialCosts(estimate, params) {
  return axiosFunc.post(`/estimates/${estimate.id}/costs`, params);
}

export {
  invoiceSent,
  setInitialCosts
}

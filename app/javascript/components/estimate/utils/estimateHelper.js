class EstimateHelper {
  constructor(estimate) {
    this.estimate = estimate;
  }

  canSendQuote() {
    return this.estimate.status == 'pending_quote';
  }

  canSchedule() {
    return this.estimate.status == 'quote_sent';
  }

  canSendInvoice() {
    return this.estimate.status == 'work_scheduled';
  }

  canPayInvoice() {
    return this.estimate.status == 'final_invoice_sent';
  }
}

export { EstimateHelper }

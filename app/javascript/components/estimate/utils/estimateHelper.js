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

  canSendFollowup() {
    return (this.estimate.status == 'pending_quote' ||
      this.estimate.status == 'needs_costs' ||
      this.estimate.status == 'quote_sent' ||
      this.estimate.status == 'work_scheduled'
    )
  }
}

export { EstimateHelper }

class EstimateHelper {
  constructor(estimate) {
    this.estimate = estimate;
  }

  canSendQuote() {
    return this.estimate.status == 'pending_quote';
  }

  canSchedule() {
    return this.estimate.status == 'quote_sent' || this.estimate.status == 'pending_permit';
  }

  canSendInvoice() {
    return this.estimate.status == 'work_scheduled';
  }

  canPayInvoice() {
    return this.estimate.status == 'final_invoice_sent';
  }

  canSendFollowup() {
    return true;
  }

  canSendSchedulingEmail() {
    return ['approved', 'work_scheduled', 'work_started', 'work_paused'].includes(this.estimate.status);
  }
}

export { EstimateHelper }

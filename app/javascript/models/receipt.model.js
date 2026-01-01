class Receipt {
  constructor(receipt) {
    this.receipt = receipt;
  }

  canApprove() {
    return this.receipt.state == 'pending' || this.receipt.state == 'rejected';
  }

  canReject() {
    return this.receipt.state == 'pending' || this.receipt.state == 'approved'
  }

  canReset() {
    return this.receipt.state == 'approved' || this.receipt.state == 'rejected'
  }
}

export default Receipt

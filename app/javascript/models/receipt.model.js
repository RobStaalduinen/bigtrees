class Receipt {
  constructor(receipt){
    this.receipt = receipt;
  }

  canApprove() {
    return this.receipt.state == 'pending' || this.receipt.state == 'rejected';
  }

  canReject() {
    return this.receipt.state == 'pending' || this.receipt.state == 'approved'
  }
}

export default Receipt

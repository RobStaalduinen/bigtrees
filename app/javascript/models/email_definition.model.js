class EmailDefinition {
  constructor(email, subject, content){
    if(Array.isArray(email)) {
      this.email = email;
    }
    else {
      this.email = [email];
    }
    this.subject = subject;
    this.content = content
  }
}

export default EmailDefinition

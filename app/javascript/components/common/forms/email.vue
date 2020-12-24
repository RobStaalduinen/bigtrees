<template>
  <div>
    <app-input-field
      v-model='recipient'
      name='email'
      label='Email Address'
      validationRules='required'
    ></app-input-field>

    <app-input-field
      v-model='emailSubject'
      name='subject'
      label='Subject'
      validationRules='required'
    ></app-input-field>

    <b-form-group
      label="Email Body"
      label-for="email-body"
      v-if='editBody'
    >
      <b-form-textarea
        id="textarea"
        name='email-body'
        label='Email Body'
        v-model="emailBody"
        rows="15"
        max-rows="15"
      ></b-form-textarea>
    </b-form-group>
    <div v-else>
      <div id='body-header'><b>Email Body</b> <span @click='editBody=true' id='edit-link'>Edit</span></div>
      <pre class='sample-email-content'>{{ emailBody.trim() }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  props: ['value'],
  data() {
    return {
      recipient: this.value.email,
      emailSubject: this.value.subject,
      emailBody: this.value.content,
      editBody: false
    }
  },
  computed: {
    emailDefinition() {
      return {
        email: this.recipient,
        subject: this.emailSubject,
        content: this.emailBody
      }
    }
  },
  watch: {
    emailDefinition() {
      this.$emit('changed', this.emailDefinition)
    }
  }
}
</script>

<style scoped>
  #email-content {
    overflow: scroll;
  }

  #edit-link {
    color: var(--main-color);
    cursor: pointer;
    font-size: 14px;
  }

  #body-header {
    font-size: 0.8rem;
    display: flex;
    justify-content: space-between;
  }

  .sample-email-content {
    font-size: 10px;
    padding: 8px;
    margin-bottom: 0px;
    white-space: pre-wrap;
  }
</style>

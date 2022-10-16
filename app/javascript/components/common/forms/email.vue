<template>
  <div>
    <div v-for='(recipient, index) in recipients' :key='index' class='email-field-container'>
      <app-input-field
        :value='recipient'
        @input='(payload) => setRecipient(index, payload)'
        name='email'
        label='Email Address'
        validationRules='required'
        class='email-field'
      ></app-input-field>

      <b-icon icon='trash-fill' class='trash-icon' v-if="recipients.length > 1" @click='deleteRecipient(index)'/>
    </div>

    <div id='add-recipient-tag' @click='addRecipient'>+ Add Recipient +</div>

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
      recipients: this.value.email,
      emailSubject: this.value.subject,
      emailBody: this.value.content,
      editBody: false
    }
  },
  computed: {
    emailDefinition() {
      return {
        email: this.recipients,
        subject: this.emailSubject,
        content: this.emailBody
      }
    }
  },
  methods: {
    addRecipient() {
      this.recipients.push(null)
    },
    setRecipient(index, payload){
      this.recipients[index] = payload;
    },
    deleteRecipient(index){
      this.recipients.splice(index, 1);
    }
  },
  watch: {
    emailDefinition() {
      this.$emit('changed', this.emailDefinition)
    },
    value() {
      console.log("VAL CHANGED");
      this.emailBody = this.value.content
    }
  },
  mounted() {
    console.log(this.recipients)
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

  #add-recipient-tag {
    display: flex;
    justify-content: center;
    width: 100%;
    color: var(--main-color);
    font-size: 12px;
  }

  .sample-email-content {
    font-size: 10px;
    padding: 8px;
    margin-bottom: 0px;
    white-space: pre-wrap;
  }

  .email-field-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .email-field {
    width: 100%;
  }

  .trash-icon {
    color: var(--main-color);
    margin-left: 8px;
  }
</style>

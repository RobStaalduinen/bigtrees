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

    <slot name='pre-body'></slot>

    <app-select-field
      v-for='insertable in activeInsertables'
      :key='insertable.key'
      :label='insertable.label'
      :value='insertableSelections[insertable.key]'
      @input='value => setInsertableSelection(insertable.key, value)'
      :name='insertable.key.toLowerCase()'
      :options='insertableOptions(insertable)'
    />

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
import OrganizationEstimateMailer from '../../../content/organizationEstimateMailer';
import { findInsertables, applyInsertables } from '../../../content/emailInsertables';

export default {
  props: ['value', 'initial_recipient', 'template', 'estimate'],
  data() {
    return {
      recipients: [this.initial_recipient],
      emailSubject: '',
      emailBody: '',
      editBody: false,
      baseContent: "",
      insertables: [],
      insertableSelections: {},
      estimateMailer: new OrganizationEstimateMailer(this.$store.state.organization, this.estimate)
    }
  },
  computed: {
    emailDefinition() {
      return {
        email: this.recipients,
        subject: this.emailSubject,
        content: this.emailBody
      }
    },
    activeInsertables() {
      return findInsertables(this.baseContent, this.insertables)
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
    },
    insertableOptions(insertable) {
      return [
        { value: null, text: '' },
        ...(insertable.options || []).map(option => ({ value: option.id, text: option.label }))
      ]
    },
    setInsertableSelection(key, value) {
      this.$set(this.insertableSelections, key, value)
      this.updateEmailDefinition(this.emailSubject)
    },
    updateEmailDefinition(subject = "") {
      let email = this.email != null ? this.email : this.estimate.customer_detail.email

      this.recipients = [email]
      this.emailSubject = subject

      let content = applyInsertables(this.baseContent, this.insertables, this.insertableSelections)

      this.emailBody = this.estimateMailer.defaultContent(content)
    },
    // Not reactive — loadTemplate only awaits it. A failure here must not block the template,
    // so it resolves to an empty list rather than rejecting.
    loadInsertables() {
      this.insertablesLoaded = this.axiosGet('/email_insertables').then(response => {
        this.insertables = response.data.email_insertables;
      }).catch(() => {
        this.insertables = [];
      })

      return this.insertablesLoaded;
    },
    loadTemplate() {
      if(!this.template) { return; }

      // Wait on the insertables so the preview never flashes a raw [KEY] placeholder.
      Promise.all([
        this.insertablesLoaded,
        this.axiosGet(`/email_templates/${this.template}`)
      ]).then(([_insertables, response]) => {
        this.baseContent = response.data.email_template.content;
        this.updateEmailDefinition(response.data.email_template.parsed_subject);
      })
    }
  },
  watch: {
    emailDefinition() {
      this.$emit('changed', this.emailDefinition)
    },
    value() {
      this.emailBody = this.value.content
    },
    template(newKey, oldKey) {
      if(newKey !== oldKey) {
        this.insertableSelections = {};
        this.loadTemplate();
      }
    }
  },
  mounted(){
    this.loadInsertables();
    this.loadTemplate();
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

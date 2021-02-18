<template>
  <div>
    <app-multi-select
        v-model="recipientObjects"
        name='recipient'
        :options="options"
        validationRules='required'
        label='Recipient'
    ></app-multi-select>
      <!-- <multiselect
        v-model="recipientObjects"
        name='recipient'
        :options="options"
        :searchable='false'
        :allow-empty='false'
        label='text'
        track-by='value'
        :multiple='true'
        :close-on-select='false'
        :taggable='false'
        :showPointer='false'
      ></multiselect> -->

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
      recipientObjects: [],
      emailSubject: this.value.subject,
      emailBody: this.value.content,
      editBody: false
    }
  },
  computed: {
    recipients() {
      return this.recipientObjects.map( obj => { return obj.value })
    },
    options() {
      return this.$store.state.arborists.map(arborist => {
        return {
          value: arborist.email,
          text: arborist.name
        }
      })
    },
    emailDefinition() {
      return {
        email: this.recipients,
        subject: this.emailSubject,
        content: this.emailBody
      }
    }
  },
  watch: {
    emailDefinition() {
      this.$emit('changed', this.emailDefinition);
    }
  },
  mounted() {
    this.$emit('changed', this.emailDefinition);
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

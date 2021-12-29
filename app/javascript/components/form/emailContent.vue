<template>
  <div class='email-container'>
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
  props: {
    value: {
      required: true,
      type: Object
    },
    initialContent: {
      required: false,
      type: String,
      default: ''
    },
    initialSubject: {
      required: false,
      type: String,
      default: ''
    }
  },
  data() {
    return {
      emailSubject: this.initialSubject,
      emailBody: this.initialContent,
      editBody: false
    }
  },
  computed: {
    emailDefinition() {
      return {
        subject: this.emailSubject,
        body: this.emailBody
      }
    }
  },
  watch: {
    emailDefinition() {
      this.$emit('input', this.emailDefinition);
    }
  },
  mounted() {
    this.$emit('input', this.emailDefinition);
  }
}
</script>

<style scoped>
  .email-container {
    margin-top: 8px;
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

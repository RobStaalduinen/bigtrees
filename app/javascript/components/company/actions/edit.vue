<template>
  <app-scrollable-sidebar :id='id' title='Update Company' submitText='Save' :onSubmit='updateCompany' @cancelled='reset'>
    <template v-slot:content>
      <div v-if="editableCompany">
        <app-input-field
          v-model='editableCompany.name'
          label='Name'
          name='name'
        />

        <app-input-field
          v-model='editableCompany.legal_name'
          label='Legal Name'
          name='legal_name'
        />

        <app-input-field
          v-model='editableCompany.email'
          label='Email Address'
          name='email'
        />

        <app-input-field
          v-model='editableCompany.phone_number'
          label='Phone Number'
          name='phone_number'
        />

        <app-input-field
          v-model='editableCompany.website'
          label='Website'
          name='website'
        />

        <app-input-field
          v-model='editableCompany.address.street'
          label='Street'
          name='street'
        />

        <app-input-field
          v-model='editableCompany.address.city'
          label='City'
          name='city'
        />

        <app-input-field
          v-model='editableCompany.address.postal_code'
          label='Postal Code'
          name='postal_code'
        />

        <app-input-field
          v-model='editableCompany.tax_description'
          label='Tax Name'
          name='tax_description'
        />
        <div class='field-hint'>Shown on the quote beside the tax amount, e.g. HST, GST, GST + PST.</div>

        <app-number-field
          v-model='editableCompany.tax_rate'
          label='Tax Rate (%)'
          name='tax_rate'
        />
        <div class='field-hint'>A whole number. 13 means 13%.</div>

        <app-input-field
          v-model='editableCompany.outgoing_quote_email'
          label='Outgoing Quote Email'
          name='outgoing_quote_email'
        />

        <app-input-field
          v-model='editableCompany.quote_bcc'
          label='Quote BCC'
          name='quote_bcc'
        />

        <app-text-area
          v-model='editableCompany.email_signature'
          label='Email Signature'
          name='email_signature'
          :rows='4'
        />
      </div>
    </template>


  </app-scrollable-sidebar>
</template>

<script>

export default {
  props: {
    id: {
      required: true
    },
    company: {
      required: true
    }
  },
  data() {
    return {
      editableCompany: { address: {} }
    }
  },
  methods: {
    reset() {
      this.editableCompany = this.company;
    },
    updateCompany() {
     let params = {
        organization: {
          ...this.editableCompany,
          address_attributes: this.editableCompany.address
        }
      };

      // Remove the original address key
      delete params.organization.address;
      delete params.id;

      this.axiosPut(`/organizations/${this.company.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        this.$store.commit('updateOrganization', response.data);
      });
    }
  },
  watch: {
    company: {
      immediate: true,
      handler(value) {
        this.editableCompany = value;
      }
    }
  }
}
</script>

<style scoped>
  /* Sits directly under its field, so it pulls up into the form-group's
     bottom margin rather than adding a gap of its own. */
  .field-hint {
    font-size: 12px;
    color: gray;
    margin-top: -12px;
    margin-bottom: 14px;
  }
</style>

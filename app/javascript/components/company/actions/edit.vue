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
          v-model='editableCompany.insurance_provider'
          label='Insurance Provider'
          name='insurance_provider'
        />

        <app-input-field
          v-model='editableCompany.insurance_policy_number'
          label='Insurance Policy Number'
          name='insurance_policy_number'
        />

        <app-input-field
          v-model='editableCompany.insurance_description'
          label='Insurance Description'
          name='insurance_description'
        />

        <app-input-field
          v-model='editableCompany.hst_number'
          label='HST Number'
          name='hst_number'
        />

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

        <app-input-field
          v-model='editableCompany.email_signature'
          label='Email Signature'
          name='email_signature'
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

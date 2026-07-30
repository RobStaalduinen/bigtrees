<template>
  <app-scrollable-sidebar :id='id' title='Transfer Quote' submitText='Transfer' :onSubmit='handleSubmit'>
    <template v-slot:content>
      <p class='transfer-help'>
        Move this quote to another organization. A copy is created there with the
        customer, addresses, images, notes and costs. This quote is marked as
        transferred.
      </p>

      <app-select-field
        v-model='targetOrganizationId'
        :options='options'
        label='Destination organization'
        name='target_organization'
        validationRules='required'
      />

      <p class='transfer-error' v-if='errorMessage'>{{ errorMessage }}</p>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
export default {
  props: {
    id: { required: true },
    estimate: { required: true }
  },
  data() {
    return {
      targetOrganizationId: null,
      organizations: [],
      errorMessage: null
    }
  },
  mounted() {
    this.populateOrganizations();
  },
  computed: {
    options() {
      return this.organizations.map(org => ({ value: org.id, text: org.name }));
    }
  },
  methods: {
    populateOrganizations() {
      this.axiosGet('/organizations/transfer_targets').then(response => {
        this.organizations = response.data.organizations;
      });
    },
    handleSubmit() {
      this.errorMessage = null;

      this.axiosPost(`/estimates/${this.estimate.id}/transfers`, {
        target_organization_id: this.targetOrganizationId
      })
        .then(() => {
          // The new copy lives in another organization and isn't accessible in
          // the current org's scope, so stay on this (now transferred) quote and
          // reload it to reflect the new state + "Transferred to" provenance.
          this.$root.$emit('bv::toggle::collapse', this.id);
          window.location.reload();
        })
        .catch(error => {
          const responseError =
            error && error.response && error.response.data && error.response.data.error;
          this.errorMessage = responseError || 'The transfer could not be completed.';
        });
    }
  }
}
</script>

<style scoped>
  .transfer-help {
    font-size: 0.9em;
    color: #555;
    margin-bottom: 12px;
  }

  .transfer-error {
    color: var(--danger);
    margin-top: 12px;
  }
</style>

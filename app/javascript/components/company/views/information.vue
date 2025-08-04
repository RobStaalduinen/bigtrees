<template>
  <div>
    <app-header title='Company Information'>
      <template v-slot:header-right>
        <a v-b-toggle.edit-company v-if='hasPermission("organizations", "update")'>
          Edit
        </a>
      </template>
    </app-header>

    <div id='company-information' v-if="company">
      <div class='company-section-header'>
        Basic Information
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Name:</div>
        <div class='company-information-value'>{{ company.name }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Legal Name:</div>
        <div class='company-information-value'>{{ company.legal_name }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Email:</div>
        <div class='company-information-value'>{{ company.email }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Phone:</div>
        <div class='company-information-value'>{{ company.phone_number }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Website:</div>
        <div class='company-information-value'>{{ company.website }}</div>
      </div>

      <div class='company-section-header'>
        Company Address
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Street:</div>
        <div class='company-information-value'>{{ company.address.street }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>City:</div>
        <div class='company-information-value'>{{ company.address.city }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Postal Code:</div>
        <div class='company-information-value'>{{ company.address.postal_code }}</div>
      </div>


      <div class='company-section-header'>
        Legal Information
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Insurance Provider:</div>
        <div class='company-information-value'>{{ company.insurance_provider }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Insurance Policy Number:</div>
        <div class='company-information-value'>{{ company.insurance_policy_number }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Insurance Description:</div>
        <div class='company-information-value'>{{ company.insurance_description }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>HST Number:</div>
        <div class='company-information-value'>{{ company.hst_number }}</div>
      </div>

      <div class='company-section-header'>
        Outgoing Email Settings
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Outgoing Email Author:</div>
        <div class='company-information-value'>{{ company.email_author }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Outgoing Quote Email:</div>
        <div class='company-information-value'>{{ company.outgoing_quote_email }}</div>
      </div>
      <div class='company-information-row'>
        <div class='company-information-label'>Quote BCC:</div>
        <div class='company-information-value'>{{ company.quote_bcc }}</div>
      </div>
    </div>

    <app-edit-company id='edit-company' :company='company' v-if="company"></app-edit-company>
  </div>
</template>

<script>
  import EditCompany from '../actions/edit';

  export default {
    components: {
      'app-edit-company': EditCompany
    },
    data() {
      return {
        company: null
      }
    },
    mounted() {
      this.company = this.$store.state.organization;
    }
  }
</script>

<style scoped>
  .company-information-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
  }

  .company-information-label {
    font-weight: bold;
    width: 45%;
  }

  .company-information-value {
    width: 50%;
  }

  .company-section-header{
    margin-bottom: 8px;
    padding: 8px;
    background-color: #f0f0f0;
    font-size: 1.2rem;
    font-weight: 600;
  }
</style>

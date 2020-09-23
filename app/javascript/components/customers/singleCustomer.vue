<template>
  <div class='customer-list-entry'>
    <div class='customer-list-contact'>
      <span class='customer-name'>{{ customer.name }}</span>
      <div class='contact-entry'>
        <b-icon icon='envelope' class='contact-icon'></b-icon>
        {{ customer.email }} <span class='preferred'>{{ preferredString('email') }}</span>
      </div>
      <div class='contact-entry'>
        <b-icon icon='telephone' class='contact-icon'></b-icon>
        {{ customer.phone }} <span class='preferred'>{{ preferredString('phone') }}</span>
      </div>
    </div>
    <div class='contact-actions'>
      <b-button class='main-color-button button-small' :href='`/estimates/new?customer_id=${customer.id}`'>New Estimate</b-button>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    'customer': {
      type: Object,
      required: true
    }
  },
  methods: {
    preferredString(contact_method){
      var preferred = this.customer.preferred_contact;
      if(contact_method == 'phone' && (preferred == 'phone' || preferred == 'text')){
        return `(${preferred} preferred)`
      }
      else if(contact_method == 'email' && preferred == 'email'){
        return `(${preferred} preferred)`
      }
    }
  }
}
</script>

<style scoped>
  .customer-list-entry {
    width: 100%;
    border: 1px solid lightgray;
    box-shadow: 0 5px 3px -3px rgba(153, 153, 153, 0.5);
    padding: 8px;
    margin-bottom: 8px;
    display: flex;
    flex-direction: column;
  }

  .customer-list-contact {
    width: 100%;
    display: flex;
    flex-direction: column;
    font-size: 14px;
  }

  .customer-name {
    font-weight: 600;
  }

  .contact-entry {
    display: flex;
    align-items: center;
    margin-bottom: 4px;
  }

  .contact-icon {
    color: var(--main-color);
    margin-right: 8px;
  }

  .contact-actions {
    display: flex;
    justify-content: flex-end;
    font-size: 14px;
    border-width: 1px 0 0 0;
    border-color: lightgray;
    border-style: solid;
    padding-top: 8px;
  }

  .preferred {
    font-size: 10px;
    margin-left: 4px;
  }
</style>

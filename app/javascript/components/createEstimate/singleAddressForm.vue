<template>
  <div>
    <app-input-field
      v-model='street'
      :name='name + "street"'
      label='Street and Number'
    ></app-input-field>

    <app-input-field
      v-model='city'
      :name='name + "_city"'
      label='City'
    ></app-input-field>
  </div>
</template>

<script>
export default {
  props: {
    name: {
      required: true
    },
    initialAddress: {
      default: null
    }
  },
  data(){
    return {
      street: null,
      city: null
    }
  },
  computed: {
    address(){
      return {
        street: this.street,
        city: this.city
      }
    }
  },
  watch: {
    address: function() {
      this.$emit('addressChange', this.address);
    },
    initialAddress: function() {
      this.updateInitialAddress();
    }
  },
  methods: {
    updateInitialAddress() {
      if(this.initialAddress) {
        this.street = this.initialAddress.street;
        this.city = this.initialAddress.city;
      }
    }
  },
  mounted() {
    this.updateInitialAddress();
    this.$emit('addressChange', this.address);
  }

}
</script>

<style scoped>
  .form-row{
    display: flex;
    justify-content: space-between;
    padding: 0 4px;
  }

  .half-form-group{
    width: 48%;
  }
</style>

<template>
  <div>
    <b-form-group label="Find an Address">
      <b-form-input
        ref="findAddress"
        placeholder="Start typing an address..."
        @keydown.enter.prevent
      ></b-form-input>
    </b-form-group>

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
      city: null,
      autocomplete: null
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
    },
    initAutocomplete() {
      if (!window.google?.maps?.places) return;
      const input = this.$refs.findAddress.$el;
      if (!input) return;
      this.autocomplete = new window.google.maps.places.Autocomplete(input, {
        componentRestrictions: { country: 'ca' },
        fields: ['address_components'],
        types: ['address']
      });
      this.autocomplete.addListener('place_changed', this.onPlaceChanged);
    },
    onPlaceChanged() {
      const place = this.autocomplete.getPlace();
      if (!place.address_components) return;
      const get = (type, nameType = 'long_name') => {
        const c = place.address_components.find(c => c.types.includes(type));
        return c ? c[nameType] : '';
      };
      this.street = [get('street_number', 'short_name'), get('route')].filter(Boolean).join(' ');
      const cityTypes = ['locality', 'sublocality_level_1', 'sublocality', 'administrative_area_level_3', 'administrative_area_level_2'];
      this.city = cityTypes.reduce((found, type) => found || get(type), '');
      this.$refs.findAddress.$el.value = '';
    }
  },
  mounted() {
    this.updateInitialAddress();
    this.$emit('addressChange', this.address);
    this.$nextTick(this.initAutocomplete);
  },
  beforeDestroy() {
    if (this.autocomplete) {
      window.google.maps.event.clearInstanceListeners(this.autocomplete);
    }
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

<template>
  <div id='owner'>
    <span id='owner-label'>Owner:</span>
    <template v-if='!isEdit'>
      <span id='owner-text'>{{ estimate.arborist.name }}</span>
      <b-icon icon='pencil-square' id='owner-edit-icon' @click='isEdit=true' />
    </template>

    <div id='arborist-form' v-if='isEdit'>
      <b-form-select v-model="arborist" :options="options" id='arborist-select'></b-form-select>

      <app-submit-button
        label='Save'
        id='save-button'
        :onSubmit="submit"
        ></app-submit-button>
    </div>

  </div>
</template>

<script>
export default {
  props: {
    estimate: {
      required: true
    }
  },
  data() {
    return {
      isEdit: false,
      arborist: this.estimate.arborist.id
    }
  },
  computed: {
    options() {
      console.log(this.$store.state.arborists);
      return this.$store.state.arborists.map(arborist => {
        if(arborist.can_manage_estimates) {
          return {
            value: arborist.id,
            text: arborist.name
          }
        }
      }).filter(arborist => !!arborist);;
    }
  },
  methods: {
    submit() {
      var params = {
        estimate: {
          arborist_id: this.arborist
        }
      }
      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        this.isEdit = false;
        this.$emit('changed', response.data.estimate);
      })
    }
  },
  mounted() {

  }
}
</script>

<style scoped>
  #owner {
    display: flex;
    align-items: center;
  }

  #owner-label {
    margin-right: 4px;
    font-weight: 600;
  }

  #owner-edit-icon {
    margin-left: 8px;
    color: var(--main-color);
  }

  #arborist-form {
    width: 100%;
    display: flex;
    justify-content: space-between;
    margin-left: 16px;
  }

  #arborist-select {
    width: 80%;
  }

  #save-button {
    margin-left: 8px;
    width: 20%;
    display: flex;
    justify-content: center;
  }

  @media(min-width: 760px){
    #arborist-form {
      width: 30%;
    }
  }
</style>

<template>
  <page-template>
    <app-header title='New Quote'></app-header>
    <app-estimate-form></app-estimate-form>
  </page-template>
</template>

<script>
import EstimateForm from '../components/createEstimate/estimateForm';

export default {
  components: {
    'app-estimate-form': EstimateForm
  },
  data() {
    return {
    }
  },
}
</script>

<style scoped>
  
</style>

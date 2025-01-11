<template>
  <div>
    <b-form-group
      label="Task"
      label-for="task">
      <b-form-select
        v-model='selectedTask'
        name='task'
        :options="options"
        @change='updateTreeImage'
        />
    </b-form-group>
  </div>
</template>

<script>
export default {
  props: {
    estimate: {
      required: true
    },
    treeImage: {
      required: true
    }
  },
  data() {
    return {
      selectedTask: this.treeImage.tree_id || 'uncategorized'
    }
  },
  methods: {
    optionForTree(tree, index){
      return {
        value: tree.id,
        text: `Task #${index+1}`
      }
    },
    updateTreeImage() {
      let params = {
        estimate_id: this.estimate.id,
        tree_id: this.selectedTask
      }

      this.axiosPut(`/tree_images/${this.treeImage.id}`, params)
        .then(response => {
          this.$emit('updated', response.data);
        })
        .catch(error => {
          console.log(error);
        })
    }
  },
  computed: {
    options() {
      var arr =  this.estimate.trees.map((tree, index) => {
        return this.optionForTree(tree, index);
      })
      arr.unshift({value: 'uncategorized', text: 'Uncategorized'});

      return arr;
    },
  },
  watch: {
    treeImage() {
      this.selectedTask = this.treeImage.tree_id || 'uncategorized';
    },
    immediate: true
  }
}
</script>

<style scoped>

</style>

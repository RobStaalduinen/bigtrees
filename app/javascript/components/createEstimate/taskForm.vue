<template>
  <div>
    <div v-for='(task, index) in tasks' :key='task.key'>
      <div id='task-header'>
        Task #{{ index + 1 }}
        <b-icon icon='trash-fill' v-if="tasks.length > 1" @click='deleteTask(index)'/>
      </div>
      <app-single-image :value='task.image' @input='(payload) => updateImage(index, payload)'></app-single-image>
      <app-single-cost :value='tasks.cost' @input='(payload) => updateCosts(index, payload)'></app-single-cost>
    </div>

    <a id='add-task-button' @click.prevent='addTask'>
      + Add Task +
    </a>
  </div>
</template>

<script>
  import SingleImageForm from '../tree_images/forms/single';
  import SingleCost from '../costs/forms/single';

  export default {
    components: {
      'app-single-image': SingleImageForm,
      'app-single-cost': SingleCost
    },
    data() {
      return {
        tasks: [this.defaultTask()],
        version: 1
      }
    },
    methods: {
      addTask() {
        this.tasks.push(this.defaultTask())
        this.$emit('input', this.tasks);
      },
      deleteTask(index) {
        this.tasks.splice(index, 1);
        this.$emit('input', this.tasks);
      },
      defaultTask() {
        return {
          key: Math.random().toString(36).substr(2, 9),
          image: null,
          cost: { description: null, amount: null }
        }
      },
      updateImage(index, payload) {
        this.tasks[index].image = { ...payload };
        this.$emit('input', this.tasks);
      },
      updateCosts(index, payload) {
        this.tasks[index].cost = { ...payload };
        this.$emit('input', this.tasks);
      }
    }
  }
</script>

<style scoped>
  #add-task-button {
    width: 100%;
    display: flex;
    justify-content: center;
    color: var(--main-color);
  }

  #task-header{
    display: flex;
    font-size: 14px;
    color: var(--main-color);
    margin-bottom: 8px;
    justify-content: space-between;
  }
</style>

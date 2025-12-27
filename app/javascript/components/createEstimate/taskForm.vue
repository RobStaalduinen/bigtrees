<template>
  <div>
    <div v-for='(task, index) in tasks' :key='task.key'>
      <div id='task-header'>
        Task #{{ index + 1 }}
        <b-icon icon='trash-fill' v-if="tasks.length > 1" @click='deleteTask(index)'/>
      </div>
      <!-- <app-single-image :value='task.image' @input='(payload) => updateImage(index, payload)'></app-single-image> -->
      <app-file-upload :value='task.image.url' @input='(payload) => updateImage(index, payload)'></app-file-upload>
      <app-single-cost :value='task.cost' @input='(payload) => updateCosts(index, payload)'></app-single-cost>
    </div>

    <a id='add-task-button' @click.prevent='addTask'>
      + Add Task +
    </a>

    <app-quick-costs :addCost='addCustomTask'></app-quick-costs>
  </div>
</template>

<script>
  import SingleImageForm from '../tree_images/forms/single';
  import FileUpload from '@/components/file/actions/upload';
  import SingleCost from '../costs/forms/single';
  import QuickCosts from '@/components/costs/widgets/quick';


  export default {
    components: {
      'app-single-image': SingleImageForm,
      'app-file-upload': FileUpload,
      'app-single-cost': SingleCost,
      'app-quick-costs': QuickCosts
    },
    data() {
      return {
        tasks: [this.defaultTask()],
        version: 1
      }
    },
    methods: {
      addCustomTask(amount, description) {
        this.tasks.push(
          {
            key: Math.random().toString(36).substr(2, 9),
            image: { url: null },
            cost: { description: description, amount: amount }
          }
        )
        this.$emit('input', this.tasks);
      },
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
          image: { url: null },
          cost: { description: null, amount: null }
        }
      },
      updateImage(index, payload) {
        this.tasks[index].image.url = payload;
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

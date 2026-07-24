<template>
  <div>
    <div class='uncategorized-block'>
      <div class='task-header'>Uncategorized Images</div>
      <app-uploader
        :value='uncategorizedImages'
        :multiple='true'
        :compact='true'
        :target="{ type: 'tree_image', pending: true }"
        accept=".jpg, .jpeg, .png"
        bucketName='tree_images'
        presignPath='/tree_images/new'
        @input='updateUncategorizedImages'
      ></app-uploader>
    </div>

    <div v-for='(task, index) in tasks' :key='task.key' class='task-block'>
      <div class='task-header'>
        Task #{{ index + 1 }}
        <b-icon icon='trash-fill' class='delete-icon' @click='deleteTask(index)'/>
      </div>
      <app-input-field
        :value='task.description'
        :name='`task_${index}_description`'
        label='Description (optional)'
        @input='(payload) => updateDescription(index, payload)'
      ></app-input-field>
      <app-uploader
        :value='task.images'
        :multiple='true'
        :compact='true'
        :target="{ type: 'tree_image', pending: true }"
        accept=".jpg, .jpeg, .png"
        bucketName='tree_images'
        presignPath='/tree_images/new'
        @input='(payload) => updateImages(index, payload)'
      ></app-uploader>
    </div>

    <a id='add-task-button' @click.prevent='addTask'>
      + Add Task +
    </a>
  </div>
</template>

<script>
  // app-uploader and app-input-field are registered globally (packs/admin.js).
  // Tasks and their images are intentionally decoupled from invoice costs:
  // a task is just an optional description plus a group of images. Images that
  // belong to no task go in the uncategorized bucket (a TreeImage with a null
  // tree_id, associated only to the estimate).
  export default {
    data() {
      return {
        tasks: [],
        uncategorizedImages: []
      }
    },
    methods: {
      addTask() {
        this.tasks.push(this.defaultTask());
        this.emit();
      },
      deleteTask(index) {
        this.tasks.splice(index, 1);
        this.emit();
      },
      defaultTask() {
        return {
          key: Math.random().toString(36).substr(2, 9),
          description: null,
          images: []
        }
      },
      updateDescription(index, value) {
        this.tasks[index].description = value;
        this.emit();
      },
      // payload is app-uploader's emitted job list: [{ id, clientUploadId, status, url }]
      updateImages(index, payload) {
        this.$set(this.tasks[index], 'images', payload);
        this.emit();
      },
      updateUncategorizedImages(payload) {
        this.uncategorizedImages = payload;
        this.emit();
      },
      emit() {
        this.$emit('input', {
          tasks: this.tasks,
          uncategorizedImages: this.uncategorizedImages
        });
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
    cursor: pointer;
  }

  .task-block {
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid lightgray;
  }

  .uncategorized-block {
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid lightgray;
  }

  .task-header {
    display: flex;
    font-size: 14px;
    color: var(--main-color);
    margin-bottom: 8px;
    justify-content: space-between;
  }

  .delete-icon {
    cursor: pointer;
  }
</style>

<template>
  <div>
    <app-collapsable id='trees-collapse' :padded='false'>
      <template v-slot:title>
        <b>Task Details and Images</b>
      </template>

      <template v-slot:content>
        <div v-for='(tree_id, index) in sortedKeys' :key='baseKey + " _ " + index'>
          <app-single-row
            :index='index'
            :tree='treeForId(tree_id)'
            :is-dragging='isDragging'
            :has-images='sortedImages[tree_id] && sortedImages[tree_id].length > 0'
            @edit='editTask'
            @add-images='addImagesToSection'
          >
            <template v-slot:images>
              <draggable
                :list='sortedImages[tree_id]'
                group='tree-images'
                :animation='150'
                :force-fallback='true'
                :delay='200'
                :delay-on-touch-only='false'
                ghost-class='image-ghost'
                chosen-class='image-chosen'
                drag-class='image-drag'
                style='display: flex; flex-wrap: nowrap; min-height: 60px; overflow-x: auto;'
                @start='onDragStart'
                @end='onDragEnd'
@change='onImageMoved($event, tree_id)'
              >
                <app-image-thumb
                  v-for='image in sortedImages[tree_id]'
                  :key='image.id'
                  :image='image'
                  @click='toggleModal(image.id)'
                  @remove='removeImage'
                />
              </draggable>
            </template>
          </app-single-row>
        </div>

        <div class='single-estimate-link-row' v-if="hasPermission('estimates', 'update')">
          <div class='single-estimate-link' v-b-toggle.add-task @click='resetTaskForm'>
            Add Task
          </div>
        </div>

        <!-- Shared picker for every section's "Add Images" link. The section the
             link belongs to is recorded in uploadTargetTreeId before opening. -->
        <input
          v-if="hasPermission('estimates', 'update')"
          ref='fileInput'
          type='file'
          multiple
          accept='.jpg, .jpeg, .png'
          style='display: none;'
          @change='onFilesSelected'
        />
      </template>
    </app-collapsable>

    <app-create-task :estimate='estimate' id='add-task'></app-create-task>
  </div>
</template>

<script>
import Draggable from 'vuedraggable';
import CreateTask from '@/components/trees/actions/create';
import SingleRow from './singleRow';
import ImageThumb from '@/components/tree_images/forms/imageThumb';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-single-row': SingleRow,
    'app-create-task': CreateTask,
    'app-image-thumb': ImageThumb,
    'draggable': Draggable
  },
  props: {
    estimate: {
      required: true
    }
  },
  data() {
    return {
      displayedImage: null,
      baseKey: 1000,
      isDragging: false,
      uploadTargetTreeId: null
    }
  },
  computed: {
    sortedImages() {
      var sortedImages = this.estimate.trees.reduce((acc, tree) => {
        acc[tree.id] = [];
        return acc;
      }, {});

      sortedImages['null'] = [];

       this.estimate.tree_images.map((image) => {
        sortedImages[image.tree_id].push(image);
      },);

      return sortedImages;
    },
    sortedKeys() {
      let initialKeys = Object.keys(this.sortedImages).filter(x => x != 'null');
      initialKeys = initialKeys.sort()
      initialKeys.unshift(null);
      return initialKeys;
    }
  },
  methods: {
    toggleModal(image_id) {
      // Pass the already-loaded images/trees so the gallery doesn't refetch.
      EventBus.$emit('TOGGLE_IMAGE_GALLERY', {
        estimate_id: this.estimate.id,
        image_id: image_id,
        images: this.estimate.tree_images,
        trees: this.estimate.trees
      });
    },
    // Open the shared task sidebar pre-filled to edit this task.
    editTask(tree) {
      EventBus.$emit('TREE_FORM_EDIT', tree);
    },
    // Clear any prior edit state so the (toggle-opened) sidebar is a fresh add.
    resetTaskForm() {
      EventBus.$emit('TREE_FORM_RESET');
    },
    // A section's "Add Images" link was clicked. Record which section it was
    // (null tree = the Uncategorized bucket) so the chosen files land there,
    // then open the OS file picker directly — no intermediate dialog.
    addImagesToSection(tree) {
      this.uploadTargetTreeId = tree ? tree.id : null;
      this.$refs.fileInput.click();
    },
    // Hand each chosen file to the durable upload queue, targeting the section
    // whose "Add Images" link was clicked (uploadTargetTreeId; null = uncategorized).
    // The queue creates a pending row, uploads in the background, and fills the
    // URL when done; the grid converges via refetch.
    onFilesSelected(event) {
      const files = Array.from(event.target.files || []);
      for (const file of files) {
        if (!file) continue;
        this.$uploads.enqueue({
          file,
          target:      { type: 'tree_image', estimate_id: this.estimate.id, tree_id: this.uploadTargetTreeId },
          bucketName:  'tree_images',
          presignPath: '/tree_images/new',
          compress:    true
        });
      }
      // Reset so picking the same file again re-fires change.
      event.target.value = '';
      // Pending rows are created asynchronously; refetch so they appear.
      this.scheduleRefresh();
    },
    scheduleRefresh() {
      clearTimeout(this._refreshTimer);
      this._refreshTimer = setTimeout(() => this.refreshEstimate(), 600);
    },
    // Cancel + remove a pending image. If a local upload job is still driving
    // this row, kill it through the manager (aborts the upload, deletes the
    // row, clears IndexedDB) so it can't resurrect via idempotent associate.
    // Otherwise (job already gone, e.g. after a reload on another device) just
    // delete the row directly.
    removeImage(image) {
      if (!confirm('Cancel this upload and remove the image?')) return;

      const job = this.$uploads && this.$uploads.allJobs().find(j =>
        j.placeholderId === image.id ||
        (image.client_upload_id && j.clientUploadId === image.client_upload_id)
      );

      if (job) {
        this.$uploads.remove(job.id).then(() => this.refreshEstimate());
      } else {
        this.axiosDelete(`/tree_images/${image.id}?estimate_id=${this.estimate.id}`)
          .then(response => EventBus.$emit('ESTIMATE_UPDATED', response.data))
          .catch(() => {});
      }
    },
    refreshEstimate() {
      this.axiosGet(`/estimates/${this.estimate.id}.json`)
        .then(response => EventBus.$emit('ESTIMATE_UPDATED', { estimate: response.data.estimate }))
        .catch(() => {});
    },
    treeForId(treeId) {
      return this.estimate.trees.find(tree => tree.id == treeId);
    },
    onDragStart() {
      this.isDragging = true;
    },
    onDragEnd() {
      this.isDragging = false;
      this.hoveringTreeId = null;
    },
    onImageMoved(event, newTreeId) {
      if (!event.added) return;
      const image = event.added.element;
      const treeId = newTreeId == null || newTreeId === 'null' ? null : Number(newTreeId);
      // Sync the model to the move. vuedraggable only reorders the arrays the
      // sortedImages computed returned — it doesn't touch image.tree_id. Without
      // this, the next recompute (e.g. when a task is added) regroups by the
      // stale tree_id and snaps the image back to its original task.
      image.tree_id = treeId;
      this.axiosPut(`/tree_images/${image.id}`, {
        tree_id: treeId,
        estimate_id: this.estimate.id
      });
    }
  },
  updated(){
    if (!this.isDragging) {
      this.baseKey += 1;
    }
  },
  mounted() {
    // When background uploads finish, the active count drops — refetch so
    // pending placeholders flip to their ready (URL-filled) images.
    this._lastActive = 0;
    if (this.$uploads) {
      this._unsubUploads = this.$uploads.subscribe((summary) => {
        if (summary.active < this._lastActive) this.scheduleRefresh();
        this._lastActive = summary.active;
      });
    }
  },
  beforeDestroy() {
    clearTimeout(this._refreshTimer);
    if (this._unsubUploads) this._unsubUploads();
  }
}
</script>

<style>
  .image-ghost {
    opacity: 0.4;
  }

  .image-chosen {
    box-shadow: 0 0 0 2px #4a90d9;
  }
</style>

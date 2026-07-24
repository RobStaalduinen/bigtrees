<template>
  <div id='image-gallery' v-if='display' @click='close'>

    <!-- image stage — owns all space above the deck. Clicking the empty area
         around the image closes; clicking the image itself does not. -->
    <div class='gallery-stage' @touchstart='onTouchStart' @touchend='onTouchEnd'>
      <img v-if='displayedUrl' :src='displayedUrl' class='gallery-photo' @click.stop />
      <div v-else class='gallery-pending' @click.stop>
        <b-spinner></b-spinner>
        <div class='gallery-pending-label'>Uploading…</div>
      </div>
    </div>

    <!-- bottom control deck -->
    <div class='gallery-deck' @click.stop>

      <!-- meta row: task label · actions menu + close -->
      <div class='deck-meta'>
        <div class='deck-task'>{{ taskLabel }}</div>
        <div class='deck-meta-right'>
          <div class='menu-wrap' v-if='canEdit'>
            <span class='deck-icon-btn' title='Image actions' @click='toggleMenu'>
              <b-icon icon='three-dots'></b-icon>
            </span>
            <div class='menu-pop' v-if='menuOpen'>
              <div class='menu-item' v-if='!isPending' @click='startEdit'>
                <span class='menu-icon'><b-icon icon='pencil-square'></b-icon></span> Edit image
              </div>
              <div class='menu-item danger' @click='deleteImage'>
                <span class='menu-icon'><b-icon icon='trash'></b-icon></span> Delete image
              </div>
            </div>
          </div>
          <span class='deck-icon-btn close' title='Close' @click='close'>
            <b-icon icon='x'></b-icon>
          </span>
        </div>
      </div>

      <!-- controls row: version toggle + nav -->
      <div class='deck-controls'>
        <app-segmented-control
          v-model='version'
          :options='versionOptions'
        ></app-segmented-control>

        <div class='nav-row' v-if='totalImages > 1'>
          <button class='nav-arrow' title='Previous' @click='step(-1)'>
            <b-icon icon='chevron-left'></b-icon>
          </button>
          <div class='counter'>{{ index + 1 }} / {{ totalImages }}</div>
          <button class='nav-arrow' title='Next' @click='step(1)'>
            <b-icon icon='chevron-right'></b-icon>
          </button>
        </div>
      </div>

      <!-- filmstrip -->
      <div class='filmstrip' ref='filmstrip' v-if='totalImages > 1'>
        <div
          v-for='(image, i) in images'
          :key='image.id'
          class='thumb'
          :class="{ active: i === index, 'has-edit': !!image.edited_image_url }"
          ref='thumbs'
          @click='goTo(i)'
        >
          <img v-if='thumbUrl(image)' :src='thumbUrl(image)' :alt='image.id' />
          <div v-else class='thumb-empty'><b-icon icon='image'></b-icon></div>
        </div>
      </div>
    </div>

    <app-image-markup
      v-if='editingId != null'
      :imageUrl='editorUrl'
      @cancel='editingId = null'
      :onSave='onEditSave'
    ></app-image-markup>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus';
import Markup from './markup';
import { base64ToBlob } from '@/utils/fileUtils';
import { signedUrlFormData, parseImageUploadResponse } from '@/utils/awsS3Utils';
import { postWithRetry } from '@/services/uploadClient';

// Self-contained gallery modal. Mounted once at the app root; opened via the
// TOGGLE_IMAGE_GALLERY EventBus event from anywhere (estimate detail, task rows,
// estimate list). It owns its own image list: callers may pass images directly,
// otherwise it fetches the estimate on open.
export default {
  components: {
    'app-image-markup': Markup
  },
  data() {
    return {
      display: false,
      loading: false,
      estimateId: null,
      images: [],
      trees: [],
      index: 0,
      version: 'original',
      menuOpen: false,
      editingId: null,
      touchStartX: null
    };
  },
  computed: {
    currentImage() {
      return this.images[this.index] || null;
    },
    totalImages() {
      return this.images.length;
    },
    hasEdit() {
      return !!(this.currentImage && this.currentImage.edited_image_url);
    },
    isPending() {
      const img = this.currentImage;
      return !img || (!img.image_url && !img.edited_image_url);
    },
    displayedUrl() {
      if (!this.currentImage) return null;
      if (this.version === 'edited') return this.currentImage.edited_image_url;
      return this.currentImage.image_url;
    },
    versionOptions() {
      return [
        { value: 'original', text: 'Original' },
        { value: 'edited', text: 'Edited', disabled: !this.hasEdit }
      ];
    },
    canEdit() {
      return this.hasPermission('estimates', 'update');
    },
    taskLabel() {
      const img = this.currentImage;
      if (!img || img.tree_id == null) return 'Uncategorized';
      const tree = img.tree || this.trees.find(t => t.id === img.tree_id);
      const position = this.trees.findIndex(t => t.id === img.tree_id);
      const name = tree && tree.work_name ? tree.work_name : 'Task';
      return position >= 0 ? `Task #${position + 1} · ${name}` : name;
    },
    editorUrl() {
      let url = `/tree_images/${this.currentImage.id}`;
      if (this.version === 'edited') url += '?edited=true';
      return url;
    }
  },
  methods: {
    // ---- open / load ----------------------------------------------------
    async handleToggle(payload) {
      this.estimateId = payload.estimate_id;
      this.menuOpen = false;

      if (payload.images) {
        this.setImages(payload.images, payload.trees || []);
      } else {
        await this.fetchEstimate(payload.estimate_id);
      }
      if (this.totalImages === 0) return;

      this.index = this.indexForId(payload.image_id);
      this.resetVersion();
      this.lockScroll();
      this.display = true;
      this.$nextTick(this.scrollActiveThumbIntoView);
    },
    async fetchEstimate(estimateId) {
      this.loading = true;
      try {
        const response = await this.axiosGet(`/estimates/${estimateId}.json`);
        const estimate = response.data.estimate;
        this.setImages(estimate.tree_images || [], estimate.trees || []);
      } catch (e) {
        this.setImages([], []);
      } finally {
        this.loading = false;
      }
    },
    setImages(images, trees) {
      this.images = images;
      this.trees = trees;
    },
    indexForId(imageId) {
      if (imageId == null) return 0;
      const found = this.images.findIndex(img => img.id === imageId);
      return found >= 0 ? found : 0;
    },
    resetVersion() {
      this.version = this.hasEdit ? 'edited' : 'original';
    },

    // ---- navigation -----------------------------------------------------
    step(delta) {
      if (this.totalImages < 2) return;
      this.index = (this.index + delta + this.totalImages) % this.totalImages;
      this.afterIndexChange();
    },
    goTo(i) {
      this.index = i;
      this.afterIndexChange();
    },
    afterIndexChange() {
      this.menuOpen = false;
      this.resetVersion();
      this.$nextTick(this.scrollActiveThumbIntoView);
    },
    scrollActiveThumbIntoView() {
      const el = this.$refs.thumbs && this.$refs.thumbs[this.index];
      if (el && el.scrollIntoView) {
        el.scrollIntoView({ block: 'nearest', inline: 'center' });
      }
    },
    onTouchStart(e) {
      this.touchStartX = e.changedTouches[0].clientX;
    },
    onTouchEnd(e) {
      if (this.touchStartX == null) return;
      const delta = e.changedTouches[0].clientX - this.touchStartX;
      if (Math.abs(delta) > 50) this.step(delta < 0 ? 1 : -1);
      this.touchStartX = null;
    },
    onKeydown(e) {
      if (!this.display) return;
      if (e.key === 'ArrowLeft') this.step(-1);
      else if (e.key === 'ArrowRight') this.step(1);
      else if (e.key === 'Escape') this.close();
    },

    // ---- menu / actions -------------------------------------------------
    toggleMenu() {
      this.menuOpen = !this.menuOpen;
    },
    startEdit() {
      this.menuOpen = false;
      if (this.isPending) return;
      this.editingId = this.currentImage.id;
    },
    deleteImage() {
      this.menuOpen = false;
      const id = this.currentImage.id;
      if (!confirm('Are you sure you want to delete this image?')) return;

      this.axiosDelete(`/tree_images/${id}?estimate_id=${this.estimateId}`).then(response => {
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
        this.applyEstimateResponse(response.data, id);
      });
    },
    async onEditSave(image_base64) {
      const abort = new AbortController();
      const blob = base64ToBlob(image_base64);
      const editedId = this.editingId;
      const imgResponse = await postWithRetry({
        resolveTarget: async () => {
          const resp = await this.axiosGet('/tree_images/new', { filename: 'edited' });
          return { url: resp.data.url, formData: signedUrlFormData(resp.data.fields, blob) };
        },
        signal: abort.signal
      });
      const params = { edited_image_url: parseImageUploadResponse(imgResponse) };
      const resp = await this.axiosPut(`/tree_images/${editedId}?estimate_id=${this.estimateId}`, params);

      EventBus.$emit('ESTIMATE_UPDATED', resp.data);
      this.applyEstimateResponse(resp.data, editedId);
      this.version = 'edited';
      this.editingId = null;
    },
    // Refresh internal state from an update/destroy response (both render the
    // full estimate). Keep the viewer on the same image where possible; if it
    // was removed, clamp the index and close when nothing remains.
    applyEstimateResponse(data, keepId) {
      const estimate = data && data.estimate;
      if (!estimate) return;
      this.setImages(estimate.tree_images || [], estimate.trees || []);
      if (this.totalImages === 0) {
        this.close();
        return;
      }
      const kept = this.images.findIndex(img => img.id === keepId);
      this.index = kept >= 0 ? kept : Math.min(this.index, this.totalImages - 1);
      this.resetVersion();
    },

    // ---- lifecycle helpers ---------------------------------------------
    close() {
      this.display = false;
      this.menuOpen = false;
      this.unlockScroll();
    },
    lockScroll() {
      document.documentElement.style.overflow = 'hidden';
    },
    unlockScroll() {
      document.documentElement.style.overflow = '';
    },
    thumbUrl(image) {
      return image.image_small_url || image.image_url || image.edited_image_url;
    }
  },
  watch: {
    // Guard against an edit being lost / the toggle landing on a disabled
    // segment after the image changes.
    hasEdit(canShowEdited) {
      if (!canShowEdited && this.version === 'edited') this.version = 'original';
    }
  },
  mounted() {
    EventBus.$on('TOGGLE_IMAGE_GALLERY', this.handleToggle);
    window.addEventListener('keydown', this.onKeydown);
  },
  beforeDestroy() {
    EventBus.$off('TOGGLE_IMAGE_GALLERY', this.handleToggle);
    window.removeEventListener('keydown', this.onKeydown);
    if (this.display) this.unlockScroll();
  }
};
</script>

<style scoped>
  #image-gallery {
    position: fixed;
    inset: 0;
    z-index: 100;
    display: flex;
    flex-direction: column;
    background-color: rgba(0, 0, 0, 0.55);
  }

  /* image stage */
  .gallery-stage {
    flex: 1 1 auto;
    min-height: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: var(--space-4);
  }

  .gallery-photo {
    max-width: 100%;
    max-height: 100%;
    object-fit: contain;
    border-radius: var(--radius-sm);
    box-shadow: var(--shadow-md);
  }

  .gallery-pending {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--space-2);
    color: #fff;
  }
  .gallery-pending-label { font-size: var(--text-base); }

  /* bottom deck */
  .gallery-deck {
    flex: 0 0 auto;
    background: var(--surface);
    border-top: 1px solid var(--border);
    padding: var(--space-2) var(--space-3) var(--space-3);
    display: flex;
    flex-direction: column;
    gap: var(--space-2);
  }

  /* meta row */
  .deck-meta {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-2);
  }
  .deck-task {
    font-size: var(--text-sm);
    color: var(--text-muted);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .deck-meta-right {
    display: flex;
    align-items: center;
    gap: var(--space-1);
    flex: 0 0 auto;
  }

  /* Bare b-icons are functional components, so scoped styles don't reliably
     attach to their <svg> root. Wrap them in a real <span> that carries the
     size (font-size → 1em icon), colour and hover affordance instead. */
  .deck-icon-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    color: var(--main-color);
    cursor: pointer;
    font-size: 22px;
    padding: 6px;
    border-radius: var(--radius-sm);
    transition: background var(--transition-fast);
  }
  .deck-icon-btn:hover { background: var(--color-brand-wash); }
  .deck-icon-btn.close { color: var(--text-muted); font-size: 24px; }
  .deck-icon-btn.close:hover { background: var(--surface-sunken); color: var(--ink); }

  /* actions popover (opens upward) */
  .menu-wrap { position: relative; display: inline-flex; }
  .menu-pop {
    position: absolute;
    bottom: calc(100% + 6px);
    right: 0;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    box-shadow: var(--shadow-md);
    min-width: 168px;
    padding: var(--space-1);
    z-index: 5;
  }
  .menu-item {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    padding: 9px 12px;
    border-radius: var(--radius-sm);
    cursor: pointer;
    font-size: var(--text-base);
    color: var(--text);
  }
  .menu-item:hover { background: var(--surface-sunken); }
  .menu-icon { display: inline-flex; color: var(--main-color); font-size: 17px; }
  .menu-item.danger { color: var(--danger); }
  .menu-item.danger .menu-icon { color: var(--danger); }

  /* controls row — toggle and nav pushed to opposite ends */
  .deck-controls {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-4);
  }
  .nav-row { display: flex; align-items: center; gap: var(--space-2); }
  .nav-arrow {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 34px;
    height: 34px;
    border-radius: var(--radius-md);
    background: var(--surface);
    border: 1px solid var(--border-strong);
    color: var(--main-color);
    font-size: 18px;
    cursor: pointer;
    transition: background var(--transition-fast);
  }
  .nav-arrow:hover { background: var(--color-brand-wash); }
  .counter {
    color: var(--text-muted);
    font-size: var(--text-sm);
    min-width: 46px;
    text-align: center;
    font-variant-numeric: tabular-nums;
  }

  /* filmstrip */
  .filmstrip {
    display: flex;
    gap: var(--space-2);
    overflow-x: auto;
    width: 100%;
    padding: 2px;
    scrollbar-width: thin;
  }
  .thumb {
    flex: 0 0 auto;
    width: 48px;
    height: 48px;
    border-radius: var(--radius-sm);
    overflow: hidden;
    cursor: pointer;
    position: relative;
    border: 2px solid var(--border);
    opacity: 0.85;
    transition: opacity var(--transition-fast), border-color var(--transition-fast);
  }
  .thumb img { width: 100%; height: 100%; object-fit: cover; display: block; }
  .thumb:hover { opacity: 1; }
  .thumb.active { opacity: 1; border-color: var(--main-color); }
  .thumb.has-edit::after {
    content: '';
    position: absolute;
    top: 3px;
    right: 3px;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--main-color);
    border: 1.5px solid #fff;
  }
  .thumb-empty {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--surface-sunken);
    color: var(--neutral);
  }

  @media (min-width: 760px) {
    .gallery-deck { width: 60%; margin: 0 auto; border-radius: var(--radius-lg) var(--radius-lg) 0 0; }
  }
</style>

<!--
  Minimal rich text editor: bold, italic, underline and line breaks, nothing
  else. Deliberately not a library — the output is rendered into a customer
  facing PDF by wkhtmltopdf and is whitelisted server-side to <p> <br> <b>
  <strong> <i> <em> <u> <div>, so an editor that can only produce those tags
  is less to go wrong than one whose extra output has to be stripped.

  document.execCommand is deprecated but is still the only cross-browser way to
  do this without a dependency, and it is universally supported. styleWithCSS is
  turned off so it emits <b>/<i>/<u> rather than <span style="...">, which the
  sanitiser would strip.
-->
<template>
  <div class='rich-text'>
    <div class='rich-toolbar'>
      <button
        type='button'
        v-for='command in commands'
        :key='command.name'
        class='rich-button'
        :class="{ active: activeCommands[command.name] }"
        :title='command.title'
        :aria-label='command.title'
        @mousedown.prevent='apply(command.name)'
      >
        <span :class='command.css'>{{ command.label }}</span>
      </button>

      <button
        type='button'
        class='rich-button rich-reset'
        title='Restore the standard wording'
        @mousedown.prevent="$emit('reset')"
        v-if='resettable'
      >
        Reset to standard
      </button>
    </div>

    <div
      ref='editor'
      class='rich-editable'
      contenteditable='true'
      :style="{ minHeight: minHeight }"
      @input='onInput'
      @keyup='refreshActive'
      @mouseup='refreshActive'
      @blur='onInput'
    ></div>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String,
      default: ''
    },
    minHeight: {
      type: String,
      default: '260px'
    },
    resettable: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      activeCommands: { bold: false, italic: false, underline: false }
    }
  },
  computed: {
    commands() {
      return [
        { name: 'bold', label: 'B', title: 'Bold', css: 'cmd-bold' },
        { name: 'italic', label: 'I', title: 'Italic', css: 'cmd-italic' },
        { name: 'underline', label: 'U', title: 'Underline', css: 'cmd-underline' }
      ];
    }
  },
  methods: {
    apply(command) {
      this.$refs.editor.focus();
      document.execCommand(command, false, null);
      this.refreshActive();
      this.onInput();
    },
    onInput() {
      this.$emit('input', this.$refs.editor.innerHTML);
    },
    refreshActive() {
      this.commands.forEach(command => {
        this.activeCommands[command.name] = document.queryCommandState(command.name);
      });
    },
    // Only write into the DOM when the incoming value differs from what is
    // already there — assigning innerHTML on every keystroke would drop the
    // caret to the start of the box.
    syncFromValue() {
      const editor = this.$refs.editor;
      if (editor && editor.innerHTML !== this.value) {
        editor.innerHTML = this.value || '';
      }
    }
  },
  mounted() {
    // Emit <b>/<i>/<u> instead of styled spans. Throws on some older browsers,
    // where the default is already the tag form.
    try { document.execCommand('styleWithCSS', false, false); } catch (e) { /* noop */ }
    this.syncFromValue();
  },
  watch: {
    value() {
      this.syncFromValue();
    }
  }
}
</script>

<style scoped>
  .rich-text {
    border: 1px solid #ced4da;
    border-radius: 4px;
    background: white;
  }

  .rich-toolbar {
    display: flex;
    align-items: center;
    padding: 4px;
    border-bottom: 1px solid #e3e3e3;
    background: #fafafa;
  }

  .rich-button {
    min-width: 30px;
    height: 28px;
    margin-right: 4px;
    padding: 0 8px;
    border: 1px solid transparent;
    border-radius: 3px;
    background: transparent;
    cursor: pointer;
    font-size: 14px;
    line-height: 1;
  }

  .rich-button:hover {
    background: #ececec;
  }

  .rich-button.active {
    background: #e2e6da;
    border-color: #bfc4b4;
  }

  .rich-reset {
    margin-left: auto;
    margin-right: 0;
    font-size: 12px;
    color: var(--main-color);
  }

  .cmd-bold { font-weight: 700; }
  .cmd-italic { font-style: italic; }
  .cmd-underline { text-decoration: underline; }

  .rich-editable {
    padding: 10px 12px;
    overflow-y: auto;
    max-height: 420px;
    font-size: 14px;
    line-height: 1.55;
    color: #3A3F35;
    outline: none;
  }

  /* ::v-deep is required, not stylistic: execCommand creates <b>/<i>/<u> at
     runtime, and those elements never receive the scoped-style data attribute,
     so a plain `.rich-editable b` rule would not match them.

     Bold is given both the weight and the darker colour the PDF uses for it.
     Source Sans Pro's 700 is a restrained bold, and at editor text sizes the
     weight change alone was easy to miss — the colour shift makes it
     unambiguous, and matches how the output actually looks. */
  .rich-editable ::v-deep b,
  .rich-editable ::v-deep strong {
    font-weight: 700;
    color: #22271F;
  }

  .rich-editable ::v-deep i,
  .rich-editable ::v-deep em {
    font-style: italic;
  }

  .rich-editable ::v-deep u {
    text-decoration: underline;
  }

  /* Paragraph spacing mirrors the PDF so the editor reads like the output. */
  .rich-editable ::v-deep p {
    margin: 0 0 10px;
  }

  .rich-editable ::v-deep p:last-child {
    margin-bottom: 0;
  }

  .rich-editable:focus {
    box-shadow: inset 0 0 0 2px rgba(124, 139, 106, 0.25);
  }
</style>

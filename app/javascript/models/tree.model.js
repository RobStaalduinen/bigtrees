class Tree {
  constructor(tree){
    this.tree = tree
  }

  galleryDisplay(current_display_index) {
    return {
      id:           this.tree.id,
      workType:     this.tree.work_name,
      description:  this.tree.description,
      stumpRemoval: this.tree.stumpRemoval ? 'Yes' : 'No',
      treeName: `Task #${current_display_index + 1}`
    }
  }
}

export default Tree

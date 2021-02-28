class TreeImage {
  constructor(tree_image){
    this.tree_image = tree_image
  }

  galleryDisplay(current_display_index) {
    return {
      id:             this.tree_image.id,
      url:            this.tree_image.image_url_md,
      edited_url:     this.tree_image.edited_image_url_md,
      imageName:      `Image #${current_display_index + 1}`
    }
  }
}

export default TreeImage

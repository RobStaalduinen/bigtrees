# Spec: Drag and Drop Task Images

**Date:** 2026-03-29
**Author:** Rob van Staalduinen

---

## Overview

Users often want to upload multiple images from the site all at once, and then assign them to the appropriate task afterwards. This saves a lot of time fumbling with selecting the correct images. Currently, assigning images to different tasks is clumsy, requiring you to do it one-by-one in a special interface for each image. Instead, we should be able to drag and drop images between tasks.

---

## Goals

We should be able to press down on an image (desktop or mobile) and be able to drag that to particular areas for each task. Once it lands in one of the areas, the inferface should remain updated with the image in its new task, and the backend should be updated appropriately. It should always be clear to the user what image they are dragging, and where they are placing it. They should be able to move both uncategorized images, and images already belonging to a different task.

---

## Non-Goals / Out of Scope

- No need to change anything to do with the creation of tasks or the content itself
- The data model of trees or tree images should not need to be updated

---

## Functional Requirements

1. When pressing down on an image, the user should see drop areas for reassignment
2. When dragging to a specific area, the image should remain there, and the backend should be updated appropriately.

---

## Acceptance Criteria

- [ ] An arborist should see the ability to drag and reassign images upon pres
- [ ] The drag and drop solution needs to work for both desktop and mobile
- [ ] Upon dragging an image to the correct location, the frontend and backend data stores should be updated appropriately
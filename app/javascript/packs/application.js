// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("stylesheets/application.scss")
require("chartkick")
require("chart.js")

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import "controllers"

import flatpickr from "flatpickr"
require("flatpickr/dist/flatpickr.min.css")

// We have been having issues with the date picker, if you click on a test run and then hit
// the back button of the browser, it will add another datepicker to the page.
// This is due to the way Turbolinks caches and restores a page
// See: https://github.com/turbolinks/turbolinks#making-transformations-idempotent
// In order to resolve this, we destroy the flatpickr before it is cached
document.addEventListener("turbolinks:before-cache", () => {
  document.querySelectorAll(".flatpickr-input").flatpickr('destroy');
});

document.addEventListener("turbolinks:load", () => {
  flatpickr("[data-behavior='flatpickr']", {
    altInput: true,
    allowInput: true
  })
})


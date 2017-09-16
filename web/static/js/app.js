// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import $ from "jquery";
import _ from "lodash";
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
let App = {
    run() {
      console.log("Hello!");

      $("html").on("dragover", (e) => {
        e.preventDefault();
        e.stopPropagation();
      });

      $("html").on("dragleave", (e) => {
        e.preventDefault();
        e.stopPropagation();
      });

      $("html").on("drop", (e) => {
        e.preventDefault();
        e.stopPropagation();

        console.log(e.originalEvent.dataTransfer);
        console.log(e.originalEvent.dataTransfer.files);

        const data_transfer = e.originalEvent.dataTransfer;
        const html_txt = data_transfer.getData("text/html")
        const parser = new DOMParser();
        const el = parser.parseFromString(html_txt, "text/html");
        const imgs = el.getElementsByTagName('img');
        console.log("html ", html_txt);
        if (imgs.length > 1) {
          console.log("html", html_txt);
          console.log("imgs", imgs);
          alert("More than 1 img in dropped html")
        } else {
          this.submitFile(imgs[0].src, null);
        }

        return true;
      });

      $('body').on('paste', (ev) => {
        const clipboardData =(event.clipboardData || event.originalEvent.clipboardData);

        const items = clipboardData.items;

        const file_item = _.find(items, (i) => (i.kind == "file"));
        let blob = file_item.getAsFile();
        const string_item = _.find(items, (i) => (i.kind == "string"));

        string_item.getAsString((s) => {
          this.submitFile(s, blob);
        });
      });
    },

    submitFile(url, blob) {
      const filename = _.startsWith(url, 'file:') ? this.extractFileFilename(url) : this.extractPastedFilename(url)

      let fd = new FormData();
      fd.append('picture[full_url]', url);
      if (blob) {
        fd.append('picture[file]', blob, filename);
      }
      $.ajax({
        type: 'POST',
        url: '/create?format=json',
        data: fd,
        headers: {
          'x-csrf-token': this.csrf()
        },
        processData: false,
        contentType: false
      }).done(function(data) {
        console.log(data);
      });
    },

    csrf() {
      return $('input[name="_csrf_token"]').val();
    },

    extractFileFilename(s) {
      return _(s).split('/').last();
    },

    extractPastedFilename(s) {
      return _.chain(s).thru((s) => s.replace(/.*src="/, '')).split('"').first().split('/').last().value();
    }
  };

  module.exports = {
    App: App
  };

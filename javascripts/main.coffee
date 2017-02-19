msnry = null
ref = new Firebase "https://question-everything.firebaseio.com"
links_ref = new Firebase "https://question-links.firebaseio.com"
$('textarea').trumbowyg({
  removeformatPasted: true
  autogrow: true
  btns: [
        ['formatting'],
        'btnGrp-semantic',
        ['superscript', 'subscript'],
        ['link'],
        'btnGrp-justify',
        'btnGrp-lists',
        ['horizontalRule'],
        ['removeformat'],
        ['fullscreen']
    ]

});

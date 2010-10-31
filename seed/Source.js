bEnable = function(i) {
    $(i).removeAttr('disabled').animate({opacity: 1.0}, 'fast');
};

bDisable = function(i) {
    $(i).attr('disabled', 'disabled').animate({opacity: 0.2}, 'fast');
}

editor = null;

buildEditor = function(readOnly) {
    if (editor) {
        editor.toTextArea();
        editor = null;
    }
    editor = CodeMirror.fromTextArea("txt-src", {
        basefiles: ["/static/codemirror_base_min.js"],
        parserfile: ["/static/codemirror_parse_haskell.js"],
        stylesheet: "/static/codemirror.css",
        autoMatchParens: true,
        textWrapping: false,
        lineNumbers: true,
        indentUnit: 4,
        tabMode: "spaces",
        readOnly: readOnly
    });
}
mkEditable = function() {
    $('#txt-src').removeAttr('readonly');
    buildEditor(false);
    bDisable('#btn-edit');
    bEnable('#btn-cancel');
    bEnable('#btn-save');
};

mkReadOnly = function() {
    $('#txt-src').attr('readonly', 'readonly');
    buildEditor(true);
    bEnable('#btn-edit');
    bDisable('#btn-cancel');
    bDisable('#btn-save');
};

setResearch = function(e) {
    if ('selectionStart' in e) {
        var len = e.selectionEnd - e.selectionStart;
        var sel = e.value.substr(e.selectionStart, len);
        var mat = sel.match(/\S(.*\S)?/);
        if (mat) {
            $('.research-query').val(mat[0]);
        }
    };
};

$('#btn-edit').click(mkEditable);
$('#btn-cancel').click(mkReadOnly);
mkReadOnly();

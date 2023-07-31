function jsTemplateSelect(textArea, options) {
  this.$toolBar = $(textArea).parent('.jstEditor').parent().find('.jstElements');

  if ($(textArea)[0].id === 'layouts') {

    var selectCodeBlock = '<select id="template-select">' +
                            '<option value="default" style="color:green;">&nbsp;</option>' +
                            '<option value="tracker">Tracker</option>' +
                            '<option value="subject">Subject</option>' +
                            '<option value="description">Description</option>' +
                            '<option value="status">Status</option>' +
                            '<option value="priority">Priority</option>' +
                            '<option value="assignee">Assignee</option>' +
                            '<option value="parent_task">Parent task</option>' +
                            '<option value="start_date">Start date</option>' +
                            '<option value="due_date">Due date</option>' +
                            '<option value="estimated">Estimated</option>' +
                            '<option value="watcher">Watcher</option>' +
                            '<option value="keywords">Keywords</option>' +
                            '<option value="layouts">Layouts</option>' +
                            '<option value="symbols_ranges">Symbols Ranges</option>' +
                            '<option value="words_ranges">Words Ranges</option>' +
                            '<option value="google_documents">Google Documents</option>' +
                          '</select>';

    this.$toolBar.append($(`${selectCodeBlock}`));
  }

  $('#template-select').change(function() {
    var selected = $('#template-select').val();
    var text = '';
    var defaultValues = [
      'tracker', 'subject', 'description', 'status', 'priority', 'assignee',
      'parent_task', 'start_date', 'due_date', 'estimated', 'watcher', 'layouts',
      'symbols_ranges', 'words_ranges', 'google_documents'
    ];

    if (selected === 'default') {
      text = '';
    } else if (defaultValues.includes(selected)) {
      text = `►►${selected}◄◄`;
    } else {
      text = ` ►►${selected}◄◄`;
    }

    var txtarea = document.getElementById('layouts');
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ?
      'ff' : (document.selection ? 'ie' : false));

    if (br == 'ie') {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart('character', -txtarea.value.length);
      strPos = range.text.length;
    } else if (br == 'ff') {
      strPos = txtarea.selectionStart;
    }

    var front = (txtarea.value).substring(0, strPos);
    var back = (txtarea.value).substring(strPos, txtarea.value.length);
    txtarea.value = front + text + back;
    strPos = strPos + text.length;
    if (br == 'ie') {
      txtarea.focus();
      var ieRange = document.selection.createRange();
      ieRange.moveStart('character', -txtarea.value.length);
      ieRange.moveStart('character', strPos);
      ieRange.moveEnd('character', 0);
      ieRange.select();
    } else if (br == 'ff') {
      txtarea.selectionStart = strPos;
      txtarea.selectionEnd = strPos;
      txtarea.focus();
    }

    txtarea.scrollTop = scrollPos;
    $('#template-select').val('default');
  });
}

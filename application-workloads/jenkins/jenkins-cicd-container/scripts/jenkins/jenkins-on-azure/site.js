$(function() {
  $('.snippet').mouseenter(function() {
    $('#clipboard').remove();
    span = $(this);
    temp = $(this).text();
    snippetLen = $(this).text().length;
    $(this).find('img').show();
    $(this).append(
        '<img id="clipboard" src="copy.png" alt="Copy to Clipboard" title="Click to copy" />');

    $(this).parent().mouseleave(function() {
      $('#clipboard').remove();
    });

    $('#clipboard').click(function() {
      var doc = document, element = span[0], range, selection;
      if (doc.body.createTextRange) {
        range = document.body.createTextRange();
        range.moveToElementText(element);
        range.select();
      } else if (window.getSelection) {
        selection = window.getSelection();
        range = document.createRange();
        range.setStart(element, 0)
        range.setEndBefore($(this)[0]);
        selection.removeAllRanges();
        selection.addRange(range);
      }
      document.execCommand('copy');
    });
  });
});
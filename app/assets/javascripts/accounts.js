function shadeEveryOtherRow() {
  $('.account_row').removeClass('shade');
  $('.account_row:visible').each(function(index, element) {
    if ( index % 2 === 1 ) {
      $(element).addClass('shade');
    }
  });
}

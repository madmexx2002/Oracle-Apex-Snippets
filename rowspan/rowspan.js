/**
 * @description Group columns over rows with the help of analytic functions
 * @author Mark Lenzer
 * @version 1.0
 */
function rowSpan() {
    $('.ir-rowspan').each(function () {
        if ($(this).attr('data-rn') === '1') {
            $(this).parent('td').attr('rowspan', $(this).attr('data-tr'));
        } else {
            $(this).parent('td').remove();
        }
    })
}

(function init($) {
    // Run after ui elements rendered on page
    $(window).on('theme42ready', function () {
        rowSpan();
    })

    // Run after refresh of report
    $(document).on('apexafterrefresh', function () {
        rowSpan();
    })
})(apex.jQuery);
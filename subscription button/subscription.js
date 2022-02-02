/**
 * @function Subscripe to a channel on button click and show status on button with css class
 * @param {*} pX01 
 */
function subscription(pX01) {
    //create an array and store data-event
    var dataArray = [];

    // Collect events only if X01 is not defined
    if (pX01 === undefined) {
        $('button[data-event]').each(function () {
            dataArray.push($(this).attr('data-event'));
        });
    }

    console.log(pX01);

    // Call process
    apex.server.process('CHECK_EVENT', {
        f01: dataArray,
        x01: pX01
    }, {
        success: function (data) {
            // loop json object and set class
            for (const [key, value] of Object.entries(data.events)) {
                if (value === true) {
                    $('[data-event="' + key + '"] span').css('color', data.settings.active_color);
                    $('[data-event="' + key + '"]').prop('title', data.settings.active_text);
                } else {
                    $('[data-event="' + key + '"] span').css('color', data.settings.inactive_color);
                    $('[data-event="' + key + '"]').prop('title', data.settings.inactive_text);
                }

            }
        }
    });
}

(function init() {
    // Init subscription after page load
    apex.jQuery(window).on('theme42ready', function () {
        // Run after ui elements rendered on page
        //console.log('Init subscription on page.');
        subscription();
    })

    // Init onClick event for buttons with attribute data-event
    apex.jQuery('button[data-event]').on('click', function () {
        //console.log(apex.jQuery(this).attr('data-event'));
        subscription(apex.jQuery(this).attr('data-event'));
    })
})();
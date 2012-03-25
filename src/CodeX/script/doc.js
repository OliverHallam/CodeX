function resizePanels() {
    var navheight = $("#nav-content").outerHeight();
    var contentheight = $("#topic-content").outerHeight();
    
    var height = navheight > contentheight ? navheight : contentheight;
    $("#navigation").height(height);
    $("#topic").height(height);
}

function setLanguage(lang) {
    $('#vbtab').removeClass('active');
    $('#cstab').removeClass('active');
    $('#cpptab').removeClass('active');

    $('#' + lang + 'tab').addClass('active');

    $('.vb').hide();
    $('.cs').hide();
    $('.cpp').hide();

    $('.' + lang).show();

    $.cookie("lang", lang, { expires: 7 });

    resizePanels();
}

$(function () {
    var width = $.cookie("width");
    if (width != null) {
        $.cookie("width", width, { expires: 7 });
        $("#navigation").width(width);
    }

    resizePanels();
    $(window).resize(resizePanels);

    $("#navigation").resizable({
        stop: function (event, ui) { $.cookie("width", $(this).width(), { expires: 7 }); },
        resize: function (event, ui) { resizePanels() },
        maxWidth: 350,
        minWidth: 20,
        handles: "e"
    });

    var lang = $.cookie("lang");
    if (lang == null) {
      lang="cs";
    }
    
    $.cookie("lang", lang, { expires: 7 });
    setLanguage(lang)
});
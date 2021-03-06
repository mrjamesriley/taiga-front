var utils = require('../utils');
var helper = module.exports;

helper.assignToLightbox = function() {
    let el = $('div[tg-lb-assignedto]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        selectFirst: function() {
            el.$$('div[data-user-id]').first().click();
        },
        select: function(index) {
            el.$$('div[data-user-id]').get(index).click();
        },
        getName: function(item) {
            return el.$$('div[data-user-id] .user-list-name').get(item).getText();
        },
        getNames: function() {
            return el.$$('.user-list-name').getText();
        },
        filter: function(text) {
            return el.$('input').sendKeys(text);
        },
        userList: function() {
            return el.$$('.user-list-single');
        }
    };

    return obj;
};

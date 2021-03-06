var utils = require('../utils');

var helper = module.exports;

helper.openNewMemberLightbox = function() {
    $('.header-with-actions .button-green').click();
};

helper.getNewMemberLightbox = function() {
    let el = $('div[tg-lb-create-members]');

    let obj = {
        el: el,
        waitOpen: function() {
            return utils.lightbox.open(el);
        },
        waitClose: function() {
            return utils.lightbox.close(el);
        },
        newEmail: function(email) {
            el.$$('input').last().sendKeys(email);
            el.$('.add-fieldset').click();
        },
        getRows: function() {
            return el.$$('.add-member-wrapper');
        },
        deleteRow: function(index) {
            el.$$('.delete-fieldset').get(index).click();
        },
        submit: function() {
            el.$('.submit-button').click();
        }
    };

    return obj;
};

helper.getMembers = function() {
    return $$('.admin-membership-table .row');
};

helper.isActive = function(elm) {
    return utils.common.hasClass(elm, 'active');
};

helper.delete = function(elm) {
    elm.$('.delete').click();
};

helper.isAdmin = async function(elm) {
    let isAdmin = await elm.$('.row-admin input').getAttribute('checked');

    return (isAdmin === 'true');
};

helper.toggleAdmin = function(elm) {
    return elm.$('.row-admin input').click();
};

helper.setRole = function(elm, index) {
    return elm.$(`select option:nth-child(${index})`).click();
};

helper.sendInvitation = function(elm) {
    $$('.pending').first().click();
};

//= require modernizr
//= require jquery
//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.mouse
//= require jquery.ui.sortable
//= require jquery.ui.nestedSortable
//= require jquery.scrollto
//= require jquery_ujs
//= require bootstrap-dropdown
//= require bootstrap-alert
//= require bootstrap-tooltip
//= require bootstrap-button
//= require amalgam/extra
//= require_tree ./admin

Modernizr.addTest("boxsizing",function(){
    return Modernizr.testAllProps("boxSizing") && (document.documentMode === undefined || document.documentMode > 7);
});
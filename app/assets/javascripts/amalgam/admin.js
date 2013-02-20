//= require modernizr
//= require jquery
//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.mouse
//= require jquery.ui.sortable
//= require jquery.ui.nestedSortable
//= require jquery.scrollto
//= require jquery_ujs
//= require twitter/bootstrap/dropdown
//= require twitter/bootstrap/alert
//= require twitter/bootstrap/tooltip
//= require twitter/bootstrap/button
//= require jquery.jstree
//= require amalgam/extra
//= require_tree ./admin

Modernizr.addTest("boxsizing",function(){
    return Modernizr.testAllProps("boxSizing") && (document.documentMode === undefined || document.documentMode > 7);
});